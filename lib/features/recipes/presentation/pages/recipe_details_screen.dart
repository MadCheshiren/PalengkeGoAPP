import 'package:flutter/material.dart';
import 'package:palengkego/features/recipes/presentation/widgets/recipe_hero_card.dart';
import 'package:palengkego/features/recipes/presentation/widgets/recipe_ingredients_list.dart';
import 'package:palengkego/features/recipes/presentation/widgets/recipe_stats_row.dart';
import 'package:palengkego/features/recipes/presentation/widgets/recipe_steps_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/recipes/application/saved_recipes_provider.dart';
import 'package:palengkego/features/recipes/domain/recipe.dart';

class RecipeDetailsScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
  });

  @override
  ConsumerState<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends ConsumerState<RecipeDetailsScreen> {
  final Set<String> checkedIngredients = {};

  @override
  Widget build(BuildContext context) {
    final recipeObject = widget.recipe;
    final savedRecipes = ref.watch(savedRecipesProvider);
    final isSaved = savedRecipes.any((r) => r.title == recipeObject.title);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        scaffoldMessenger.clearSnackBars();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar with Back Button and Favorite
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              color: Colors.black.withOpacity(0.05),
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
                        ref.read(savedRecipesProvider.notifier).toggleSave(recipeObject);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSaved 
                                  ? 'Removed "${recipeObject.title}" from Cookbook.' 
                                  : 'Added "${recipeObject.title}" to Cookbook.',
                              style: const TextStyle(fontFamily: 'PlusJakartaSans'),
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSaved ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isSaved ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          size: 20,
                          color: isSaved ? const Color(0xFFEF4444) : const Color(0xFF0B372B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Hero Image with Overlay
          SliverToBoxAdapter(
            child: RecipeHeroCard(recipe: widget.recipe),
          ),

          // Stats Chips
          SliverToBoxAdapter(
            child: RecipeStatsRow(recipe: widget.recipe),
          ),

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

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    ),
  );
}
}
