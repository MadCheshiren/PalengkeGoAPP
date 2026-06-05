# Saved Recipes Cookbook Feature

This plan details the implementation of a Saved Recipes "Cookbook" feature in PalengkeGo. It adds a custom Cookbook SVG icon to the top-right of the Recipes screen, provides visual "Heart" states on both recipe lists and details screens, and delivers a new, premium Cookbook screen with a delightful empty state.

## Visual Direction Probes

We generated two design concepts for the Cookbook UI:
- **Probe A (Deep Green Premium List)**: Features a beautiful clean dark-green header, structured recipe list cards with interactive favoriting states, and high readability matching the main app.
- **Probe B (Cozy kitchen sketch grid)**: Features a cozy recipe card grid layout with light warm backgrounds.

> [!NOTE]
> Based on our discovery, we are moving forward with **Probe A (List layout + Full screen route)** which fits the mobile-first, clean utilitarian PalengkeGo design style.

````carousel
![Probe A - Deep Green Premium Theme](/C:/Users/fragi/.gemini/antigravity-ide/brain/a504c9a5-b44f-493c-b978-407f75a8b43c/cookbook_probe_a_1779950155877.png)
<!-- slide -->
![Probe B - Hand-Drawn Cozy Kitchen Grid Theme](/C:/Users/fragi/.gemini/antigravity-ide/brain/a504c9a5-b44f-493c-b978-407f75a8b43c/cookbook_probe_b_1779950204179.png)
````

---

## User Review Required

> [!IMPORTANT]
> **Dynamic Syncing**: Hearting a recipe on the main Recipes screen or within the Recipe Details screen will instantly add or remove it from the Cookbook. This provides seamless, live-updated synchronization across all screens.
>
> **Interactive Micro-animations**: Tapping the heart button will trigger a subtle scale-bounce animation to provide delightful visual feedback.

---

## Proposed Changes

### Component: Core Assets & Router

#### [NEW] [cookbook.svg](file:///c:/Users/fragi/Videos/PalengkeGoAPP/assets/icons/cookbook.svg)
Create a new custom SVG icon representing a cookbook (a book with a chef's hat and bookmark details).

#### [MODIFY] [app_routes.dart](file:///c:/Users/fragi/Videos/PalengkeGoAPP/lib/core/navigation/app_routes.dart)
Add route name constant for the Cookbook screen:
```dart
static const cookbook = '/cookbook';
```

#### [MODIFY] [app_router.dart](file:///c:/Users/fragi/Videos/PalengkeGoAPP/lib/core/navigation/app_router.dart)
Import `cookbook_screen.dart` and register the route inside `onGenerateRoute`:
```dart
case AppRoutes.cookbook:
  return _slideRoute(settings, const CookbookScreen());
```

---

### Component: State Management

#### [NEW] [saved_recipes_provider.dart](file:///c:/Users/fragi/Videos/PalengkeGoAPP/lib/features/recipes/application/saved_recipes_provider.dart)
Implement a state notifier class (`SavedRecipesService` extending `ChangeNotifier`) to handle local memory-saved recipe state and a Riverpod provider `savedRecipesServiceProvider`.
```dart
class SavedRecipesService extends ChangeNotifier {
  final List<Recipe> _savedRecipes = [];
  List<Recipe> get savedRecipes => List.unmodifiable(_savedRecipes);
  
  bool isSaved(Recipe recipe) => _savedRecipes.any((r) => r.title == recipe.title);
  
  void toggleSave(Recipe recipe) { ... }
}
```

---

### Component: Recipes & Details Screens

#### [MODIFY] [recipes_screen.dart](file:///c:/Users/fragi/Videos/PalengkeGoAPP/lib/features/recipes/presentation/pages/recipes_screen.dart)
- Import `flutter_svg` and `saved_recipes_provider.dart`.
- Change to a `ConsumerWidget` if not already (it is).
- Add a top-right action button in the header displaying `cookbook.svg`. Tapping it navigates to the Cookbook screen.
- Overlap a circular Heart button on the Featured Recipe card using a Glassmorphic or transparent white container.
- Add an interactive Heart button on each recipe card in the "More Recipes" list.
- Wire up the buttons to call `ref.read(savedRecipesServiceProvider.notifier).toggleSave(recipe)`.

#### [MODIFY] [recipe_details_screen.dart](file:///c:/Users/fragi/Videos/PalengkeGoAPP/lib/features/recipes/presentation/pages/recipe_details_screen.dart)
- Convert to `ConsumerStatefulWidget` and `ConsumerState`.
- Watch `savedRecipesServiceProvider` to get the current favorite status of the recipe instead of local state.
- Wire up the top-right favorite button to toggle state via `savedRecipesServiceProvider` when tapped.

---

### Component: Cookbook Screen

#### [NEW] [cookbook_screen.dart](file:///c:/Users/fragi/Videos/PalengkeGoAPP/lib/features/recipes/presentation/pages/cookbook_screen.dart)
Implement a premium Cookbook screen matching **Probe A**:
- **AppBar**: Slim elegant header with a Back button and a title like "My Cookbook".
- **List Layout**: Display cards of saved recipes using similar styling to recipe cards.
- **Empty State UI**: When the cookbook is empty, show a cozy, beautiful custom illustration (using a chef hat/cooking theme), a comforting description: *"Your cookbook is empty. Start adding recipes you love!"*, and a green primary button labeled **"Explore Recipes"** that pops back to the recipes screen.
- **Micro-interactions**: Subtle hover/tap scaling and list animations when items are deleted.

---

## Verification Plan

### Automated & Manual Verification
1. **Verify Asset Loading**: Build and run the app. Check that `cookbook.svg` loads properly in the top-right header of the Recipes screen.
2. **Test Route Navigation**: Tap the Cookbook icon; verify it slides in cleanly to the `/cookbook` screen.
3. **Validate Empty State**: Observe the empty state illustration and tap the "Explore Recipes" button to ensure it brings the user back to the recipes tab.
4. **Test Saving & De-saving**:
   - Save a recipe from the main list using the Heart button.
   - Tap the Cookbook icon and verify the saved recipe appears instantly.
   - Open the recipe details screen; confirm the favorite icon in the top-right shows it is favorited.
   - Unfavorite it from the details screen; check that the Cookbook updates dynamically.
