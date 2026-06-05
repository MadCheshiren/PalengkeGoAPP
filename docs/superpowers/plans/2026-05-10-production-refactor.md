# Production Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor PalengkeGo into a cleaner, production-ready Flutter architecture without changing visible behavior.

**Architecture:** Move from page-heavy StatefulWidget screens and global singleton services toward feature-owned models, repositories/services, Riverpod providers, and smaller reusable widgets. Keep the existing visual design and navigation behavior stable while introducing production seams for persistence, Firebase, payments, and test coverage.

**Tech Stack:** Flutter 3.x, Dart, flutter_riverpod, flutter_test, Material navigation, existing in-memory services during transition.

---

## Usage-Limit Strategy

Each phase is designed as one bounded work session. Stop after the verification gate, summarize changed files, and commit before beginning the next phase. If a phase grows too large, split it at the nearest feature boundary and keep the app analyzer-clean before stopping.

Baseline command before every phase:

```powershell
flutter analyze
flutter test
```

Expected baseline at plan creation:

```text
flutter analyze: No issues found
flutter test: should pass or expose the current widget-test baseline before implementation begins
```

Commit pattern:

```powershell
git status --short
git add <changed files>
git commit -m "refactor: <phase summary>"
```

---

## Current Codebase Map

Primary files and responsibilities:

- `lib/main.dart`: app entry point, `ProviderScope`, theme, responsive wrapper, splash home.
- `lib/core/services/cart_service.dart`: cart model, mutable cart state, global cart singleton, bottom-nav badge coupling.
- `lib/core/services/order_service.dart`: order models, mock order data, order creation, global order singleton.
- `lib/core/services/customer_preferences_service.dart`: preference state and profile-like user settings.
- `lib/core/mock/mock_data.dart`: shared mock catalog/vendor/recipe data.
- `lib/core/theme/app_theme.dart`: app theme.
- `lib/core/widgets/*`: shared UI widgets.
- `lib/features/*/presentation/pages/*`: large feature screens with UI, local state, navigation, and some feature logic mixed together.
- `test/widget_test.dart`: default/minimal widget test only.

Largest refactor targets:

- `lib/features/checkout/presentation/pages/checkout_screen.dart`
- `lib/features/orders/presentation/pages/order_details_screen.dart`
- `lib/features/orders/presentation/pages/track_order_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_onboarding_screen.dart`
- `lib/features/cart/presentation/pages/shopping_cart_screen.dart`
- `lib/features/recipes/presentation/pages/recipe_details_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_profile_screen.dart`
- `lib/features/home/presentation/pages/market_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_dashboard_screen.dart`
- `lib/features/profile/presentation/pages/security_settings_screen.dart`

---

## Phase 0: Baseline Safety And Inventory

**Purpose:** Lock in current behavior before structural edits.

**Files:**
- Modify: `README.md`
- Create: `docs/ARCHITECTURE_REFACTOR.md`
- Create: `test/services/cart_service_test.dart`
- Create: `test/services/order_service_test.dart`

- [ ] Run `flutter analyze` and confirm the current analyzer baseline is green.

- [ ] Run `flutter test` and record whether the existing `test/widget_test.dart` passes. If it fails because the default test no longer matches the app, replace it with a smoke test that pumps `PalengkeGoApp`.

- [ ] Create `docs/ARCHITECTURE_REFACTOR.md` with the target architecture:
  - Feature folders keep `presentation/`.
  - Add `domain/` for models and pure business rules.
  - Add `application/` for Riverpod providers and controllers.
  - Add `data/` for repositories and future Firebase/Paymongo adapters.
  - Keep `core/widgets/` only for cross-feature widgets.
  - Keep `core/theme/` for app-wide visual tokens.

- [ ] Add unit tests for `CartService`:
  - adding a new item increases `items`, `itemCount`, and `subtotal`;
  - adding the same vendor/product/weight increments quantity;
  - `updateQuantity(index, 0)` removes the item;
  - `selectAll(false)` excludes items from `itemCount` and `subtotal`;
  - `clearCart()` empties the cart.

- [ ] Add unit tests for `OrderService`:
  - empty item list returns no orders;
  - selected cart items are grouped by vendor;
  - each created order contains copied line items;
  - pickup orders start as `Pending`;
  - delivery orders start as `Confirmed`.

- [ ] Verification gate:

