# PalengkeGo — Ultimate Implementation Plan (merged audit)

> **Date:** 2026-08-06
> **Source:** Three independent audits, cross-verified against the repo on 2026-08-06 —
> 1. **DeepSeek V4 Flash** (session audit, file-by-file verification)
> 2. **GPT Terra** (`docs/AUDIT_IMPLEMENTATION_HANDOFF_2026-07-26.md`)
> 3. **Qwen 3.8 Max** (2026-08-06 audit)
>
> For an implementing agent: work through the phases in order. Make **one focused change at a time**, run the named checks, and stop if a check exposes an unrelated regression. Do not rewrite broad areas during a narrow task.
>
> **Current baseline (measured 2026-08-06):** `flutter analyze` 0 issues · 221 lib files / ~41,800 LOC · 37 test files / 2,838 LOC · coverage 3,419/8,296 ≈ 41% · 22 files > 500 LOC · ~1,750 hardcoded `Color(0xFF…)` literals · 17/17 direct deps outdated · 4 placeholder tests.

---

## Non-Negotiable Product Decisions

These are intentional current behaviors. Do **not** change them unless the project owner explicitly asks.

1. Customers can browse the market before signing in. Require login only for protected actions (add to cart, checkout, saved data, ratings, vendor operations).
2. New customer orders start in `pending` and wait for vendor acceptance. Do not restore an automatic `confirmed` status for delivery orders.
3. Per-kilogram products must use kilogram divisions in the picker, including fruit. Do not infer piece units from category or name.
4. `UnitHelper.getUnitString` stays `kg` for the current project requirement.
5. Deals only appear when at least one active discounted product exists. No placeholder deals.
6. The floating tracker and full order-details tracker use **one** consistent status model — no third tracker implementation.
7. Existing mock repositories are useful for frontend/dev/tests. Do not delete them; introduce environment-based repository selection.
8. Never commit `.env`, service-role keys, payment secret keys, keystores, Firebase private config, build dirs, or generated local history.

**Auth-related decisions (flagged, not yet owner-approved):**
- `loginAs(UserRole)` must never silently grant vendor without credentials in non-debug builds.
- Mock default mode currently auto-logs-in a customer and maps `'v1'`/`'stall holder-001'` as vendor IDs — keep for demo, but gate behind `kDebugMode`-equivalent dev config when the real backend is on.

---

## Part 1 — Qwen 3.8 Max: claim-by-claim verification

Qwen's audit scored **~90% accurate** on checkable claims. Every metric was re-measured; every file:line re-checked.

| Qwen claim | Measured | Verdict |
|---|---|---|
| `flutter analyze`: 0 issues | 0 issues (171s, today) | ✅ |
| 221 lib files / 41,784 LOC | 221 files / ~41,790 lines | ✅ |
| 37 test files / 2,838 LOC | 37 files / 2,838 lines | ✅ |
| Coverage 3,419/8,296 ≈ 41% | Matches `coverage/lcov.info` | ✅ (stale artifact, no gate) |
| 22 files > 500 LOC | 22 exactly (500s×10, 600s×5, 700s×7) | ✅ |
| Top god files 783 / 756 / 742 | registration_screen, vendor_add_product, vendor_order_details | ✅ exact |
| 1,724 hardcoded `Color(0xFF…)` | 1,764 matches | ✅ (±2% tolerance) |
| 46 TODO/FIXME/HACK | 47 | ✅ |
| 19 print/debugPrint | 19 | ✅ |
| Only baseline flutter_lints | `analysis_options.yaml` = `flutter_lints` + 2 commented rules | ✅ |
| 17/26 deps outdated | **17/17 direct deps outdated** | ⚠️ denominator wrong |
| riverpod 3.3→3.4 | 3.3.1 → 3.4.2 | ✅ |
| firebase_core 4.11→4.13 | 4.11.0 → 4.13.0 | ✅ |
| share_plus 12→13 | 12.0.2 → 13.3.0 | ⚠️ (unused — delete, not upgrade) |
| google_sign_in 6→7 | 6.3.0 → 7.2.0 | ✅ |
| geolocator 13→14 | 13.0.4 → 14.0.3 | ✅ |
| ~11 mock repos in lib | **10** `Mock*Repository` classes | ⚠️ off by one |
| Firebase disabled in release (`main.dart`) | `main.dart:23` `kReleaseMode ? Future.value() : …` | ✅ |
| `.env` bundled as asset (`pubspec.yaml`) | `.env` listed under `assets:` | ✅ |
| Two config systems coexist | `AppConfig` (dart-defines) + `SupabaseService` (dotenv) | ✅ |
| No `firestore.rules`/`storage.rules`/`firebase.json`/functions | Confirmed (only plugin symlink example) | ✅ |
| `ResponsiveWrapper` minWidth 450 | `responsive_wrapper.dart:14` `minWidth:450, maxWidth:450` | ✅ |
| dart-define config landed since 07-26 audit; P0 security untouched | Confirmed | ✅ |

