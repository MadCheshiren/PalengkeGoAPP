# Emerald Harvest Design System

## 1. Overview & Creative North Star

**Creative North Star: The Urban Agrarian**

Emerald Harvest is a design system that bridges the gap between the raw, tactile energy of a local marketplace and the sophisticated efficiency of modern digital commerce. It rejects the sterile "white-box" tech aesthetic in favor of a deep, organic palette and editorial layouts that prioritize discovery and community.

The system uses intentional asymmetry and overlapping elements (like the floating promo cards and bottom-anchored navigation) to break the grid, creating a sense of movement and "market-day" energy.

---

## 2. Colors

The palette is rooted in deep forest greens (`#0b372b`) and vibrant herbal accents (`#6d9773`), balanced against crisp white surfaces.

### Core Palette

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary (Deep Emerald) | `#0B372B` | Primary buttons, active states, navigation, brand identity |
| Accent Green | `#6D9773` | Secondary actions, herbal accents, category tags |
| Accent Yellow | `#FFB902` | Status indicators, ratings, promos (sparingly) |
| Surface Light | `#F6F8F7` | Input fields, search bars, secondary containers |
| Surface Container Low | `#F1F5F9` | Section backgrounds, card containers |
| Surface Container | `#E2E8F0` | Elevated surfaces, dividers, borders |
| Background | `#FFFFFF` | Main content background |
| On Surface | `#0B372B` | Primary text (deep emerald, not black) |
| On Surface Variant | `#64748B` | Secondary text, metadata, timestamps |

### Semantic Colors

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Status Open | `#22C55E` | Open status badges |
| Status Closed | `#94A3B8` | Closed status badges |
| Notification Badge | `#EF4444` | Alert indicators, unread badges |
| Star Rating | `#FFB902` / `#FBBF24` | Rating stars (both yellow variants acceptable) |
| Error State | `#EF4444` | Error messages, delete actions |
| Success State | `#22C55E` | Success confirmations |

### Color Rules

- **The "No-Line" Rule:** Sectioning is achieved through shifts in background tone (e.g., transitioning from `surface` to `surface_container_low`) rather than 1px borders. If a boundary is required, use a soft shadow or a change in the elevation of the container.
- **Surface Hierarchy:** Depth is created by nesting `surface_container` elements within a white `background`. High-priority cards use `shadow-md` to appear lifted, while secondary inputs sit flush within `surface_light`.
- **Glass & Gradient:** Hero banners and promotional areas must utilize bottom-up gradients (Primary to Transparent) to ensure text legibility over photography.
- **Signature Textures:** Use the "Accent Yellow" (`#ffb902`) sparingly for status indicators (ratings, promos) to provide a sun-drenched, high-contrast focal point.

---

## 3. Typography

The system uses **Plus Jakarta Sans** across all levels to maintain a clean, contemporary feel with high legibility.

### Typography Scale

| Level | Size | Weight | Tracking | Usage |
|-------|------|--------|----------|-------|
| Display | 1.5rem (24px) | 700 | -0.02em | Brand identity, hero titles |
| Headline | 1.25rem (20px) | 700 | -0.02em | Section titles, page headers |
| Subheadline | 1rem (16px) | 600 | normal | Card titles, important labels |
| Body | 0.875rem (14px) | 400 | normal | Product descriptions, secondary info |
| Caption | 0.75rem (12px) | 500 | normal | Metadata, timestamps |
| Label | 0.75rem (12px) | 600 | 0.05em | Uppercase, section headers |
| Micro | 9-10px | 600 | 0.1em | Stall numbers, badges |

### Typography Rules

- **Display & Headline:** Bold weights (700) with tight tracking (-0.02em) are used for brand identity and section titles.
- **Body:** Regular weight (400) at `0.875rem` for product descriptions and secondary information.
- **Labels:** Micro-type at `0.75rem` (uppercase with `tracking-wider`) and `9px` to `10px` for metadata (stall numbers, badges), creating an information hierarchy that feels dense yet organized.
- **Rhythm:** The scale jumps from `14px` labels to `1.5rem` headers to create dramatic editorial contrast.

---

## 4. Elevation & Depth

Elevation is communicated through a combination of tailored shadows and tonal stacking.

### Shadow Scale

| Shadow Name | Blur | Offset | Usage |
|-------------|------|--------|-------|
| shadow-sm | 8px | 0, 2px | Interactive cards, input fields |
| shadow-md | 12px | 0, 4px | Standard product/stall cards ("pick-up-ability") |
| shadow-lg | 16px | 0, 8px | Featured promotional banners, hero moments |
| shadow-2xl | 24px | 0, 12px | Primary containers, persistent sidebars |

### Elevation Rules