```powershell
flutter analyze
flutter test test/services/cart_service_test.dart test/services/order_service_test.dart
flutter test
```

- [ ] Commit:

```powershell
git add README.md docs/ARCHITECTURE_REFACTOR.md test/services/cart_service_test.dart test/services/order_service_test.dart test/widget_test.dart
git commit -m "test: add refactor safety baseline"
```

---

## Phase 1: Domain Models And Pure Data Types

**Purpose:** Separate production data shapes from mutable UI/service state.

**Files:**
- Create: `lib/features/cart/domain/cart_item.dart`
- Create: `lib/features/orders/domain/order_line_item.dart`
- Create: `lib/features/orders/domain/market_order.dart`
- Create: `lib/features/orders/domain/order_status.dart`
- Modify: `lib/core/services/cart_service.dart`
- Modify: `lib/core/services/order_service.dart`
- Modify: affected imports in `lib/features/**`
- Modify: `test/services/cart_service_test.dart`
- Modify: `test/services/order_service_test.dart`

- [ ] Move `CartItem` from `core/services/cart_service.dart` into `features/cart/domain/cart_item.dart`.

- [ ] Make `CartItem` support copy-style updates so UI code no longer mutates `quantity` and `selected` directly.

- [ ] Move `OrderLineItem` into `features/orders/domain/order_line_item.dart`.

- [ ] Move `MarketOrder` into `features/orders/domain/market_order.dart`.

- [ ] Introduce `OrderStatus` enum in `features/orders/domain/order_status.dart` with values matching current string statuses:
  - `pending`
  - `confirmed`
  - `completed`
  - `cancelled`

- [ ] Keep display labels in one place by adding an extension or getter that maps `OrderStatus.pending` to `Pending`, and so on.

- [ ] Update `OrderService` to use `OrderStatus` internally while preserving the labels rendered by existing screens.

- [ ] Update all imports from `core/services/cart_service.dart` and `core/services/order_service.dart` so screens import domain models from feature folders when they only need data types.

- [ ] Verification gate:

```powershell
flutter analyze
flutter test test/services/cart_service_test.dart test/services/order_service_test.dart
flutter test
```

- [ ] Commit:

```powershell
git add lib test
git commit -m "refactor: extract cart and order domain models"
```

---

## Phase 2: Riverpod Service Providers

**Purpose:** Remove direct dependence on global singleton variables while keeping service behavior intact.

**Files:**
- Create: `lib/features/cart/application/cart_provider.dart`
- Create: `lib/features/orders/application/order_provider.dart`
- Modify: `lib/core/services/cart_service.dart`
- Modify: `lib/core/services/order_service.dart`
- Modify: `lib/features/cart/presentation/pages/shopping_cart_screen.dart`
- Modify: `lib/features/checkout/presentation/pages/checkout_screen.dart`
- Modify: `lib/features/orders/presentation/pages/order_history_screen.dart`
- Modify: `lib/features/vendors/presentation/widgets/add_to_cart_bottom_sheet.dart`
- Modify: other files that reference `globalCart` or `globalOrders`
- Modify: service tests as needed

- [ ] Add `cartServiceProvider` as a Riverpod provider for a single app-scoped `CartService`.

- [ ] Add `orderServiceProvider` as a Riverpod provider for a single app-scoped `OrderService`.

- [ ] Keep `globalCart` and `globalOrders` temporarily only as compatibility shims, marked with a short deprecation comment.

- [ ] Convert cart screens/widgets that read or mutate cart state to `ConsumerStatefulWidget` or `ConsumerWidget`.

- [ ] Replace direct `globalCart` calls with `ref.read(cartServiceProvider)` and listener/watch usage where rebuilds are required.

- [ ] Replace direct `globalOrders` calls with `ref.read(orderServiceProvider)` or `ref.watch(orderServiceProvider)` as appropriate.

- [ ] Remove the cart service import from widgets that only need the domain model.

- [ ] Verification gate:

```powershell
flutter analyze
flutter test
```

- [ ] Commit:

```powershell
git add lib test
git commit -m "refactor: provide cart and order services through Riverpod"
```

---

## Phase 3: Navigation Centralization

**Purpose:** Make app flow easier to reason about before production auth, onboarding, and deep links are introduced.