### Qwen's strengths (unique value)
- **Live dependency lag against pub.dev** — the only audit that networked version deltas.
- **Delta insight** — compared the 07-26 audit to current state and tracked progress.
- **i18n/l10n absence** flagged — no other audit mentioned it.
- **No coverage enforcement gate, no release CI path** as distinct P2 items.
- Proposed job-safety lints (`use_build_context_synchronously`, `prefer_const_*`).

### Qwen's misses (corrected here)
1. **The build-blocker:** 12 untracked `.freezed.dart`/`.g.dart` files + no `build_runner` in CI ⇒ fresh clone / CI cannot compile. Qwen rated CI "Good."
2. **Silent order failure** on checkout (release builds swallow the error).
3. **`loginAs(UserRole.vendor)` credential-free role switch** in 3 non-debug call sites.
4. **Unused deps** — and it recommends *upgrading* `share_plus`, which is dead weight; correct action is remove.
5. **Performance score 5/10 is too harsh** — lazy lists everywhere, const-heavy, cached images, no blocking work in `build()`. Real score ≈ 6.5/10.

---

## Part 2 — Three-way consensus map

| Finding | DeepSeek | GPT Terra | Qwen | Confidence |
|---|:--:|:--:|:--:|---|
| Backend never runs in release; app is mock-only | ✅ | ✅ | ✅ | **CONFIRMED·P0** |
| No firestore/storage rules, no functions | ✅ | ✅ | ✅ | **CONFIRMED·P0** |
| Dual config system | ⚠️ | ✅ | ✅ | CONFIRMED·P0 |
| 450px wrapper breaks 360/390dp phones | ✅ | ✅ | ✅ | CONFIRMED·P1 |
| 22 god files (top-3 identical) | ✅ | ✅ | ✅ | CONFIRMED·P1 |
| Theme bypass (~1.7K color literals) | ✅ | ✅ | ✅ | CONFIRMED·P1 |
| 4 placeholder `expect(true,true)` tests | ✅ | ✅ | ✅ | CONFIRMED·P1 |
| **And Always-mock brokers**: cart/market/recipes mock-only | ✅ | ✅ | ✅ | CONFIRMED·P1 |
| **Untracked codegen files break fresh-clone/CI build** | ✅ | ❌ | ❌ | **CONFIRMED·1 — missed by the other two** |
| loginAs vendor bypass | ✅ | ⚠️ partial | ❌ | CONFIRMED·1 |
| Silent release order failure | ✅ | ⚠️ partial | ❌ | CONFIRMED·1 |
| kg stock math `quantity.ceil()` | ❌ | ✅ | ❌ | CONFIRMED·2 |
| Sales reports hardcode July 2026 | ❌ | ✅ | ❌ | CONFIRMED·2 |
| Deps outdated / some unused | ⚠️ | ⚠️ | ✅ | CONFIRMED·3 (Qwen best) |
| Supabase reserved for recipes | ✅ | ✅ | ⚠️ (implicit) | CONFIRMED · open decision |

