# Hasibny (حاسبني) — Smart Account Book & Debt Manager

<p align="center">
  <img src="assets/images/hasibnyLogo.png" alt="Hasibny Logo" width="120" />
</p>

<p align="center">
  <strong>A modern, offline-first, cloud-synced financial ledger and debt management system built with Flutter & Firebase.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State_Management-GetX-8E44AD" alt="GetX" />
  <img src="https://img.shields.io/badge/Database-Isar_3.1-00B4D8" alt="Isar" />
  <img src="https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License" />
</p>

---

## 🌟 Overview

**Hasibny (حاسبني)** is a comprehensive, production-grade ledger application designed for small business owners, freelancers, merchants, and individuals. It bridges the gap between lightning-fast offline operation and seamless cloud synchronization, enabling effortless tracking of customer debts, merchant invoices, and inventory shortages.

---

## 🚀 Key Features

### 📊 Real-Time Financial Dashboard
- **Instant Balance Cards**: Visual breakdown of total amounts you owe (*Give*) vs. amounts owed to you (*Get*).
- **Customer & Merchant Stats**: Live counters for active debtors, creditors, settled accounts, and suppliers.
- **Recent Activity Feed**: Quick ledger entries with color-coded badges and instant drill-downs.

### 👥 Customer Debt & Credit Ledger
- **Complete Transaction Flow**: Clear "Give" (Debit) and "Got" (Credit) logging with date pickers and descriptions.
- **Instant Search & Filters**: Search by customer name, phone number, or balance status with zero lag.
- **Customer Profile & History**: Full chronological ledger, running balances, and direct contact shortcuts.

### 🏢 Merchant & Supplier Management
- **Supplier Hub**: Track merchant contact details, company profiles, and aggregate balances.
- **Invoice Tracking**: Log incoming invoices, payment statuses, and invoice attachments.
- **Product Search & Shortages**: Keep track of missing items and low inventory to replenish on your next supplier order.

### 🔄 Offline-First with Firebase Cloud Sync
- **Ultra-Fast Local Storage**: Powered by **Isar Database** for 60fps local performance and offline reliability.
- **Cloud Firestore Synchronization**: Automatic background synchronization when network connectivity is detected.
- **Secure Authentication**: Firebase Auth with email/password, email verification, and password reset flows.

### 🔒 Enterprise-Grade Security & Privacy
- **Biometric & PIN Lock**: Secure your financial data with PIN or fingerprint/Face ID local authentication.
- **Encrypted Local Backups**: Export and import full database backups (`.abbackup`) protected by PBKDF2-HMAC-SHA256 and AES-256-GCM encryption.

### 💬 Invoicing, Sharing & WhatsApp Integration
- **Direct WhatsApp Messaging**: Send balance statements, payment reminders, and invoices directly via WhatsApp.
- **Professional PDF & Excel Exports**: Generate high-res statements and account summaries ready to print or email.

### 🌐 Internationalization & Responsive UI
- **Bilingual Arabic & English**: Full RTL and LTR support with typography tuned with the **Cairo** and **Inter** font families.
- **Multi-Currency Engine**: Support for multiple global currencies (USD, EUR, GBP, SAR, AED, EGP, and more).
- **Responsive Layouts**: Designed to look clean across small phones, tablets, and desktop displays.
- **Dark & Light Mode**: Seamless theme switching with system-matched defaults.

---

## 🏗️ Architecture & Technology Stack

```
lib/
├── controllers/          # GetX controllers (Auth, Customer, Transaction, Merchant, Invoices, Sync)
├── core/                 # Responsive engine, breakpoints, layout helpers
├── models/               # Isar & Firestore data schemas (Customer, Transaction, Merchant, Invoice)
├── services/             # Core services (DatabaseService, FirestoreService, SyncService, BackupService, WhatsAppService)
├── themes/               # Material 3 light & dark design themes
├── translations/         # Localization dictionaries (Arabic & English)
├── utils/                # Currency formatters, input formatters, helpers
├── views/                # Modular view screens (Auth, Dashboard, Customers, Merchants, Invoices, Settings)
└── widgets/              # Reusable UI components (AppCard, AppButton, AmountField, StatsCard)
```

| Component | Technology | Description |
|:---|:---|:---|
| **Framework** | Flutter 3.x / Dart 3.x | Cross-platform UI toolkit |
| **State Management** | GetX | Reactive state management & dependency injection |
| **Local Database** | Isar 3.1 | High-performance, embedded NoSQL database |
| **Cloud Services** | Firebase Auth & Firestore | Secure user authentication and real-time cloud sync |
| **Encryption** | PointyCastle / Cryptography | AES-256-GCM & PBKDF2 for encrypted file backups |
| **Reports** | PDF & Printing | Dynamic PDF invoice and ledger statement generation |

---

## 🏁 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10+ recommended)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code with Flutter extension
- Firebase project configured (if testing cloud synchronization)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/bebk7/Hasibny.git
   cd Hasibny/account_book
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code (Isar models)**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Firebase Configuration** *(Optional for local-only testing)*:
   - Place your `google-services.json` in `android/app/`
   - Place your `GoogleService-Info.plist` in `ios/Runner/`
   - Configure `lib/firebase_options.dart` via the FlutterFire CLI:
     ```bash
     flutterfire configure
     ```

5. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Hasibny includes comprehensive unit, widget, and screen-render test suites:

```bash
flutter test
```

To run static analysis:
```bash
dart analyze
```

---

## 🛡️ Security & Safe Credential Handling

- **Zero Hardcoded Secrets**: Sensitive configuration files (`google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart`) are excluded from version control via `.gitignore`.
- **Encrypted Local Backups**: User database exports are encrypted with user-defined passwords before being written to storage.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feat/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add AmazingFeature'`)
4. Push to the Branch (`git push origin feat/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