**Files:**
- Create: `lib/core/navigation/app_routes.dart`
- Create: `lib/core/navigation/app_router.dart`
- Modify: `lib/main.dart`
- Modify: all screens with repeated `MaterialPageRoute` usage
- Add or modify widget tests for route smoke coverage

- [ ] Define route names in `AppRoutes` for:
  - splash
  - onboarding
  - login
  - registration
  - main
  - market
  - cart
  - checkout
  - paymentMethods
  - addCreditCard
  - orderConfirmation
  - orderHistory
  - orderDetails
  - trackOrder
  - profile
  - editProfile
  - securitySettings
  - setDeliveryAddress
  - notifications
  - recipes
  - recipeDetails
  - vendorDashboard
  - vendorOrders
  - vendorProducts
  - vendorAddProduct
  - vendorEarnings
  - vendorProfile
  - vendorOnboarding

- [ ] Add an `AppRouter.onGenerateRoute` function that returns the same screen widgets currently pushed manually.

- [ ] Update `MaterialApp` in `lib/main.dart` to use `initialRoute`, `onGenerateRoute`, and existing theme/builder behavior.

- [ ] Replace straightforward `Navigator.push(context, MaterialPageRoute(...))` calls with named route pushes.

- [ ] Keep custom page transitions only where they currently matter, and centralize them in `core/utils/page_transitions.dart` or the router.

- [ ] Verification gate:

```powershell
flutter analyze
flutter test
```

- [ ] Commit:

```powershell
git add lib test
git commit -m "refactor: centralize app navigation"
```

---

## Phase 4: Mock Data Boundary

**Purpose:** Prepare the app for Firebase and API-backed data by isolating mock data behind repositories.

**Files:**
- Create: `lib/features/market/domain/vendor.dart`
- Create: `lib/features/market/domain/product.dart`
- Create: `lib/features/market/data/market_repository.dart`
- Create: `lib/features/market/data/mock_market_repository.dart`
- Create: `lib/features/market/application/market_provider.dart`
- Create: `lib/features/recipes/domain/recipe.dart`
- Create: `lib/features/recipes/data/recipe_repository.dart`
- Create: `lib/features/recipes/data/mock_recipe_repository.dart`
- Create: `lib/features/recipes/application/recipe_provider.dart`
- Modify: `lib/core/mock/mock_data.dart`
- Modify: `lib/features/home/presentation/pages/market_screen.dart`
- Modify: `lib/features/recipes/presentation/pages/recipes_screen.dart`
- Modify: `lib/features/recipes/presentation/pages/recipe_details_screen.dart`
- Add repository tests under `test/features/market/` and `test/features/recipes/`

- [ ] Extract vendor/product data structures from generic maps or screen-local structures into typed domain models.

- [ ] Create `MarketRepository` interface with read methods needed by `market_screen.dart`.

- [ ] Create `MockMarketRepository` that wraps current mock market data.

- [ ] Create `marketRepositoryProvider` and update market UI to depend on the provider.

- [ ] Extract recipe structures into typed domain models.

- [ ] Create `RecipeRepository` and `MockRecipeRepository`.

- [ ] Create `recipeRepositoryProvider` and update recipe UI to depend on the provider.

- [ ] Keep `core/mock/mock_data.dart` only as an implementation detail of mock repositories, then shrink it as data moves into feature-specific mock repositories.

- [ ] Verification gate:

```powershell
flutter analyze
flutter test
```

- [ ] Commit:

```powershell
git add lib test
git commit -m "refactor: isolate mock catalog and recipe data"
```

---

## Phase 5: Split Large Page Widgets

**Purpose:** Reduce production maintenance risk by turning very large screens into focused page + section widgets.

**Files:**
- Modify: `lib/features/checkout/presentation/pages/checkout_screen.dart`
- Create: `lib/features/checkout/presentation/widgets/checkout_address_section.dart`
- Create: `lib/features/checkout/presentation/widgets/checkout_payment_section.dart`
- Create: `lib/features/checkout/presentation/widgets/checkout_order_summary.dart`
- Modify: `lib/features/cart/presentation/pages/shopping_cart_screen.dart`
- Create: `lib/features/cart/presentation/widgets/cart_item_tile.dart`
- Create: `lib/features/cart/presentation/widgets/cart_summary_bar.dart`
- Modify: `lib/features/orders/presentation/pages/order_details_screen.dart`
- Create: `lib/features/orders/presentation/widgets/order_items_section.dart`
- Create: `lib/features/orders/presentation/widgets/order_status_timeline.dart`
- Modify: `lib/features/orders/presentation/pages/track_order_screen.dart`
- Create: `lib/features/orders/presentation/widgets/tracking_map_preview.dart`
- Create: `lib/features/orders/presentation/widgets/tracking_status_card.dart`

