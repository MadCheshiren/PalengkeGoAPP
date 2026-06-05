# PalengkeGo - AI Handoff

## Purpose

This handoff is for the next coding assistant continuing work on PalengkeGo.
It is meant to prevent regressions, avoid stale assumptions, and point the next agent to the most important remaining issues with concrete proposed fixes.

This app is no longer just a collection of mock screens.
Several core flows are already dynamic and connected:

- market browsing
- vendor profile
- add-to-cart flow
- shopping cart
- checkout
- order history

Do not replace those flows with static placeholders.

## Current App Status

The frontend has made significant progress.
The current codebase already has real local state for cart and orders, and the user has recently fixed the major cart web rendering blocker enough that the app can continue forward again.

Treat the following as active, working baselines:

- `lib/core/services/cart_service.dart`
- `lib/core/services/order_service.dart`
- `lib/features/cart/presentation/pages/shopping_cart_screen.dart`
- `lib/features/checkout/presentation/pages/checkout_screen.dart`
- `lib/features/orders/presentation/pages/order_history_screen.dart`
- `lib/features/vendors/presentation/pages/vendor_profile_screen.dart`
- `lib/features/vendors/presentation/widgets/add_to_cart_bottom_sheet.dart`
- `lib/features/home/presentation/pages/market_screen.dart`

## Critical Environment Note

On this machine, validation should use Flutter's bundled Dart.

Use:

```powershell
C:\Users\fragi\Music\flutter\bin\dart.bat analyze <files>
```

Do not trust plain:

```powershell
dart analyze
```

Reason:

- Flutter is installed at `C:\Users\fragi\Music\flutter\bin`
- a separate WinGet Dart install can shadow the correct analyzer
- that previously caused misleading failures and hangs

## What Is Dynamic Right Now

### Cart

- `globalCart` drives the cart state
- quantity changes are live
- selected state is live
- vendor grouping is live
- weight variants are treated as distinct items

### Checkout

- checkout reads selected cart items directly from `globalCart`
- checkout supports delivery and pickup
- checkout creates real local orders through `globalOrders.placeOrders(...)`

### Orders

- `globalOrders` stores order history
- tabs filter between all, active, completed, and cancelled
- completed orders can reorder items back into cart

## Do / Don't Rules

### Do

- read the exact file before editing it
- preserve working dynamic behavior when making Figma-alignment changes
- validate only the files you changed
- keep the app mobile-width constrained
- keep changes small and targeted when a flow already works
- prefer real state and shared services over screen-local fake data
- keep documenting major findings in this file and `issues.md`

### Do Not

- do not replace working flows with static demo content
- do not reintroduce old cart "safe mode" debug code unless actively debugging
- do not assume a visible web console warning is the root cause without confirming it
- do not hardcode new order details, addresses, or fees into UI screens if the data should come from the actual flow
- do not change the state architecture unless explicitly asked
- do not use plain `dart analyze` on this machine and then report those results as authoritative

## Current Audit Findings

These are the most important remaining code issues found in the latest audit.

### 1. Multi-vendor checkout only confirms the first created order

Files:

- `lib/features/checkout/presentation/pages/checkout_screen.dart`

Observed behavior:

- checkout groups selected items into one or more orders
- `globalOrders.placeOrders(...)` can return multiple `MarketOrder`s
- the confirmation flow only keeps `createdOrders.first`
- all selected cart items are still removed afterward

Why this matters:

- if a user checks out items from multiple vendors, several orders are created
- the user only sees confirmation details for the first one
- this creates a mismatch between what was placed and what was shown

Proposed solution:

- decide on one of these two paths and implement it consistently:

Path A:
- restrict checkout to one vendor at a time in the cart UI
- block cross-vendor checkout clearly in the frontend

Path B:
- allow cross-vendor checkout
- update confirmation to show a summary of all created orders, not only the first
- pass the full created order list into the confirmation screen or create a dedicated multi-order confirmation screen

Recommended path:

- Path B is more flexible, but Path A is faster if the intended product flow is one-vendor-per-checkout

### 2. Pickup orders are tracked as if they were delivery orders

Files:

- `lib/features/orders/presentation/pages/order_history_screen.dart`

Observed behavior:

- active orders go to `TrackOrderScreen`
- `isPickup` is hardcoded to `false`
- the order object already contains enough information to know whether it is a pickup order

Why this matters:

- pickup and delivery are different user experiences
- the wrong tracking mode can show the wrong labels, ETA assumptions, or next actions

Proposed solution:

- pass `order.isPickup` instead of hardcoding `false`
- audit `TrackOrderScreen` to confirm it correctly branches for pickup and delivery
- test at least one delivery order and one pickup order end-to-end from checkout to tracking

### 3. Cart address picker is visually wired but functionally ignored