**Read:** 12 findings agreed by all 3; 2 agreed by 2; 7 unique to one audit — and the 4 most immediately damaging items were each caught by exactly one audit. All three were needed to see 100%.

---

## Part 3 — Ultimate scorecard

| Area | Score | Combined evidence |
|---|---|---|
| Analyze / lint | 7.5/10 | 0 issues, but baseline-only lint set |
| Size / maintainability | 3.5/10 | 22 god files, ~1.7K hardcoded colors, 7+ duplicated utility classes |
| Architecture | 6/10 | Feature-first + Riverpod + repository interfaces; dual backend + mock-first not finalized |
| Security | 2/10 | No rules; no trusted writes; client role switch; PII plaintext |
| Backend readiness | 2/10 | No `firebase.json`, no functions, no integration tests |
| Testing | 4/10 | 41% stale coverage, 4 placeholders, zero emulator/integration |
| Performance | 6.5/10 | Lazy lists + cached images; 8 uncached Image.network, timer carousel, no offline |
| Responsive / a11y / i18n | 3/10 | minWidth 450, no semantics tests, zero l10n |
| CI / CD | 5/10 | analyze/test/build/secret-scan; breaks on fresh checkout; no coverage gate, no release path |
| Release readiness | 2/10 | Firebase off in release; PayMongo placeholder domain; debug-signing fallback |

---

## Phase 4/5 — the ultimate plan

The phases are ordered for **bang-per-buck** and safety: unblock the build, close security, fix correctness, then quality. Each task lists files, steps, verification, and acceptance criteria. Global Definition of Done for every task:

> `flutter analyze` = 0 issues · `flutter test` = green · `git diff --check` clean · no new `catch (_) {}` · no new `setState` in extracted widgets · no behavior change unless stated.

### Phase 0 — Protect the current worktree (do first, ~90 min)

**Goal:** Make the mid-migration tree reviewable before any further behavior changes.

- **Task 0.1** — Group the large working tree into logical commits (`git status --short` → review). Do **not** add another unrelated feature to this branch.
- **Task 0.2** — `git diff --check`; remove trailing whitespace / extra final blank lines.
- **Task 0.3** — Ensure `.gitignore` covers: `android/build/`, `compiled_history.md` (1.8 MB — never stage), local export dirs (`exports/`, `downloads/`).
- **Task 0.4** — Decide if this doc gets versioned; `docs/*` is ignored — use `git add -f docs/ULTIMATE_IMPLEMENTATION_PLAN.md` only if the team wants it tracked, and add it to the `.gitignore` exception list.
- **Task 0.5** — Read `docs/AUDIT_IMPLEMENTATION_HANDOFF_2026-07-26.md` flags; the two order-detail screens and the notification screens are near-duplicates — noted here for Phase 6.

**Verify:** `git diff --check` clean; `git status --short` shows only intended files.
**Do Not:** `git reset --hard`; `git checkout -- .`; delete untracked files broadly; commit `compiled_history.md` or `android/build/reports`.

### Phase 1 — Fix the build for fresh clones & CI (P0, ~1 hr) 🔴 the blocker

**Problem:** 12 generated `.freezed.dart` / `.g.dart` files are untracked; CI has no `build_runner` step. Fresh clone and current CI do not compile.

**Decision (pick one — recommended: commit generated files):**
- **T1.1 (commit path)** `git add` the generated files:
  - `lib/core/domain/product.freezed.dart`, `product.g.dart`
  - `lib/features/cart/domain/cart_item.{freezed,g}.dart`
  - `lib/features/orders/domain/market_order.{freezed,g}.dart`, `order_line_item.{freezed,g}.dart`
  - `lib/features/vendors/domain/day_schedule.{freezed,g}.dart`, `delivery_settings.{freezed,g}.dart`, `vendor_stall.{freezed,g}.dart`
  - AC: `git ls-files | grep -E 'freezed|\.g\.dart'` lists 14 files; `git status` zero `??` generated files.