- **The Layering Principle:** Deep emerald backgrounds (`primary`) are used for active states in chips and navigation, while "resting" states use `surface_container` tiers.
- **Glassmorphism:** Bottom navigation and floating badges (like ratings) use a `backdrop-blur-md` (95% opacity) to maintain context of the content scrolling beneath them.

---

## 5. Components

### Buttons & Chips

**Primary Buttons:**
- Shape: Pill-shaped (`rounded-full`)
- Background: High-contrast emerald (`#0B372B`)
- Text: White, weight 600
- Elevation: shadow-sm on hover

**Secondary Chips:**
- Background: `surface_light` (`#F6F8F7`)
- Border: Subtle, 1px
- Shape: Rounded-lg (8px)
- Text: On Surface variant

### Stall Cards

A compound component with:
- **Image:** `1:1` aspect ratio, `rounded-2xl` (16px) corners
- **Rating Badge:** Glassmorphism, floating top-right
- **Action Button:** Floating "add" button, pill-shaped
- **Elevation:** shadow-md
- **Layout:** Asymmetric, overlapping elements

### Search Bar

- Shape: `rounded-xl` (12px)
- Background: Flat, shadow-less
- Icon: Inset, 18px
- Text: Body size, placeholder in On Surface Variant
- Container height: 43px

### Promotional Banners

- Aspect Ratio: `2:1` (wide format)
- Corners: `rounded-2xl` (16px)
- Overlay: Bottom-up gradient (Primary to Transparent)
- Typography: White-on-dark
- Elevation: shadow-lg

### Status Badges

- **Open:** Green-500 fill, white text
- **Closed:** Slate-400 fill, white text
- Shape: Pill-shaped or rounded-lg
- Size: Label (12px, uppercase)

---

## 6. Do's and Don'ts

### Do's

- ✅ Use `primary` (`#0B372B`) for all primary actions, headers, and key brand elements
- ✅ Use `accent-green` for secondary actions and category indicators
- ✅ Ensure all imagery has a slight `rounded-2xl` corner radius to match the soft-organic theme
- ✅ Leverage "Open/Closed" status badges with high-contrast color fills (`#22C55E` / `#94A3B8`)
- ✅ Apply glassmorphism to floating elements (ratings, navigation, bottom nav)
- ✅ Use `on_surface` (`#0B372B`) for all primary text - **never pure black**

### Don'ts

- ❌ Use solid black (`#000000`) or dark grays (`#1F2937`, `#0F172A`) for text
- ❌ Use the wrong primary green (`#2E7D32`) - must be `#0B372B`
- ❌ Use sharp-edged boxes; every container minimum `0.5rem` (rounded-lg) radius
- ❌ Use 1px borders for sectioning; prefer background tone shifts (`surface_container_low`)
- ❌ Overuse Accent Yellow; reserve for ratings and promos only
- ❌ Apply heavy shadows to flat inputs (search bar should be shadow-less)

---

## 7. Flutter Implementation Notes

### Color Constants (app_theme.dart)

```dart
static const Color primary = Color(0xFF0B372B);
static const Color accentGreen = Color(0xFF6D9773);
static const Color accentYellow = Color(0xFFFFB902);
static const Color surfaceLight = Color(0xFFF6F8F7);
static const Color surfaceContainerLow = Color(0xFFF1F5F9);
static const Color surfaceContainer = Color(0xFFE2E8F0);
static const Color background = Color(0xFFFFFFFF);
static const Color onSurface = Color(0xFF0B372B);
static const Color onSurfaceVariant = Color(0xFF64748B);
static const Color statusOpen = Color(0xFF22C55E);
static const Color statusClosed = Color(0xFF94A3B8);
static const Color notificationBadge = Color(0xFFEF4444);
static const Color starRating = Color(0xFFFFB902);
```

### Corner Radius Standards

```dart
static const double radiusSm = 8.0;   // rounded-lg
static const double radiusMd = 12.0;  // rounded-xl
static const double radiusLg = 16.0;  // rounded-2xl
static const double radiusFull = 50.0; // rounded-full
```

### Shadow Standards

```dart
static List<BoxShadow> shadowSm = [
  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2)),
];

static List<BoxShadow> shadowMd = [
  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4)),
];

static List<BoxShadow> shadowLg = [
  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: Offset(0, 8)),
];
```

---

## 8. Animation Guidelines

### Page Transitions

- **Slide from Right:** Standard navigation (Market → Cart, Cart → Checkout)
- **Scale + Fade:** Full-screen replacements (Checkout → Order Confirmation)
- **Duration:** 280ms forward, 220ms reverse

### Micro-interactions

- **Button Press:** Scale down to 0.95 on tap, 100ms duration
- **Card Entrance:** Fade + slide up, staggered by 50ms per item
- **Hero Transitions:** Product images and vendor avatars use Hero widgets

---

*Design System Version 1.0 | PalengkeGo App*
