import 'package:flutter/material.dart';
import 'package:palengkego/features/recipes/presentation/widgets/recipe_hero_card.dart';
import 'package:palengkego/features/recipes/presentation/widgets/recipe_ingredients_list.dart';
import 'package:palengkego/features/recipes/presentation/widgets/recipe_stats_row.dart';
import 'package:palengkego/features/recipes/presentation/widgets/recipe_steps_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/recipes/application/saved_recipes_provider.dart';
import 'package:palengkego/features/recipes/domain/recipe.dart';

class RecipeDetailsScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailsScreen> createState() =>
      _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends ConsumerState<RecipeDetailsScreen> {
  final Set<String> checkedIngredients = {};

  @override
  Widget build(BuildContext context) {
    final recipeObject = widget.recipe;
    final savedRecipes = ref.watch(savedRecipesProvider);
    final isSaved = savedRecipes.any((r) => r.title == recipeObject.title);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final hasIngredients =
        recipeObject.ingredients != null && recipeObject.ingredients!.isNotEmpty;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        scaffoldMessenger.clearSnackBars();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        bottomNavigationBar: hasIngredients
            ? _AddToCartBar(recipe: recipeObject)
            : null,
        body: CustomScrollView(
          slivers: [
            // App Bar with Back Button and Favorite
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                      ),
                      const Text(
                        'Recipe Details',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(savedRecipesProvider.notifier)
                              .toggleSave(recipeObject);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isSaved
                                    ? 'Removed "${recipeObject.title}" from Cookbook.'
                                    : 'Added "${recipeObject.title}" to Cookbook.',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSaved
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            size: 20,
                            color: isSaved
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0B372B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Hero Image with Overlay
            SliverToBoxAdapter(child: RecipeHeroCard(recipe: widget.recipe)),

            // Stats Chips
            SliverToBoxAdapter(child: RecipeStatsRow(recipe: widget.recipe)),

            // Ingredients Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RecipeIngredientsList(
                  recipe: widget.recipe,
                  checkedIngredients: checkedIngredients,
                  onIngredientToggled: (name) {
                    setState(() {
                      if (checkedIngredients.contains(name)) {
                        checkedIngredients.remove(name);
                      } else {
                        checkedIngredients.add(name);
                      }
                    });
                  },
                ),
              ),
            ),

            // Procedure Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Procedure',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecipeStepsList(recipe: widget.recipe),
                  ],
                ),
              ),
            ),

            // Bottom padding for the sticky CTA bar
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky "Add Ingredients to Cart" bottom bar
// ---------------------------------------------------------------------------
class _AddToCartBar extends ConsumerWidget {
  final Recipe recipe;
  const _AddToCartBar({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartService = ref.read(cartServiceProvider);
    final ingredients = recipe.ingredients ?? [];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            if (ingredients.isEmpty) return;

            // Add each ingredient as a cart item from the "Recipe Market" vendor
            for (final ingredient in ingredients) {
              cartService.addToCart(
                vendorName: 'Recipe Market',
                productName: ingredient.name,
                price: 0,
                weight: ingredient.description,
                pricePerKg: '',
                image: ingredient.imageUrl ?? '',
              );
            }

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${ingredients.length} ingredient${ingredients.length == 1 ? '' : 's'} added to cart!',
                  style: const TextStyle(fontFamily: 'PlusJakartaSans'),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF0B372B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'View Cart',
                  textColor: const Color(0xFF6FCF97),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            );
          },
          icon: const Icon(Icons.shopping_cart_outlined, size: 18),
          label: Text(
            'Add ${ingredients.length} Ingredients to Cart',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B372B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