Files:

- `lib/features/cart/presentation/pages/shopping_cart_screen.dart`

Observed behavior:

- the address row opens `SetDeliveryAddressScreen`
- the result comes back
- the `setState` callback is effectively empty
- the displayed address remains hardcoded

Why this matters:

- the user is given an interactive address selection flow that currently does not persist in the cart UI
- that makes the app feel less reliable even though the interaction exists

Proposed solution:

- introduce a small shared delivery-address state holder
- update both cart and checkout to read from the same source
- at minimum, store:
  - recipient name
  - phone
  - address line
- if you do not want a new service yet, at least keep the chosen address in the cart screen and pass it forward to checkout

Recommended implementation order:

1. create a lightweight local/shared address model
2. update the cart subtitle to display the chosen address
3. update checkout delivery card to use the same chosen address

### 4. Order details still use hardcoded/fabricated data

Files:

- `lib/features/orders/presentation/pages/order_history_screen.dart`

Observed behavior:

- order details are built through a map
- several fields are fake or fixed:
  - ETA
  - delivery address
  - vendor location
  - delivery fee
  - service fee

Why this matters:

- the rest of the app has moved toward dynamic flows
- fake details make the order screens drift away from the actual user path
- future backend or Firebase migration gets harder when fake UI contracts stay in place

Proposed solution:

- stop constructing order details as a fake map inside the screen
- pass the real `MarketOrder` or a typed view model into `OrderDetailsScreen`
- derive details from the actual order data
- if certain fields truly do not exist yet:
  - mark them as unavailable
  - or add them properly to the local order model

Good rule:

- prefer "not available yet" over fake but plausible values

### 5. There is still visible text encoding corruption in multiple screens

Files:

- `lib/features/cart/presentation/pages/shopping_cart_screen.dart`
- `lib/features/checkout/presentation/pages/checkout_screen.dart`
- `lib/features/orders/presentation/pages/order_history_screen.dart`

Observed examples:

- `â‚±`
- `â€¢`
- vendor names like `Sbâ€™s`

Why this matters:

- this is user-visible
- it makes polished screens feel broken
- it can spread if copied into more widgets

Proposed solution:

- normalize all affected strings to plain ASCII-safe text where possible
- replace malformed peso strings with either:
  - `PHP ...`
  - or a properly encoded peso sign if the file encoding is confirmed safe
- replace malformed bullets with simple separators like ` | ` if needed

Recommended rule for this repo:

- default to ASCII in source files unless there is a strong reason not to

### 6. Minor analyzer cleanup still remains

Observed analyzer issues from the targeted audit:

- `shopping_cart_screen.dart` still has deprecated `withOpacity(...)`
- `order_history_screen.dart` has an unused import

Proposed solution:

- replace `withOpacity(...)` with `withValues(alpha: ...)`
- remove unused imports as part of normal cleanup

## Backend vs Frontend Clarification

Most of the issues in the latest audit are not backend problems.

They are primarily:

- frontend rendering or UX issues
- client-side state propagation issues
- screen-to-screen data flow issues
- local model design issues

Specifically:

- multi-vendor confirmation mismatch: frontend / local flow issue
- pickup tracking using delivery mode: frontend logic issue
- cart address not updating: frontend state issue
- hardcoded order detail values: frontend modeling issue
- encoding corruption: frontend source/data formatting issue

These may later benefit from backend support, but they do not require a backend to fix correctly right now.

The only sense in which they touch "backend" is that the current local models should be shaped in a way that will be easy to connect to Firebase or a real API later.

## Recommended Next Work Order

If continuing from here, the next agent should work in this order:

1. Fix pickup tracking mode in order history
2. Fix the cart address flow so the chosen address actually persists
3. Fix the multi-vendor checkout confirmation behavior
4. Replace hardcoded order detail values with typed real order data
5. Sweep encoding corruption across cart, checkout, and orders
6. Do a small analyzer cleanup pass

## Validation Commands

Examples:

```powershell
C:\Users\fragi\Music\flutter\bin\dart.bat analyze .\lib\features\cart\presentation\pages\shopping_cart_screen.dart
C:\Users\fragi\Music\flutter\bin\dart.bat analyze .\lib\features\checkout\presentation\pages\checkout_screen.dart
C:\Users\fragi\Music\flutter\bin\dart.bat analyze .\lib\features\orders\presentation\pages\order_history_screen.dart
```

## Final Bottom Line

The app has moved out of the mockup phase.
The remaining important work is mostly about making the dynamic flows truthful and consistent, not just prettier.

The next agent should assume:

- cart/order/checkout flows are already real enough to preserve
- the most important remaining bugs are frontend and state-flow issues
- broad rewrites are risky now
- targeted fixes with validation are the right approach