- [ ] Start with checkout because it is currently the largest screen and central to revenue flow.

- [ ] Move repeated checkout UI chunks into widgets without changing state ownership.

- [ ] Add widget tests for extracted checkout widgets where practical, using small fake model inputs.

- [ ] Split cart item rows and cart summary into dedicated widgets.

- [ ] Split order detail item list and status timeline into dedicated widgets.

- [ ] Split tracking screen display-only sections into dedicated widgets.

- [ ] After each screen split, run:

```powershell
flutter analyze
flutter test
```

- [ ] Commit after checkout/cart:

```powershell
git add lib test
git commit -m "refactor: split checkout and cart widgets"
```

- [ ] Commit after orders/tracking:

```powershell
git add lib test
git commit -m "refactor: split order detail and tracking widgets"
```

---

## Phase 6: Vendor Feature Cleanup

**Purpose:** Prepare vendor flows for real backend integration and reduce duplicate dashboard/product/profile UI logic.

**Files:**
- Create: `lib/features/vendors/domain/vendor_profile.dart`
- Create: `lib/features/vendors/domain/vendor_product.dart`
- Create: `lib/features/vendors/domain/vendor_order.dart`
- Create: `lib/features/vendors/data/vendor_repository.dart`
- Create: `lib/features/vendors/data/mock_vendor_repository.dart`
- Create: `lib/features/vendors/application/vendor_provider.dart`
- Modify: `lib/features/vendors/presentation/pages/vendor_dashboard_screen.dart`
- Modify: `lib/features/vendors/presentation/pages/vendor_orders_screen.dart`
- Modify: `lib/features/vendors/presentation/pages/vendor_products_screen.dart`
- Modify: `lib/features/vendors/presentation/pages/vendor_profile_screen.dart`
- Modify: `lib/features/vendors/presentation/pages/vendor_onboarding_screen.dart`
- Modify: `lib/features/vendors/presentation/pages/vendor_add_product_screen.dart`
- Add tests under `test/features/vendors/`

- [ ] Extract typed vendor profile, product, and order models.

- [ ] Create a vendor repository interface with methods for dashboard summary, product list, order list, and profile.

- [ ] Create a mock vendor repository using current hard-coded screen data.

- [ ] Update vendor screens to read from `vendorRepositoryProvider`.

- [ ] Split vendor onboarding into smaller form section widgets while keeping the same validation behavior.

- [ ] Split vendor dashboard summary cards into reusable widgets.

- [ ] Add tests for repository data shape and product/order mutations if current screens allow mutation.

- [ ] Verification gate:

```powershell
flutter analyze
flutter test
```

- [ ] Commit:

```powershell
git add lib test
git commit -m "refactor: isolate vendor domain and repository"
```

---

## Phase 7: Auth, Profile, And Preferences Boundary

**Purpose:** Make user identity and settings ready for Firebase Auth/Firestore without wiring production credentials yet.

**Files:**
- Create: `lib/features/auth/domain/app_user.dart`
- Create: `lib/features/auth/data/auth_repository.dart`
- Create: `lib/features/auth/data/mock_auth_repository.dart`
- Create: `lib/features/auth/application/auth_provider.dart`
- Create: `lib/features/profile/domain/customer_profile.dart`
- Create: `lib/features/profile/data/profile_repository.dart`
- Create: `lib/features/profile/data/mock_profile_repository.dart`
- Create: `lib/features/profile/application/profile_provider.dart`
- Modify: `lib/core/services/customer_preferences_service.dart`
- Modify: `lib/features/auth/presentation/pages/login_screen.dart`
- Modify: `lib/features/auth/presentation/pages/registration_screen.dart`
- Modify: `lib/features/profile/presentation/pages/profile_screen.dart`
- Modify: `lib/features/profile/presentation/pages/edit_profile_screen.dart`
- Modify: `lib/features/profile/presentation/pages/security_settings_screen.dart`
- Modify: `lib/features/profile/presentation/pages/set_delivery_address_screen.dart`

