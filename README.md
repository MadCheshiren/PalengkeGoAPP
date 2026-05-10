# PalengkeGo

A Flutter mobile app for local Filipino public markets (palengke). It bridges customers and vendors in a single ecosystem — customers browse stalls, compare fresh goods, build carts, and track orders; vendors manage product listings, inventory, and order fulfillment without leaving the app.

## Features

### For Customers
- Browse stalls and products by category
- Compare prices and freshness ratings
- Build shopping carts and checkout with multiple payment methods (Cash on Delivery, GCash, Card)
- Track order status in real time
- Save favorite recipes with ingredient checklists
- Manage delivery addresses and payment methods
- View order history and reorder past items
- Receive push notifications for order updates

### For Vendors
- Manage stall profile and visibility
- Add, edit, and remove product listings
- Track stock levels and mark items out of stock
- View incoming orders and update preparation status
- Monitor weekly earnings and sales trends

## Tech Stack

- **Framework:** Flutter 3.x (stable channel)
- **Language:** Dart
- **Backend:** Firebase (Authentication, Firestore, Cloud Functions)
- **Payments:** Paymongo API (GCash, Card, Cash on Delivery)
- **Recipe Generation:** To be decided by the team (TBD)
- **Primary Target:** Android
- **Secondary Target:** Web (for preview and testing)
- **State Management:** StatefulWidget + service layer
- **Navigation:** MaterialPageRoute + named routes

## Project Structure

```
lib/
├── core/
│   ├── services/       # Business logic: auth, cart, orders, payments, preferences
│   ├── widgets/        # Reusable UI components (headers, buttons, cards)
│   └── utils/          # Helpers, constants, extensions
├── features/
│   ├── auth/           # Login, registration, onboarding, splash
│   ├── cart/           # Shopping cart, item management
│   ├── checkout/       # Payment selection, order confirmation, address flow
│   ├── home/           # Market browsing, stall discovery, product search
│   ├── main/           # Bottom navigation shell
│   ├── notifications/  # In-app notification list
│   ├── onboarding/     # First-launch experience
│   ├── orders/         # Order history, details, tracking
│   ├── profile/        # User profile, settings, security
│   ├── recipes/        # Recipe discovery, ingredient lists, cooking steps
│   └── vendors/        # Vendor dashboard, earnings, product management
└── main.dart           # App entry point and theme setup
```

## Quick Start

### Prerequisites
- Flutter SDK 3.x (stable channel)
- Android Studio or VS Code with Flutter / Dart extensions
- Android emulator (API 28+) or a physical Android device with USB debugging
- Git

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd palengkego

# Fetch dependencies
flutter pub get

# Verify setup
flutter doctor
```

### Run the App

```bash
# Android device / emulator (primary target)
flutter run

# Or Chrome for quick UI preview (no native plugins)
flutter run -d chrome

# List available devices
flutter devices
```

### Build for Production

```bash
# Release APK
flutter build apk --release

# App bundle (for Play Store)
flutter build appbundle --release
```

## Development Workflow

1. **Before coding:** Run `flutter analyze` on a clean state to confirm baseline is green.
2. **During coding:** Use hot reload (`r` in terminal) for quick UI iteration.
3. **After code changes:** Always run `flutter analyze` and fix all warnings before committing.
4. **Before a commit:** Restart the dev server fresh — do not rely on hot restart when modifying global state or services.
5. **Before a PR:** Run the app on a real device or emulator to verify flows end-to-end.

## Tips

- **Firebase setup:** Ensure `google-services.json` is in `android/app/` and Firebase is initialized in `main.dart` before running auth or database features.
- **Paymongo testing:** Payment flows are mocked in development. For real testing, configure your Paymongo secret keys in environment variables or a secure config file.
- **Recipe API placeholder:** The recipe generation feature currently uses static/mock data. Once the team decides on an API (e.g., Spoonacular, OpenAI, or a custom backend), swap the mock service in `core/services/recipe_service.dart`.
- **Asset images:** If you add new images to `assets/`, remember to list them in `pubspec.yaml` and fully restart the app (hot reload won't pick them up).
- **Global state gotchas:** Service classes in `core/services/` hold singleton state. If behavior feels "stuck" after code changes, stop the dev server and restart fresh.
- **Emulator vs device:** Some Firebase features (like push notifications) only work on real devices. Test critical flows on hardware when possible.

## Code Standards

- Use `const` constructors for widgets and literals where possible
- Prefer `SizedBox` over `Container` when you only need whitespace
- Do not use `BuildContext` across async gaps without a `mounted` guard
- Avoid deprecated Flutter APIs — `flutter analyze` will flag them
- Keep UI code in `presentation/pages/` and business logic in `core/services/`
- Follow the existing feature-based folder structure for new screens

## Architecture Notes

- **Presentation layer:** StatelessWidget / StatefulWidget in `features/*/presentation/pages/`
- **Service layer:** Plain Dart classes in `core/services/` hold business logic and in-memory state
- **No external state management:** The app uses StatefulWidget + service singletons. If the project grows, consider migrating to Riverpod or Bloc.
- **Navigation:** Imperative (`Navigator.push`) for now. Deep linking and declarative routing are future considerations.

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | Primary | Full feature support |
| iOS      | Not supported | No macOS build environment |
| Web      | Preview | Good for UI testing; some native plugins may not work |
| Windows  | Not supported | Desktop not in project scope |
| Linux    | Not supported | Desktop not in project scope |
| macOS    | Not supported | Desktop not in project scope |

## Troubleshooting

- **`flutter analyze` fails:** Fix all warnings before opening a PR. The project enforces a zero-warning policy.
- **App crashes on hot restart:** Stop the server and run `flutter run` again. Stale global service state can cause errors.
- **Images not loading:** Ensure `assets/` folder is listed in `pubspec.yaml` and the app has been rebuilt (not just hot reloaded).
- **Firebase auth errors:** Verify `google-services.json` is present and Firebase is initialized in `main.dart`. Check that your device has an internet connection.
- **Paymongo payment errors:** Payment flows are mocked in development. For live testing, configure Paymongo API keys and ensure the device can reach Paymongo servers.

## Contributing

1. Fork the repository and create a feature branch (`git checkout -b feature/your-feature`)
2. Make your changes and ensure `flutter analyze` passes with zero issues
3. Test on an Android emulator or physical device
4. Commit with a clear message describing the change
5. Open a pull request with a short description of what changed and why

## License

This project is for academic / thesis purposes. Contact the maintainers for reuse or distribution questions.
