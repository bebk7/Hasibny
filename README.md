# Account Book & Debt Manager

A high-end, production-ready Flutter application for managing customer debts and credits with a modern, intuitive interface.

## Features

### 🏠 Dashboard
- **Real-time Balance Cards**: Display total amounts to give and get with beautiful gradient cards
- **Customer Statistics**: Track total customers, active debtors, creditors, and settled accounts
- **Recent Transactions**: Quick overview of latest financial activities
- **Quick Actions**: Fast access to add customers and transactions

### 👥 Customer Management
- **Complete CRUD Operations**: Add, edit, delete customers with ease
- **Smart Search**: Filter customers by name or phone number instantly
- **Profile Pictures**: Add customer photos for personalization
- **Balance Overview**: See at a glance who owes you and who you owe
- **Hero Animations**: Smooth transitions when navigating to customer details

### 💰 Debt Tracking
- **Transaction Types**: Clear distinction between "Give" (debit) and "Got" (credit)
- **Automatic Calculations**: Real-time balance updates for each customer
- **Transaction History**: Complete ledger for each customer
- **Color-Coded Interface**: Intuitive visual feedback (Teal for credits, Orange for debits)

### ⚙️ Settings & Tools
- **Currency Selector**: Support for multiple currencies (USD, EUR, GBP, JPY)
- **Dark/Light Mode**: Automatic system theme detection with manual override
- **App Lock**: PIN and biometric authentication for data security
- **Data Export**: Backup functionality with PDF and Excel export options
- **Privacy Controls**: Complete data privacy with local storage only

## Technical Architecture

### 🏗️ Project Structure
```
lib/
├── controllers/          # GetX state management
│   ├── customer_controller.dart
│   ├── transaction_controller.dart
│   └── dashboard_controller.dart
├── models/              # Data models with Isar
│   ├── customer.dart
│   └── transaction.dart
├── services/            # Business logic
│   └── database_service.dart
├── views/               # UI screens
│   ├── home/
│   ├── dashboard/
│   ├── customers/
│   ├── transactions/
│   └── settings/
├── widgets/             # Reusable UI components
├── themes/              # App theming
└── utils/               # Helper functions
```

### 🛠️ Technology Stack
- **Framework**: Flutter 3.10.0+
- **State Management**: GetX 4.6.6
- **Database**: Isar 3.1.0 (High-performance local database)
- **Animations**: Lottie 2.7.0, Flutter Staggered Animations
- **UI Components**: Material 3 Design System
- **Image Handling**: Image Picker, Cached Network Images
- **Export**: PDF generation, Excel export
- **Security**: Local Authentication (PIN/Biometric)

### 🎨 Design System
- **Color Palette**: Professional Deep Blue/Teal for credits, Soft Red/Orange for debits
- **Typography**: Inter font family for modern readability
- **Animations**: Hero animations, AnimatedContainer, Lottie success states
- **Responsive**: Optimized for phones and tablets
- **Dark Theme**: Complete dark mode support

## Getting Started

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK compatible with Flutter version
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/account-book.git
   cd account-book
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Isar schemas**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Key Features Implementation

### 📊 Real-time Dashboard
- Live balance calculations using reactive GetX controllers
- Animated balance cards with gradient backgrounds
- Customer statistics with intuitive icons
- Recent transactions with color-coded indicators

### 🔍 Smart Search & Filtering
- Instant customer search with debounced input
- Transaction filtering by type and date range
- Real-time list updates without page refresh

### 🎯 User Experience
- **Hero Animations**: Smooth customer list to details transitions
- **Swipe Gestures**: Delete transactions with haptic feedback
- **Floating Action Button**: Quick transaction entry
- **Bottom Navigation**: Custom design with center docked FAB

### 🔐 Security & Privacy
- **Local Storage**: All data stored locally using Isar database
- **App Lock**: Optional PIN and biometric authentication
- **No Tracking**: No analytics or data collection
- **Privacy First**: User data never leaves the device

## Data Models

### Customer
```dart
class Customer {
  late String name;
  late String phoneNumber;
  String? profilePicturePath;
  late DateTime createdAt;
  late DateTime updatedAt;
}
```

### Transaction
```dart
class TransactionModel {
  late double amount;
  late TransactionType type; // Give or Got
  late String description;
  late DateTime createdAt;
  final customer = IsarLink<Customer>();
}
```

## Performance Optimizations

- **Lazy Loading**: Efficient list rendering with pagination
- **Memory Management**: Proper disposal of resources
- **Database Indexing**: Optimized queries with Isar indexes
- **Image Caching**: Efficient profile picture handling
- **State Management**: Minimal rebuilds with GetX reactive programming

## Future Enhancements

- [ ] Cloud synchronization (optional)
- [ ] Advanced reporting and analytics
- [ ] Multi-currency support with real-time rates
- [ ] Transaction categories and tags
- [ ] Payment reminders and notifications
- [ ] Data import from other apps
- [ ] Web dashboard interface

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please contact:
- Email: labeeb.kaleessi@gmail.com
- Phone: +967 774 190 100

---

**Built with ❤️ using Flutter**
