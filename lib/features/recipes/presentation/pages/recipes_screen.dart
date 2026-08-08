import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/features/recipes/application/recipe_provider.dart';
import 'package:palengkego/features/recipes/domain/recipe.dart';
import 'recipe_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/features/recipes/application/saved_recipes_provider.dart';
import 'package:palengkego/features/orders/application/order_provider.dart';
import 'package:palengkego/features/orders/domain/order_status.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final allRecipes = ref.watch(allRecipesProvider).value ?? const <Recipe>[];
    final savedRecipes = ref.watch(savedRecipesProvider);
    final ordersAsync = ref.watch(orderServiceProvider);

    final purchasedProductNames = <String>{};
    ordersAsync.whenData((orders) {
      purchasedProductNames.addAll(
        orders
            .where((order) => order.status == OrderStatus.completed)
            .expand((order) => order.items)
            .map((item) => item.productName.toLowerCase()),
      );
    });

    // Recipes unlock when their title or ingredients match any purchased item
    final unlockedRecipes = allRecipes.where((recipe) {
      final titleLower = recipe.title.toLowerCase();
      if (purchasedProductNames.any(
        (p) => titleLower.contains(p) || p.contains(titleLower),
      )) {
        return true;
      }
      if (recipe.ingredients != null) {
        for (final ing in recipe.ingredients!) {
          final ingName = ing.name.toLowerCase();
          if (purchasedProductNames.any(
            (p) => ingName.contains(p) || p.contains(ingName),
          )) {
            return true;
          }
        }
      }
      return false;
    }).toList();

    final categories = [
      'All',
      ...unlockedRecipes.map((r) => r.category).toSet(),
    ];

    final filteredRecipes = _selectedCategory == 'All'
        ? unlockedRecipes
        : unlockedRecipes
              .where((r) => r.category == _selectedCategory)
              .toList();

    final featuredRecipe = filteredRecipes.isNotEmpty
        ? filteredRecipes.first
        : null;
    final moreRecipes = filteredRecipes.length > 1
        ? filteredRecipes.skip(1).toList()
        : <Recipe>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recipes',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.cookbook),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/cookbook.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0B372B),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Cook with fresh ingredients\nfrom your local market',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (unlockedRecipes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 48,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0FDF4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                size: 48,
                                color: Color(0xFF0B372B),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Locked Recipes',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Purchase fresh ingredients like Mango, Chicken, Pork, or Vegetables from Diosa Fruit Stand or other stalls to unlock delicious local recipes!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: categories.map((cat) {
                            final isSelected = cat == _selectedCategory;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutQuart,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0B372B)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (featuredRecipe != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Featured Recipe',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildFeaturedRecipe(
                            context,
                            ref,
                            featuredRecipe,
                            savedRecipes,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (moreRecipes.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'More Recipes',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: moreRecipes.length,
                          itemBuilder: (cellContext, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildRecipeCard(
                                context,
                                ref,
                                moreRecipes[index],
                                savedRecipes,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (filteredRecipes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 40,
                          ),
                          child: Center(
                            child: Text(
                              'No recipes found in this category.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedRecipe(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
    List<Recipe> savedRecipes,
  ) {
    final isSaved = savedRecipes.any((r) => r.title == recipe.title);

    return GestureDetector(
      onTap: () => _openRecipe(context, recipe),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                recipe.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    color: recipe.backgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: recipe.backgroundColor,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Heart Button on Featured Card
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  ref.read(savedRecipesProvider.notifier).toggleSave(recipe);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved
                            ? 'Removed "${recipe.title}" from Cookbook.'
                            : 'Added "${recipe.title}" to Cookbook.',
                        style: const TextStyle(fontFamily: 'PlusJakartaSans'),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color: isSaved ? const Color(0xFFEF4444) : Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.time,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.bar_chart_rounded,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.difficulty,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
    List<Recipe> savedRecipes,
  ) {
    final isSaved = savedRecipes.any((r) => r.title == recipe.title);

    return GestureDetector(
      onTap: () => _openRecipe(context, recipe),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                recipe.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: recipe.backgroundColor,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 24,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: recipe.backgroundColor,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 24,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.category,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.time,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.bar_chart_rounded,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.difficulty,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isSaved
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isSaved
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF9CA3AF),
                size: 20,
              ),
              onPressed: () {
                ref.read(savedRecipesProvider.notifier).toggleSave(recipe);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isSaved
                          ? 'Removed "${recipe.title}" from Cookbook.'
                          : 'Added "${recipe.title}" to Cookbook.',
                      style: const TextStyle(fontFamily: 'PlusJakartaSans'),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _openRecipe(BuildContext context, Recipe recipe) {
    Navigator.of(
      context,
    ).push(PageTransitions.slideFromRight(RecipeDetailsScreen(recipe: recipe)));
  }
}