- **T1.2** `dart run build_runner build --delete-conflicting-outputs` locally → AC: no changed files remain.
- **（CI path, alternative)** Add to `.github/workflows/flutter-ci.yml` between pub get and analyze: `dart run build_runner build --delete-conflicting-outputs`; add `*.freezed.dart` / `*.g.dart` to `.gitignore`.
- **T1.3** Run CI on a clean checkout. AC: analyze → test → build apk all green.

### Phase 2 — Release backend initialization (P0, half day)

**Problem:** `main.dart:23` skips Firebase init in `kReleaseMode`; release build can select Firebase repositories while the SDK is never initialized. Config is split between `.env` (dotenv) and `AppConfig` (dart-defines).

**Files:** `lib/main.dart`, `lib/core/infrastructure/firebase_service.dart`, `lib/core/infrastructure/supabase_service.dart`, `lib/core/config/app_config.dart`, `pubspec.yaml`, `test/core/config/app_config_test.dart` (new).

- **T2.1** Write 3 config tests: local mock mode, Firebase-enabled mode (debug+release), missing-config startup error.
- **T2.2** Make `AppConfig` the single source of truth via `--dart-define`. Decouple dotenv: decide whether Supabase reads dart-define too — kill the two-source split.
- **T2.3** Init Firebase only when `config.firebaseEnabled`, regardless of debug/release. Use `DefaultFirebaseOptions.currentPlatform` (run **`flutterfire configure`** first) — never `Firebase.initializeApp()` without platform options in production.
- **T2.4** Missing required production config → startup error + user-facing message + non-zero CI, NOT silent mock fallback in production builds.
- **T2.5** `.env` → `.env.example` (keys documented: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `PAYMONGO_PUBLIC_KEY`); `dotenv.load(isOptional: true)`; keep `.env` out of production unless all keys are intentionally public.
  - AC: delete `.env` → app boots to demo mode; staging build with `--dart-define=FIREBASE_ENABLED=true` reaches Firebase without `no-app` error.

**Verify:** `flutter test test/core/config/app_config_test.dart && flutter analyze && flutter build apk --debug --dart-define=FIREBASE_ENABLED=true`
**Do not:** put secret keys in Flutter config; catch-and-continue-as-mock in production; treat anon/public keys as secret.

### Phase 3 — Backend authorization & trusted writes (P0 (1-2 days + emulator setup)

**Problem:** Direct client writes for orders, stock, reviews, profiles, KYC — but zero server-side rules. `AuthGuard` is a UI gate, not auth.

**Files:** `firestore.rules` (new), `storage.rules` (new), `firebase.json` (new), `functions/src/{orders,reviews,reports}.ts` (new), Flutter repositories wired to call those endpoints for privileged ops.

- **T3.1** Write Firestore emulator tests: customer A→B read/write denied; customer edits stall denied; vendor edits another vendor's product denied.
- **T3.2** Custom claims or `users/{uid}` role doc verified by rules; never trust a role string from the client.
- **T3.3** Move order creation, stock mutation, status transitions, cancellations, rating aggregates, report generation into trusted endpoints, using server timestamps + transactions.
- **T3.4** Deploy to a non-prod project first → emulator tests → promote same versioned rules.
- **AC:** emulator denies unauthorized; authorized ownership passes.
- **Do not:** allow `request.auth != null` catch-all; client-calculate payment status / earnings / aggregate ratings.

### Phase 4 — Client-side security & error honesty (P0 (half day)

- **T4.1** Audit `loginAs` call sites (`notifications_screen.dart:128`, `main_screen.dart:192`, `profile_screen.dart:405`). Wrap demo/support entries in `kDebugMode`; real flows use actual credential switch. Remove bare `authProvider.loginAs` outside debug.
- **T4.2** `currentVendorIdProvider`: non-vendor/null user → returns `null`, not `'v1'`. Null-guard consumers (vendor_orders_provider, vendor_reviews_provider).
- **T4.3** Wrap remaining vendor routes in `AuthGuard` (`vendorOrderDetails`, orders, payouts, earnings, stall settings, KYC, reports, notifications).
- **T4.4** Fix silent order failure: `checkout_screen.dart:363-366` → error SnackBar, keep cart intact, never succeed on failure. Add `firestore` rules/function error mapping (typed failure reasons).
- **T4.5** Move PII (addresses, order history names, mock session) to `flutter_secure_storage`; keep `shared_preferences` for theme/prefs troisen. android: disable cloud backups (`android:allowBackup="false"` or `dataExtractionRules`).
- **AC:** a customer tapping vendor-reg-success notification stays customer; no customer can reach vendor screens; checkout failure shows a message and preserves cart; PII no longer in plaintext prefs.