- [ ] Extract app user and customer profile models from screen-local state.

- [ ] Create auth repository methods for mock login, registration, logout, and current user.

- [ ] Create profile repository methods for reading/updating profile, delivery address, and security settings.

- [ ] Update auth screens to call repository methods instead of holding all behavior in page callbacks.

- [ ] Update profile screens to use profile providers.

- [ ] Keep production Firebase integration out of this phase; this phase only creates the boundary.

- [ ] Verification gate:

```powershell
flutter analyze
flutter test
```

- [ ] Commit:

```powershell
git add lib test
git commit -m "refactor: add auth and profile repositories"
```

---

## Phase 8: Production Configuration And Integration Stubs

**Purpose:** Make deployment-sensitive behavior explicit and prevent secrets from entering the repo.

**Files:**
- Create: `lib/core/config/app_environment.dart`
- Create: `lib/core/config/app_config.dart`
- Create: `.env.example` only if the team chooses dotenv later; otherwise document `--dart-define`
- Modify: `README.md`
- Modify: `.gitignore`
- Modify: `android/app/build.gradle` or current Android Gradle files only if needed for release config
- Modify: `lib/main.dart`

- [ ] Add `AppEnvironment` enum with development, staging, and production.

- [ ] Add `AppConfig` values loaded from `String.fromEnvironment`, including:
  - environment name;
  - Firebase enabled flag;
  - Paymongo public key placeholder;
  - API base URL placeholder.

- [ ] Document local run commands:

```powershell
flutter run --dart-define=APP_ENV=development
flutter build apk --release --dart-define=APP_ENV=production
flutter build appbundle --release --dart-define=APP_ENV=production
```

- [ ] Ensure `.gitignore` excludes local secret/config files such as Firebase generated local files and any future `.env`.

- [ ] Add a startup assertion or debug log that clearly identifies non-production builds without printing secrets.

- [ ] Verification gate:

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

- [ ] Commit:

```powershell
git add lib README.md .gitignore android test
git commit -m "chore: add production environment configuration"
```

---

## Phase 9: Final Production Hardening Pass

**Purpose:** Confirm the refactor did not change user-visible behavior and the app is ready for backend wiring or beta release.

**Files:**
- Modify: `README.md`
- Modify: `docs/ARCHITECTURE_REFACTOR.md`
- Modify: `docs/AI_HANDOFF.md`
- Modify: tests as needed

- [ ] Run full static and test verification:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

- [ ] Manually verify primary customer flows on Android or Chrome:
  - splash to onboarding/login/main;
  - market browse;
  - add item to cart;
  - cart quantity changes;
  - checkout;
  - order confirmation;
  - order history/details/tracking;
  - profile edit/address/security screens.

- [ ] Manually verify vendor flows:
  - vendor onboarding;
  - dashboard;
  - orders;
  - products;
  - add product;
  - earnings;
  - profile.

- [ ] Update `docs/AI_HANDOFF.md` with the new architecture, remaining mocked integrations, and next production steps.

- [ ] Update `README.md` so it reflects the current state after refactor:
  - architecture;
  - test commands;
  - production build commands;
  - configuration instructions;
  - what is still mocked.

- [ ] Commit:

```powershell
git add README.md docs test
git commit -m "docs: document production refactor architecture"
```

---

## Phase Order Summary

1. Baseline tests and architecture inventory.
2. Extract cart/order domain models.
3. Introduce Riverpod providers for services.
4. Centralize navigation.
5. Isolate mock market and recipe data behind repositories.
6. Split the largest customer-facing page widgets.
7. Clean up vendor domain and repository boundaries.
8. Add auth/profile repository boundaries.
9. Add production configuration and integration stubs.
10. Run final hardening, manual QA, and docs.

## Stop Conditions

Stop and reassess before continuing if any of these happen:

- `flutter analyze` is not green at the end of a phase.
- `flutter test` exposes a behavior change that is not intentionally part of the refactor.
- A screen rewrite requires changing visible UX or business rules.
- A production integration requires real credentials or secrets.
- A single phase touches more than six large page files before reaching a verification gate.

## Recommended First Execution

Start with Phase 0 only. It gives us a safety harness and leaves the app behavior untouched, which is the right first move before reshaping the codebase.
