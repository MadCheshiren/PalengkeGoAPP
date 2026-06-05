# PalengkeGo Refactor Handoff

Last updated: 2026-05-25, expanded low-usage handoff after checkout splitting pass

This handoff is for the next developer or agent continuing the frontend production refactor. The app is still frontend-only: no backend, Firebase, Paymongo, persistence, or real API integration has been added.

The goal of the refactor is to make the prototype easier to turn into a production app without changing the visible design too much. Most work so far has separated data shape, state access, navigation, and reusable UI pieces so future backend work has clear places to connect.

## Current Status

The app should still look and behave like the original frontend prototype. The refactor has focused on structure, safety, and production readiness without intentionally changing UI flows.

Frontend refactor progress is roughly in the middle-to-late structure phase. The safest mental model:

- Safety net exists and currently passes.
- Cart/order domain extraction is done.
- Riverpod provider entry points exist for cart, orders, market, and recipes.
- Central app routing exists for main app/auth/checkout/order flows.
- Market and recipe mock data are behind repository boundaries.
- Cart, checkout, tracking, and order details screens have been partially or heavily split.
- Vendor, auth/profile, production config, and final hardening are still unfinished.

Latest verified checkpoint before this handoff:

```powershell
flutter analyze
flutter test
```

Expected result:

```text
flutter analyze: No issues found
flutter test: 22 tests passed
```

If continuing later, run both commands first before making new edits. The known-good checkpoint was recorded after extracting checkout delivery/pickup widgets and reducing `checkout_screen.dart` to about 328 lines.

## What Has Been Completed

### 1. Refactor Planning And Docs

Created:

- `docs/ARCHITECTURE_REFACTOR.md`
- `docs/superpowers/plans/2026-05-10-production-refactor.md`
- `docs/REFACTOR_HANDOFF.md`

`.gitignore` intentionally ignores most `docs/`, but allows these refactor docs through.

Important `.gitignore` detail:

- Keep most markdown files in `docs/` ignored if the team does not need them.
- Do not ignore the refactor handoff/planning docs listed above.
- The team needs these refactor docs because they explain how to continue safely.

### 2. Safety Tests

Added:

- `test/services/cart_service_test.dart`
- `test/services/order_service_test.dart`
- `test/features/cart/application/cart_provider_test.dart`
- `test/features/orders/application/order_provider_test.dart`
- `test/features/market/data/mock_market_repository_test.dart`
- `test/features/recipes/data/mock_recipe_repository_test.dart`

Updated:

- `test/widget_test.dart`

The smoke test now pumps through the splash screen timer so the test does not fail with a pending timer.

### 3. Cart And Order Domain Models

Created:

- `lib/features/cart/domain/cart_item.dart`
- `lib/features/orders/domain/market_order.dart`
- `lib/features/orders/domain/order_line_item.dart`
- `lib/features/orders/domain/order_status.dart`

Important changes:

- `CartItem` moved out of `cart_service.dart`.
- `CartItem` is immutable and has `copyWith`.
- `MarketOrder` and `OrderLineItem` moved out of `order_service.dart`.
- Order status is now an `OrderStatus` enum, not raw strings.
- `MarketOrder.statusLabel` preserves display text like `Pending`, `Confirmed`, `Completed`, and `Cancelled`.

### 4. Riverpod Providers

Created:

- `lib/features/cart/application/cart_provider.dart`
- `lib/features/orders/application/order_provider.dart`

The providers currently wrap the existing shared in-memory services:

- `globalCart`
- `globalOrders`

This is a transition step. Screens now mostly ask Riverpod for services instead of importing globals directly. The globals should eventually disappear after service lifecycle and state ownership are fully provider-driven.

Beginner explanation:

Riverpod is the app's "shared state access system." Instead of every screen creating or importing its own cart/order object, the screen asks Riverpod for the current cart/order service. That makes it easier later to replace mock in-memory data with real backend data because screens will already depend on providers, not random globals.

Why this is good here:

- It gives one predictable place to find app state.
- It reduces hidden dependencies between screens.
- It makes tests easier because providers can be overridden.
- It prepares the app for repositories, controllers, and backend adapters later.
- It fits Flutter well and does not require a backend to start using it.

Current limitation:

The providers still expose existing `ChangeNotifier` services through plain `Provider` because this project is on Riverpod v3 and `ChangeNotifierProvider` was not available in the installed API. This is acceptable for the transition phase. A future phase can replace `ChangeNotifier` services with `Notifier`, `AsyncNotifier`, or repository-backed controllers.

### 5. Central Navigation

Created:

- `lib/core/navigation/app_routes.dart`
- `lib/core/navigation/app_router.dart`

Updated:

- `lib/main.dart`

`MaterialApp` now uses:

```dart
initialRoute: AppRoutes.splash,
onGenerateRoute: AppRouter.onGenerateRoute,
```

Migrated key routes:

- splash
- onboarding
- login
- registration
- main
- cart
- checkout
- payment methods
- add credit card
- order confirmation
- track order
- set delivery address

Some feature-specific navigation still uses direct `MaterialPageRoute`, especially market/profile/recipes/vendor flows. That can be migrated gradually.

Do not try to migrate every route at once. Central routing is valuable, but route migration can touch many screens. Prefer one feature group per pass.

### 6. Mock Data Boundaries

Market:

- `lib/features/market/domain/market_vendor.dart`
- `lib/features/market/domain/market_product.dart`
- `lib/features/market/data/market_repository.dart`
- `lib/features/market/data/mock_market_repository.dart`
- `lib/features/market/application/market_provider.dart`

Recipes:

- `lib/features/recipes/domain/recipe.dart`
- `lib/features/recipes/data/recipe_repository.dart`
- `lib/features/recipes/data/mock_recipe_repository.dart`
- `lib/features/recipes/application/recipe_provider.dart`

Screens updated:

- `lib/features/home/presentation/pages/market_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_profile_screen.dart`
- `lib/features/recipes/presentation/pages/recipes_screen.dart`

Direct usage of `MockDataService` should now be isolated to `MockMarketRepository`.

This was an important production-readiness step. A future backend can replace `MockMarketRepository` or `MockRecipeRepository` without making every screen know where the data came from.

### 7. Large Screen Splitting

Cart:

- `lib/features/cart/presentation/widgets/cart_item_card.dart`
- `lib/features/cart/presentation/widgets/cart_summary_bar.dart`

Checkout:

- `lib/features/checkout/presentation/widgets/checkout_footer.dart`
- `lib/features/checkout/presentation/widgets/checkout_order_item.dart`
- `lib/features/checkout/presentation/widgets/checkout_summary_row.dart`
- `lib/features/checkout/presentation/widgets/checkout_method_toggle.dart`
- `lib/features/checkout/presentation/widgets/checkout_section_title.dart`
- `lib/features/checkout/presentation/widgets/checkout_delivery_cards.dart`
- `lib/features/checkout/presentation/widgets/checkout_pickup_cards.dart`

Orders:

- `lib/features/orders/presentation/widgets/tracking_map_preview.dart`
- `lib/features/orders/presentation/widgets/tracking_contact_cards.dart`
- `lib/features/orders/presentation/widgets/order_details_timeline.dart`
- `lib/features/orders/presentation/widgets/order_details_items_list.dart`
- `lib/features/orders/presentation/widgets/order_summary_row.dart`

Approximate reductions:

- `shopping_cart_screen.dart`: 567 lines to 275 lines
- `track_order_screen.dart`: 799 lines to 410 lines
- `order_details_screen.dart`: 750 lines to 569 lines
- `checkout_screen.dart`: 883 lines to about 328 lines

The current checkout page now mainly owns state and flow:

- selected delivery method
- selected cart/order data
- payment method navigation
- order placement
- navigation to order confirmation

Most checkout display sections have been extracted into widgets. Keep this pattern: page owns orchestration, widgets render UI.

Important checkout boundary:

- Keep navigation, snackbar behavior, selected delivery method, selected payment method, and order placement in the page for now.
- Keep extracted checkout widgets mostly display-only.
- Do not move order placement into a widget.
- Only move order placement into an application controller after an order repository/provider boundary is ready.

This matters because checkout is a critical user flow. UI cleanup is safe; moving business flow too early can create harder bugs.

## Current Architecture Direction

Target feature shape:

```text
lib/features/<feature>/
  application/   Riverpod providers and controllers
  data/          repositories and mock/backend adapters
  domain/        typed models and pure business rules
  presentation/  pages and widgets
```

Current code is moving toward this, but not every feature has all folders yet.

What each folder means:

- `domain/`: plain data models and business concepts, with little or no Flutter UI code.
- `data/`: repositories and adapters. Today these are mock repositories; later this is where APIs/Firebase can plug in.
- `application/`: Riverpod providers/controllers that connect UI to domain/data.
- `presentation/`: screens and widgets.

Try to keep that direction. If a screen has hardcoded data, move the data behind `data/` before adding backend code.

## Important Current Constraints

- Do not add real backend integration yet unless explicitly requested.
- Do not add Firebase, Paymongo, auth persistence, or environment secrets yet.
- Preserve visible UI and user flows during refactors.
- Prefer small, verified slices.
- Run `flutter analyze` and `flutter test` after each slice.
- There are many unstaged/uncommitted changes. Do not revert anything unless the user explicitly requests it.
- Avoid broad auto-formatting across the whole app because some existing files have peso-symbol/bullet encoding artifacts.
- If committing, remember many newly created files are untracked and must be staged intentionally.
- Keep current frontend behavior first. The point is to make the code easier to productionize, not redesign the app during this pass.

