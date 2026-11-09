# 🌱 AgriVault: CropFresh Manager

**Smart Crop Shelf-Life, Storage Monitoring and Inventory Management System**

AgriVault is a web-based application designed to help users monitor crop storage conditions, manage agricultural inventory, track shelf life, and record sales. It provides temperature and humidity monitoring, crop expiry alerts, stock management, sales tracking, and PDF report generation in one platform.

The application uses Supabase for authentication and cloud database storage.

---

## 🚀 Key Features

### 1. User Authentication
- User registration and login.
- Secure authentication using Supabase.
- User-specific crop and sales records.
- Logout functionality.

### 2. Temperature Monitoring
- Monitor current storage temperature.
- Increase or decrease temperature settings.
- Adjustable temperature control.
- Compare actual temperature with optimal crop storage temperature.
- Temperature status indicators and history.

### 3. Humidity Monitoring
- Monitor current storage humidity.
- Adjustable humidity settings.
- Define optimal humidity levels for individual crops.
- Compare actual humidity with optimal humidity.
- Humidity status indicators and history.

### 4. Crop Management
- Add and manage different crops.
- Enter crop name, quantity, category, and harvest date.
- Set optimal temperature and humidity.
- Define crop shelf life.
- Automatically calculate expiry dates.
- Track crop freshness through status indicators:
  - Good
  - Expiring Soon
  - Expired
- Delete crops when required.

### 5. Stock Management
- Record initial crop quantities.
- Track remaining stock.
- Automatically update stock after sales.
- Prevent sales exceeding available stock.

### 6. Record Sales
- Dedicated Record Sales section.
- Select crops from available inventory.
- Record quantity sold and sale date.
- Optionally enter buyer details and notes.
- View previous sales records.
- Automatically update remaining stock.

### 7. History and Analytics
- View temperature and humidity history.
- Monitor crop storage conditions.
- Analyse crop freshness and expiry status.
- View crop-specific environmental information.

### 8. Alerts and Notifications
- Crop expiry alerts.
- Storage temperature and humidity status alerts.
- Environmental condition warnings.
- Emergency adjustment options.

### 9. PDF Reports
- Generate downloadable PDF reports.
- Include crop inventory details.
- Include crop shelf-life information.
- Include remaining stock quantities.
- Include sales transaction history.
- Include relevant storage monitoring information.

---

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| HTML5 | Application structure |
| CSS3 | Styling and responsive interface |
| JavaScript | Application functionality |
| AngularJS | Dynamic data binding and interface updates |
| Supabase | Authentication and database |
| PostgreSQL | Cloud database |
| jsPDF | PDF report generation |
| GitHub | Version control and hosting |

---

## 🏗️ Application Architecture

AgriVault follows a client-server architecture.

1. **Frontend:** HTML, CSS, JavaScript and AngularJS provide the user interface and application logic.
2. **Backend:** Supabase handles authentication and database operations.
3. **Database:** PostgreSQL stores crop information, stock quantities, environmental history and sales records.
4. **Reporting:** PDF generation provides downloadable inventory and sales reports.

---

## ⚙️ Installation and Setup

### Prerequisites
- A web browser.
- Visual Studio Code.
- VS Code Live Server extension.
- A Supabase account.

### Step 1: Clone the Repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

Navigate to the project directory:

```bash
cd YOUR_PROJECT_FOLDER
```

### Step 2: Configure Supabase

1. Create a project in [Supabase](https://supabase.com/).
2. Open Project Settings and locate your API credentials.
3. Configure the Supabase project URL and publishable key in the application.
4. Enable email authentication.
5. Configure the required authentication redirect URLs.

Never expose your Supabase service-role key in frontend code.

### Step 3: Configure the Database

1. Open the Supabase SQL Editor.
2. Open `AgriVault_Stock_Sales_Migration.sql`.
3. Copy its contents into the SQL Editor.
4. Execute the migration.

This migration configures the additional stock and sales database functionality.

### Step 4: Run the Application

1. Open the project folder in Visual Studio Code.
2. Open the main HTML file.
3. Right-click and select **Open with Live Server**.
4. Access the application through the local browser URL.

---

## 📊 Database Overview

AgriVault uses Supabase PostgreSQL to store application data.

### Crops Table
Stores:
- Crop identification and name.
- Initial and remaining quantities.
- Crop category and harvest date.
- Shelf-life duration.
- Optimal temperature and humidity.
- Environmental history.
- User association.

### Crop Sales Table
Stores:
- Sales transaction details.
- Associated crop.
- Quantity sold.
- Sale date.
- Remaining stock after the sale.
- Optional buyer name and notes.

**Security:** Row Level Security (RLS) policies restrict access to records belonging to the authenticated user.

---

## 🧪 Testing and Validation

The application has been tested for the following operations:

- User registration, login and logout.
- Adding and deleting crops.
- Crop shelf-life and expiry calculations.
- Temperature and humidity functionality.
- Initial and remaining stock management.
- Sales recording and stock deduction.
- Prevention of sales exceeding available stock.
- Rejection of future sale dates.
- Data persistence after refreshing the application.
- PDF report generation with sales information.

---

## 🎯 Project Objective

The primary objective of AgriVault is to provide a digital solution for monitoring crop storage conditions and managing agricultural inventory.

By combining shelf-life tracking, environmental monitoring, stock management and sales recording, the application helps users maintain better visibility of stored crops and their availability.

---

## 🔮 Future Enhancements

- Integration with IoT temperature and humidity sensors.
- Real-time environmental monitoring.
- Automated alerts through external notification services.
- Mobile application support.
- Advanced crop storage analytics.

---

## 👨‍💻 Developed By

**AgriVault Project Team**

---

## 📄 License

No license has been specified yet. Add a license file if you intend to make the project open source.

---

**AgriVault: Smarter Storage. Better Crop Management.** 🌱
