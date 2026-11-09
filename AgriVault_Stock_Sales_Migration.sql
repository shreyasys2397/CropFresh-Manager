-- AgriVault stock tracking and sales history migration
-- Run once in Supabase Dashboard > SQL Editor.
-- This migration adds stock balances, a sales ledger, RLS policies,
-- and an atomic database function for recording sales.

BEGIN;

-- Stock fields for each crop.
ALTER TABLE public.crops
    ADD COLUMN IF NOT EXISTS initial_quantity NUMERIC,
    ADD COLUMN IF NOT EXISTS remaining_quantity NUMERIC,
    ADD COLUMN IF NOT EXISTS quantity_unit TEXT;

-- Backfill existing crop quantities such as "50 kg" or "120 boxes".
UPDATE public.crops
SET
    initial_quantity = COALESCE(
        initial_quantity,
        NULLIF(substring(quantity FROM '^[[:space:]]*([0-9]+([.][0-9]+)?)'), '')::NUMERIC,
        0
    ),
    remaining_quantity = COALESCE(
        remaining_quantity,
        initial_quantity,
        NULLIF(substring(quantity FROM '^[[:space:]]*([0-9]+([.][0-9]+)?)'), '')::NUMERIC,
        0
    ),
    quantity_unit = COALESCE(
        NULLIF(trim(quantity_unit), ''),
        NULLIF(lower(trim(substring(quantity FROM '[[:alpha:]]+'))), ''),
        'kg'
    );

ALTER TABLE public.crops
    ALTER COLUMN initial_quantity SET DEFAULT 0,
    ALTER COLUMN remaining_quantity SET DEFAULT 0,
    ALTER COLUMN quantity_unit SET DEFAULT 'kg',
    ALTER COLUMN initial_quantity SET NOT NULL,
    ALTER COLUMN remaining_quantity SET NOT NULL,
    ALTER COLUMN quantity_unit SET NOT NULL;

-- Ensure users can read, update, and delete only their own crops.
ALTER TABLE public.crops ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "AgriVault users can select own crops" ON public.crops;
CREATE POLICY "AgriVault users can select own crops"
    ON public.crops FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "AgriVault users can insert own crops" ON public.crops;
CREATE POLICY "AgriVault users can insert own crops"
    ON public.crops FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "AgriVault users can update own crops" ON public.crops;
CREATE POLICY "AgriVault users can update own crops"
    ON public.crops FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "AgriVault users can delete own crops" ON public.crops;
CREATE POLICY "AgriVault users can delete own crops"
    ON public.crops FOR DELETE
    USING (auth.uid() = user_id);

-- Sales ledger. Removing a crop also removes its sales rows.
CREATE TABLE IF NOT EXISTS public.crop_sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    crop_id UUID NOT NULL REFERENCES public.crops(id) ON DELETE CASCADE,
    crop_name TEXT NOT NULL,
    quantity_sold NUMERIC NOT NULL CHECK (quantity_sold > 0),
    quantity_unit TEXT NOT NULL,
    sale_date DATE NOT NULL,
    remaining_after NUMERIC NOT NULL CHECK (remaining_after >= 0),
    buyer_name TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS crop_sales_user_date_idx
    ON public.crop_sales(user_id, sale_date DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS crop_sales_crop_idx
    ON public.crop_sales(crop_id);

ALTER TABLE public.crop_sales ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "AgriVault users can select own sales" ON public.crop_sales;
CREATE POLICY "AgriVault users can select own sales"
    ON public.crop_sales FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "AgriVault users can insert own sales" ON public.crop_sales;
CREATE POLICY "AgriVault users can insert own sales"
    ON public.crop_sales FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Atomic sale: lock the crop row, validate stock, update the balance,
-- and insert the sales-history row in one transaction.
CREATE OR REPLACE FUNCTION public.record_crop_sale(
    p_crop_id UUID,
    p_quantity_sold NUMERIC,
    p_sale_date DATE,
    p_buyer_name TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS SETOF public.crop_sales
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
    v_crop public.crops%ROWTYPE;
    v_remaining NUMERIC;
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Authentication required';
    END IF;

    IF p_quantity_sold IS NULL OR p_quantity_sold <= 0 THEN
        RAISE EXCEPTION 'Sale quantity must be greater than zero';
    END IF;

    IF p_sale_date IS NULL OR p_sale_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Sale date must be today or earlier';
    END IF;

    SELECT *
    INTO v_crop
    FROM public.crops
    WHERE id = p_crop_id
      AND user_id = auth.uid()
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Crop not found or access denied';
    END IF;

    IF p_sale_date < v_crop.harvest_date THEN
        RAISE EXCEPTION 'Sale date cannot be earlier than the harvest date';
    END IF;

    v_remaining := v_crop.remaining_quantity;

    IF p_quantity_sold > v_remaining THEN
        RAISE EXCEPTION 'Insufficient stock. Available quantity: % %',
            v_remaining, v_crop.quantity_unit;
    END IF;

    v_remaining := v_remaining - p_quantity_sold;

    UPDATE public.crops
    SET remaining_quantity = v_remaining
    WHERE id = p_crop_id
      AND user_id = auth.uid();

    RETURN QUERY
    INSERT INTO public.crop_sales (
        user_id,
        crop_id,
        crop_name,
        quantity_sold,
        quantity_unit,
        sale_date,
        remaining_after,
        buyer_name,
        notes
    )
    VALUES (
        auth.uid(),
        p_crop_id,
        v_crop.name,
        p_quantity_sold,
        v_crop.quantity_unit,
        p_sale_date,
        v_remaining,
        NULLIF(trim(p_buyer_name), ''),
        NULLIF(trim(p_notes), '')
    )
    RETURNING *;
END;
$$;

GRANT EXECUTE ON FUNCTION public.record_crop_sale(UUID, NUMERIC, DATE, TEXT, TEXT)
    TO authenticated;

COMMIT;