Current working-tree warning:

This handoff was written while the refactor branch/worktree still had many modified and untracked files. Treat the working tree as intentionally dirty. Use `git status --short --untracked-files=all` before deciding what to stage.

## Remaining Work

Short version of what remains:

1. Finish splitting the remaining large screens.
2. Add vendor repository/provider boundaries.
3. Add auth/profile mock repository/provider boundaries.
4. Finish route migration gradually.
5. Add production config placeholders.
6. Run final build/manual QA hardening.

### Phase A: Continue Large Screen Splitting

Highest value targets now:

- `lib/features/orders/presentation/pages/order_history_screen.dart`
- `lib/features/recipes/presentation/pages/recipe_details_screen.dart`
- `lib/features/checkout/presentation/pages/order_confirmation_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_onboarding_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_profile_screen.dart`

Checkout status:

`checkout_screen.dart` is now much smaller. Do not aggressively split it further unless there is a clear target. The remaining useful extraction would be:

- payment method card, but it currently owns async navigation/snackbar behavior;
- order placement helper/controller, but only after a repository/provider boundary is ready.

For the next large-screen pass, prefer `order_history_screen.dart` or `recipe_details_screen.dart`.

Recommended `order_history_screen.dart` extractions:

```text
lib/features/orders/presentation/widgets/order_history_tab_row.dart
lib/features/orders/presentation/widgets/order_history_card.dart
lib/features/orders/presentation/widgets/order_history_empty_state.dart
```

Recommended `recipe_details_screen.dart` extractions:

```text
lib/features/recipes/presentation/widgets/recipe_hero_card.dart
lib/features/recipes/presentation/widgets/recipe_stats_row.dart
lib/features/recipes/presentation/widgets/recipe_ingredients_list.dart
lib/features/recipes/presentation/widgets/recipe_steps_list.dart
```

Keep screen state in the page first, especially favorite state and checked ingredients.

Why this phase is useful:

Large pages are risky because UI, state, navigation, and data are all mixed together. Splitting display widgets out makes the page easier to read, easier to test, and easier to connect to backend data later. The key is to extract UI sections first, while keeping the behavior owner in the page until the application/data layers are ready.

### Phase B: Vendor Cleanup

Large files still needing attention:

- `lib/features/vendors/presentation/pages/vendor_onboarding_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_profile_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_dashboard_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_add_product_screen.dart`
- `lib/features/vendors/presentation/widgets/add_to_cart_bottom_sheet.dart`

Recommended structure:

```text
lib/features/vendors/domain/vendor_profile.dart
lib/features/vendors/domain/vendor_product.dart
lib/features/vendors/domain/vendor_order.dart
lib/features/vendors/data/vendor_repository.dart
lib/features/vendors/data/mock_vendor_repository.dart
lib/features/vendors/application/vendor_provider.dart
```

Do not connect a backend here yet. Move hardcoded vendor data behind a mock repository first.

Recommended vendor approach:

1. Create typed vendor domain models first.
2. Create a `VendorRepository` interface.
3. Create `MockVendorRepository` using the same data the UI already shows.
4. Add `vendor_provider.dart`.
5. Migrate one vendor screen only.
6. Verify.

This prevents a huge risky rewrite of all vendor screens at once.

### Phase C: Auth/Profile Boundary

Current auth/profile screens are still mostly page-local UI and mock behavior.

Recommended structure:

```text
lib/features/auth/domain/app_user.dart
lib/features/auth/data/auth_repository.dart
lib/features/auth/data/mock_auth_repository.dart
lib/features/auth/application/auth_provider.dart

lib/features/profile/domain/customer_profile.dart
lib/features/profile/data/profile_repository.dart
lib/features/profile/data/mock_profile_repository.dart
lib/features/profile/application/profile_provider.dart
```

Keep Firebase out of this phase. This should only prepare boundaries.

Recommended auth/profile approach:

- Keep login/register behavior mocked.
- Add typed user/profile models.
- Add mock repositories.
- Make screens read/write through providers.
- Do not add secrets, tokens, or real session persistence yet.

### Phase D: Production Configuration

After boundaries are cleaner, add:

```text
lib/core/config/app_environment.dart
lib/core/config/app_config.dart
```

Use `--dart-define` placeholders for:

- app environment
- API base URL
- Firebase enabled flag
- Paymongo public key placeholder

Do not commit secrets.

This phase should be done late because configuration is only useful once the app has stable boundaries. Adding config too early can create unused scaffolding.

### Phase E: Final Hardening

Run:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Then manually test:

- splash to onboarding/auth/main
- market browse
- vendor profile
- add to cart
- cart select/quantity/delete
- checkout delivery and pickup
- payment method screen
- order confirmation
- order history/details/tracking
- recipes list/details
- vendor screens

## Suggested Next Slice

The next best small slice is one of these:

Option 1, continue order screen cleanup:

1. Extract `order_history_screen.dart` card/tab/empty-state widgets.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Stop and report.

Option 2, start recipe details cleanup:

1. Extract recipe details ingredients and procedure widgets.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Stop and report.

Option 3, start vendor cleanup:

1. Add vendor domain/repository/provider.
2. Keep data mocked.
3. Migrate only one vendor screen first.
4. Run `flutter analyze`.
5. Run `flutter test`.

If usage/time is low, choose Option 1. It is the safest next step because it is mostly display extraction.

If usage/time is medium, choose Option 3. Vendor cleanup is more strategically important for production because vendor screens are still a large mock-data area.

Suggested order history files:

```text
lib/features/orders/presentation/widgets/order_history_card.dart
lib/features/orders/presentation/widgets/order_history_tab_row.dart
lib/features/orders/presentation/widgets/order_history_empty_state.dart
```

Avoid moving order mutation/reorder logic until display widgets are split cleanly.

Suggested exact next command sequence for a new developer/agent:

```powershell
git status --short --untracked-files=all
flutter analyze
flutter test
```

Then choose only one slice. Do not combine order history, recipe details, and vendor cleanup in the same pass unless there is a lot of time and test budget.

## Latest Phase Notes

The last completed phase extracted most of `checkout_screen.dart` into presentation widgets:

- method toggle
- section title
- delivery address/map cards
- pickup header/card/ready-time card
- order item row
- summary row
- footer

The page remained behavior owner. This is important because checkout is revenue-flow critical. Do not move `placeOrders`, `removeSelectedItems`, or navigation to order confirmation casually.

After this phase:

```text
flutter analyze: No issues found
flutter test: 22 tests passed
```

Files from the latest checkout split:

```text
lib/features/checkout/presentation/widgets/checkout_method_toggle.dart
lib/features/checkout/presentation/widgets/checkout_section_title.dart
lib/features/checkout/presentation/widgets/checkout_delivery_cards.dart
lib/features/checkout/presentation/widgets/checkout_pickup_cards.dart
```

These join the earlier checkout widgets:

```text
lib/features/checkout/presentation/widgets/checkout_footer.dart
lib/features/checkout/presentation/widgets/checkout_order_item.dart
lib/features/checkout/presentation/widgets/checkout_summary_row.dart
```

The intended pattern is now clear:

- The page owns selected values and side effects.
- Widgets receive data and callbacks.
- Widgets should not import cart/order globals.
- Widgets should not perform navigation unless they are explicitly designed as navigation controls.

## Current Risk Notes

- The app still uses in-memory singleton services behind providers.
- Some screens still pass `Map<String, dynamic>` payloads, especially order details and recipe details.
- Some text in existing files has mojibake/encoding artifacts for peso symbols and bullets. Avoid broad formatting churn; fix only touched lines when necessary.
- Many files are modified and many new files are untracked. Stage carefully if committing.
- `pubspec.lock` is ignored by `.gitignore`; this was pre-existing.
- Navigation is partially centralized, not fully centralized.
- Vendor and auth/profile flows are still prototype-style.
- There is still no persistence, so cart/orders reset with app lifecycle as before.
- Passing tests means the safety net passed. It does not mean the full production refactor is complete.

Practical interpretation:

The app is healthier and easier to continue, but it is not production-ready yet. It is in a strong frontend-refactor checkpoint: tests are green, several risky globals are now behind provider entry points, and several large pages are smaller. Backend readiness still needs vendor/auth/profile boundaries and production config.

## Good Commit Strategy

Because this is a large refactor, commit in groups if possible:

1. safety tests and docs
2. domain model extraction
3. providers
4. router
5. market/recipe repositories
6. cart/checkout/order widget splits
7. updated handoff docs

Before each commit:

```powershell
flutter analyze
flutter test
git status --short --untracked-files=all
```

Do not make one giant commit if the team wants reviewable history.

If time is very low, commit at least the docs and the passing refactor checkpoint together so the team does not lose context.

## Best Next Decision

Recommended next phase from this exact point:

Start with `order_history_screen.dart` display extraction if the developer has low time/usage. Start vendor repository/provider cleanup if the developer has enough time for a more structural phase.

My recommendation:

1. Low usage: split `order_history_screen.dart`.
2. Medium usage: start vendor domain/repository/provider.
3. High usage: vendor cleanup, then one vendor screen migration, then verify.

Do not start backend integration yet. The frontend still needs cleaner boundaries first.
