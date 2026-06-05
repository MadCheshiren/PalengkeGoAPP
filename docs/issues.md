# PalengkeGo - Active Issues

This file only tracks work that still appears open.
Fixed items were removed so this stays useful as a live backlog.

## High Priority

### 0. Logo display issues - PARTIALLY FIXED
**Current state**: 
- ✅ Splash screen - FIXED: Now using `logonobg.png` (no background) for consistent dark green appearance
- ✅ Splash screen centering - FIXED: Using Center widget with Column MainAxisAlignment.center
- ✅ Registration/Login screens - Logos temporarily removed (entry points, no need for back button or logo clutter)

**Remaining**: Consider re-adding logos to auth screens after testing logo positioning with proper constraints

### 1. Cart screen still has a web layout/render bug at narrow widths
**Current state**: the cart badge updates and cart state exists, but on Flutter web at narrow mobile-like widths the cart body can still render as a blank white area while the header and bottom nav remain visible.

**Observed console/runtime symptoms**:
- `BoxConstraints forces an infinite width`
- `Cannot hit test a render box that has never been laid out`
- repeated rendering `Assertion failed` logs
- earlier runs also showed `A RenderFlex overflowed by 5.6 pixels on the right`

**Why this matters**:
- this is currently the most disruptive UX bug in the app
- it blocks the whole cart -> checkout flow on web
- it is easy to waste time chasing the wrong warning

**What is probably NOT the root cause**:
- the Chrome/Dart issue panel warning about `Intl.v8BreakIterator is deprecated`
- `SafeArea` alone

**Suggested fix**:
- isolate the first widget subtree that causes the render break
- temporarily replace the cart body with plain debug rows
- add the real UI back section-by-section until the exact offender is found

**Tips**:
- keep Chrome DevTools open and stop at the first real render error, not the later cascades
- test on the same narrow viewport where the problem appears
- suspect rows that mix:
  - images
  - `Expanded`
  - nested `Row`
  - `double.infinity`
  - quantity controls
- suspect the shared bottom nav too if the cart icon or labels visually corrupt

### 2. `HomeScreen` and `MarketScreen` architecture is still awkward
**Current state**: `HomeScreen` is effectively a placeholder wrapper around `MarketScreen`, which avoids duplicate UI but does not yet give the app a true distinct Home experience.

**Why this matters**:
- the current shell now has both `Home` and `Market` tabs
- visually they are too similar right now
- future changes can accidentally reintroduce duplication or inconsistent tab behavior

**Suggested fix**:
- decide whether `Home` should be a true separate screen or intentionally mirror `Market`
- if separate, extract reusable shared pieces first:
  - header
  - search bar
  - category chips
  - stall card
- keep tab state in `MainScreen`, not inside each page

**Tips**:
- do not duplicate the bottom nav inside subpages
- if extracting widgets, prefer `lib/core/widgets/` only for genuinely shared pieces
- if keeping `Home` distinct, use different sections rather than just rearranging the exact same list

### 3. SVG/icon usage is still inconsistent
**Current state**: some major areas were improved, but several screens still rely on Material icons where the Figma design language would look better with custom assets.

**Why this matters**:
- this is one of the biggest remaining reasons the app can still feel “close” to Figma instead of truly matching it
- visual polish suffers when custom iconography and Material icons are mixed

**Suggested fix**:
- audit screen-by-screen and replace high-visibility Material icons with Figma-derived SVGs where appropriate
- prioritize:
  - headers
  - action buttons
  - metadata rows
  - status and navigation icons

**Tips**:
- do not blindly replace every icon if there is no matching asset
- focus first on icons the user sees repeatedly
- keep explicit width and height on SVGs to avoid scaling/viewBox issues

## Medium Priority

### 4. Form validation is still incomplete
**Current state**: auth forms still rely mostly on UI structure without strong validation behavior.

**Why this matters**:
- forms can still accept empty or weak values
- this weakens the realism of the flow even before backend auth exists

**Suggested fix**:
- add validators to login and registration fields
- cover at least:
  - required fields
  - email format
  - password minimum rules
  - confirm-password match

**Tips**:
- keep validation messages short and calm
- do not over-engineer this into a full auth layer yet
- use helper methods for validators so the rules stay consistent across screens

### 5. Deprecated `withOpacity()` usage still exists in the codebase
**Current state**: several warnings remain outside the recently updated screens.

**Why this matters**:
- analyzer noise makes real warnings harder to spot
- future cleanup gets slower when deprecated APIs stay everywhere

**Suggested fix**:
- replace remaining `withOpacity(x)` calls with `withValues(alpha: x)`

**Tips**:
- validate changed files with Flutter’s bundled Dart:
  - `C:\Users\fragi\Music\flutter\bin\dart.bat analyze <files>`
- do this in batches by feature instead of one giant repo-wide sweep if you want easier review

### 6. Several taps still do nothing
**Current state**: some buttons or cards still have placeholder handlers.

**Examples likely still needing follow-up**:
- forgot password
- track delivery
- order detail / recipe detail style taps
- some secondary profile/settings actions

**Why this matters**:
- the app looks more complete than it behaves in those spots
- dead taps are frustrating because they appear interactive

**Suggested fix**:
- either wire real navigation
- or intentionally show a lightweight “Coming soon” response

**Tips**:
- prefer real navigation if the target screen already exists
- if the screen does not exist yet, use a temporary message instead of silent no-op behavior
- keep a small list of unresolved tap targets so they do not disappear into the UI

### 7. Some vendor/product logic is still using fallback mapping instead of fully data-driven records
**Current state**: a few Figma-aligned screens use helper methods or fallback mappings for vendor details and product variations when the shared mock data does not yet contain the right structure.

**Why this matters**:
- it works, but it is harder to scale
- future screens may need more per-vendor metadata

**Suggested fix**:
- move vendor-specific metadata into shared data models
- examples:
  - stall label
  - section name
  - rating
  - available weights
  - vendor avatar / hero image

**Tips**:
- prefer updating `mock_data.dart` over adding more special-case `switch` logic in widgets
- keep temporary fallback logic only where it is clearly marked
- this will make eventual Firebase migration easier

## Low Priority

### 8. `SplashScreen` font usage should be normalized
**Current state**: some screens still specify `fontFamily` manually, and the splash/font setup should eventually be normalized around `google_fonts`.

**Why this matters**:
- text rendering can drift between platforms
- it is cleaner to rely on the theme or direct `GoogleFonts.plusJakartaSans()` usage

**Suggested fix**:
- remove risky hardcoded font-family assumptions where they conflict with the Google Fonts setup

**Tips**:
- do not rewrite every text style at once
- clean this up gradually when touching related screens
- prioritize top-level branding screens first

### 9. The backlog itself should be kept current as screens change
**Current state**: this file previously drifted badly from the real codebase.

**Why this matters**:
- stale issue lists waste time
- handoff quality drops fast when docs stop matching reality

**Suggested fix**:
- update this file after major screen rewrites
- remove fixed issues instead of letting the file become a changelog

**Tips**:
- treat this as an active backlog, not project history
- if a fix is partial, note what still remains instead of leaving the original issue text untouched