**Verify:** widget tests for the above; else `flutter test`.

### Phase 5 — Order & inventory correctness (P1 (half day)

- **T5.1** Define explicit stock model: store stock in the product's `unit`; `double` for kg, integer-compatible `double` for pc. Reject `stock < requested` — never clamp-and-accept.
- **T5.2** Replace `item.quantity.ceil()` (`firebase_order_repository.dart:103`) with unit-aware deduction; test `0.25/0.5/1/2 kg`, `3 pc`.
- **T5.3** Enforce a status transition graph (e.g. `pending→confirmed|rejected|cancelled`, `confirmed→preparing…`, terminal statuses immutable) in trusted code; atomic status+history write.
- **T5.4** Cancellation eligibility from server time; typed failures `outOfStock`, `cancelWindowExpired`, `illegalStatusTransition` surfaced to UI.
- **Verify:** `flutter test features/orders test/features/vendors/add_to_cart_bottom_sheet_test.dart`
- **Do not:** change pending→confirmed; convert kg via ceil/round/name heuristics; accept order with no stock.

### Phase 6 — Hybrid repository switch (P1 (1-2 weeks)

**Problem:** `cart`, `market`, `recipes` always use mocks; `supabase` client initialized but unused. Existing firebase switch already done for orders/auth/profile/vendors (client switches on `firebaseEnabledProvider`) — finish the same pattern.

- **T6.1** Cart: decide product rule — device-local cart pre-login, merge to server cart (per user) after login; implement `FirebaseCartRepository` or local `SharedPreferences`-backed repository selected via *one explicit backend mode*.
- **T6.2** Market: `FirebaseMarketRepository` implementing the `MarketRepository` contract. Convert the eager `GridView.builder(shrinkWrap)` in `market_screen.dart` to a lazy sliver once catalogs are real.
- **T6.3** Recipes: keep mock for MVP (static content) **or** Supabase content repo with public `RLS select` for anon; owner-scoped purchase/unlock records in Firestore (per your decision below). Do not leave init-only Supabase.
- **T6.4** One repo-selection provider (`backendMode`) that picks mock vs Firebase/Supabase; contract tests run the same suite against each implementation.
- **T6.5** Remove mock fallbacks from live `get()` error paths — live doc missing returns documented empty state, never unrelated mock data.
- **T6.6** Delete the unused `supabaseClientProvider` if Supabase is dropped from the recipe domain.
- **Decision (recipe backend):** Let Project Owner confirm — **Keep Supabase content-only (read-only, public RLS)** or **drop Supabase and store recipes in Firestore** (array-contains for related recipes, subcollection for unlocks). Prefer ONE server plus the smaller runtime footprint. Do not build the two-auth bridge unless the killer recipe→cart feature is on the roadmap.

**Verify:** `flutter test test/features/market test/features/cart test/features/recipes`; staging run `--dart-define=FIREBASE_ENABLED=true --dart-define=APP_ENV=staging` shows zero mock products/profiles.
**Do not:** delete mock repositories; mix Firestore & Supabase in UI; implement recipes in Firestore merely because Firebase exists (this is the decision).

### Phase 7 — Fix sales reports & privacy (P1 (half day)

