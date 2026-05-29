# OUT fIT - Fashion Store App

A Flutter mobile app based on the OUT fIT Figma design.

## 📱 Screens Included

| Screen | Description |
|--------|-------------|
| Splash | Animated logo splash screen |
| Welcome | Sign In / Register landing |
| Sign In | Email + password login with Google/Apple options |
| Register | Account creation form |
| Home | Product grid with category filter & search bar |
| Search | Recent searches + Trending Now categories |
| Product Detail | Full product page with size selector & quantity |
| Cart | Cart items with order summary |
| Checkout | Order summary + payment method selection |
| Success | Payment success confirmation |
| Profile | User profile with edit mode |
| Settings | Account settings + preferences (notifications, theme, language) |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Dart SDK (comes with Flutter)
- Android Studio or VS Code with Flutter extension

### Steps

```bash
# 1. Navigate into the project
cd outfit_app

# 2. Install dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build for iOS
```bash
flutter build ios --release
```

## 🎨 Design System

| Token | Value |
|-------|-------|
| Primary Red | `#E8253A` |
| Dark Brown | `#2C2416` |
| Star Gold | `#FFB800` |
| Font Display | Playfair Display |
| Font Body | Lato |

## 📦 Dependencies

```yaml
google_fonts: ^6.1.0   # Playfair Display + Lato
cupertino_icons: ^1.0.6
```

## 📁 Project Structure

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart       # Colors, text styles, button themes
├── models/
│   ├── product.dart         # Product & CartItem models + sample data
│   └── cart_provider.dart   # Cart state management
└── screens/
    ├── splash_screen.dart
    ├── welcome_screen.dart
    ├── signin_screen.dart
    ├── register_screen.dart
    ├── home_screen.dart
    ├── product_detail_screen.dart
    ├── search_screen.dart
    ├── cart_screen.dart
    ├── checkout_screen.dart
    ├── success_screen.dart
    ├── profile_screen.dart
    └── settings_screen.dart
```

## 🔌 No Firebase Required

This project uses local in-memory state only — no Firebase or backend setup needed.
To add Firebase later, visit: https://firebase.google.com/docs/flutter/setup