- Replace the July 2026-const `sales_report_export_service.dart` with a typed report input: authenticated stall identity, date range, actual completed orders, approved revenue fields. Compute boundaries from the selected period + tz.
- Drop the `deliveryCount * 50.0` assumption (use the order's real fee) in `detailed_sales_report_export_service.dart`.
- Include only orders the current vendor is authorized to export; no masked contacts leak (redact another customer's phone/address).
- AC: PDF/Excel test asserts dynamic stall/date/totals and excludes known fixtures.

**Verify:** `flutter test test/features/vendors/application/sales_report_export_service_test.dart`
**Do not:** claim official financial documents until numbers come from trusted backend + reconciliation.

### Phase 8 — Responsive, accessibility, i18n (P1 (1 day))

- **T8.1** Kill the `minWidth:450` cap in `responsive_wrapper.dart`; use real breakpoints (mobile full-width; desktop centered max-width). Mobile `360dp` / `390dp`; never overflow.
- **T8.2** Add 360/390/430dp + tablet layout tests for home, cart, checkout, order tracker, vendor dashboard, notifications.
- **T8.3** Test at 1.3× and 1.5× text scale; ensure icon-only controls have semantics/tooltips; every status must be color+icon+text.
- **T8.4** i18n: ARB/intl scaffolding (`flutter gen-l10n`) + move the ~hardcoded UI strings in the highest-traffic screens first.
- **Verify:** `flutter test test/core/widgets/responsive_wrapper_test.dart` + screens list.
- **Do not:** shrink fonts globally; hide vital actions at large text.

### Phase 9 — Theme consolidation (P1 (1-2 days))

- **T9.1** Add semantic colors (`surface`, `text`, `muted`, `border`, `success`, `warning`, `error`, `open`, `closed`, statuses) to `AppTheme`. Migrate high-traffic screens (home, cart, checkout, notifications, order details, vendor dashboard) off literals. Promote only reused values.
- **T9.2** Tighten `analysis_options.yaml`: enable `use_build_context_synchronously`, `prefer_const_constructors`, `prefer_const_declarations`, `avoid_print`. Delete raw font-family repeat → use theme text style.
- **AC:** grep for `0xFF0B372B` in `core` reachable screens ~0; `flutter analyze` still 0 after fixes.
- **Do not:** build a giant constant file for one-off decor; add a dark mode before light semantics are stable.

### Phase 10 — God-file extraction (P1, ongoing)

- **Registration_presentation (783):** with draft fields, terms row, address placeholder card, bottom action bar, formatter classes → widgets/utils.
- **vendor_add_product (756):** split success sheet, category/subcategory pickers, save→controller with ≤5 setState (currently 13).
- **vendor_order_details (742):** the single 420-line `build()` → 4+ widgets (status header, special-instructions card, actions row); 3 dialogs → files; `_getStatusColor`→shared util.
- **Same treatment** for `vendor_reviews` (725), `vendor_license` (512+gen) (712), `set_delivery_address` (708), `vendor_dashboard` (706), `market_screen` (580), `order_details` (678), `recipes` (654), `checkout_widgets` (653).
- PII of duplication: consolidate quantity formatting, currency formatting, status colors, empty states, async error/empty widget (32 hand-rolled sites) into shared widgets (`AsyncStateView`, `EmptyState`, `AppTextField`).
- AC: no behavior change; file sizes drop below 400; each screen's existing widget tests pass.

### Phase 11 — Dependency & code hygiene (P1)

- **T11.1** Remove unused deps: `share_plus`, `file_saver`, `cupertino_icons` (runtime), `network_image_mock` (dev). Confirm each has zero imports before deleting.
- **T11.2** Batch upgrade minors/patches (intl, pdf, printing, image_picker, url_launcher…). Then *judge* majors: `flutter_riverpod 3.4`, `google_sign_in 7` (needs API rework — check), `share_plus` moot if removed, `file_picker 8→11`, `geolocator 13→14`.
- **domain AC:** run a staging manual pass after each major.
- **Do not:** upgrade a major mid-task just to be current; remove deps without zero-import proof.

### Phase 12 — Testing & quality gate (P2 (2-3 days))

- **T12.1** Replace 4 placeholder `expect(true, true)` tests with real behavior (order_service, floating_order_progress, order_details, floating_new_order_notification). AC: zero `true, true` in repo.
- **Priority new coverage:** KYC + license flow (providers, snackbars) — money-adjacent; vendor onboarding steps; announcements; recipes UI; checkout address/payment validation. AC: ≥60% on those files.
- **Test layers:** fast unit (transitions, fees, mapping), widget (kg picker, closed-stall block, tracker), emulator/local environments (Firebase emulator, RLS) run separate from PR.
- **fake_async** for delays; bounded `pumpUntilFound`; instantiate only the API on each subject; avoid static shared state between tests.
- **Golden fix:** bundle PlusJakartaSans or a fallback for CI reproducibility; keep only meaningful golden.
- **Add coverage gate** to CI after value chains; set initial threshold 55% then raise.

### Phase 13 — CI/CD hardening (P2)

- Timed steps (`timeout-minutes`) + elapsed echo on Analyze/Test/Build.
- Split PR-required (format, analyze, fast tests, debug APK) from heavier (coverage, integration, larger suites) on scheduled/manual.
- Coverage upload after publishing.
- Dependency vulnerability scanning optional (osv-scanner) once triage ownership exists.
- Release signing: only when a release candidate exists; keys in Actions secrets; fail build if `key.properties` absent (build.gradle.kts:44-57 fallback to debug keystore is a trap).
- CD to Play’s internal test track, never auto-PR-ing debug APK as production.

**Verify:** PR shows secret hygiene, analyze, fast test, debug APK, bounded timing.
**Do not:** CD just because CI is green; debug artifacts as production.

### Phase 14 — Performance polish (P2D (slot))

- Rewrite 8 uncached `Image.network` → `AdaptiveImage` (recipe ingredients, notifications, recipes screen, cookbook).
- `vendor_reviews_carousel` → `AnimationController`.

### Phase 15 — the killer-recipe feature (optional bet, P2)

Only if the Project Owner greenlights Supabase: "recipes I can cook from what's in my cart" and per-product ingredient→item price mapping. That is the relational workload that justifies the hybrid backend — nothing else does today.

---

## Recommended Commit Sequence

1. `chore: clean generated files and formatting`
2. `fix: initialize enabled backends in release`
3. `feat: add firestore and storage access rules`
4. `fix: enforce server-side order transitions and stock`
5. `feat: connect live market cart and recipe repositories`
6. `fix: generate sales reports from actual data`
7. `fix: support narrow screens and larger text`
8. `test: replace stale order flow tests`
9. `chore: remove unused dependencies`
10. `ci: split fast checks from integration coverage`

---

## Final Release Gate

The app is ready for a closed beta only when **every** statement is true:

- [ ] CI compiles a **fresh clone** (generated files committed or build_runner in CI).
- [ ] Firebase initializes in a **release** build when Firebase mode is enabled.
- [ ] Firestore/Storage rules deployed and emulator-tested for customer, vendor, unauthorized.
- [ ] The Flutter client cannot set payment status, stock, aggregate ratings, or illegal order statuses directly.
- [ ] Weighted inventory deducts exact kilograms and rejects insufficient stock.
- [ ] Market, cart, orders, profile, vendor, recipes show **live** backend data (staging), not mock fallback.
- [ ] Reports use the authenticated vendor, selected period, real orders; no hard-coded fixtures.
- [ ] App works at 390/430dp and 1.3×/1.5× text scale without overflow.
- [ ] No placeholder tests; unit, widget, integration suites cover the money/order path.
- [ ] No `.env`, secrets, keystores, generated reports, local history, or build output tracked.
- [ ] `flutter analyze`, `flutter test`, `git diff --check`, debug APK build all green in CI with recorded output.

---

## Suggested starting point

**Phase 0 → Phase 1 → Phase 2.** Do not begin live Firebase/Supabase work until release initialization and server-side authorization are designed. After Phase 5 (orders/inventory), you can interleave the frontend-hardening phases (8-11) as backend repositories get connected.

**Every phase gates on:** `flutter analyze` 0, `flutter test` green, no new `catch (_) {}`, no new silent failures in release.