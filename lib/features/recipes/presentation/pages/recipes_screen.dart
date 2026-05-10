import 'package:flutter/material.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'recipe_details_screen.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = [
      {
        'title': 'Sinigang na Hipon',
        'category': 'Seafood',
        'time': '30 min',
        'difficulty': 'Easy',
        'image':
            'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400&h=250&fit=crop',
        'bgColor': const Color(0xFFE0F2FE),
      },
      {
        'title': 'Chicken Adobo',
        'category': 'Chicken',
        'time': '45 min',
        'difficulty': 'Medium',
        'image':
            'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400&h=250&fit=crop',
        'bgColor': const Color(0xFFFEE2E2),
      },
      {
        'title': 'Ginisang Ampalaya',
        'category': 'Vegetables',
        'time': '20 min',
        'difficulty': 'Easy',
        'image':
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=250&fit=crop',
        'bgColor': const Color(0xFFDCFCE7),
      },
      {
        'title': 'Pork Sinigang',
        'category': 'Pork',
        'time': '60 min',
        'difficulty': 'Medium',
        'image':
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=250&fit=crop',
        'bgColor': const Color(0xFFFEF3C7),
      },
      {
        'title': 'Fresh Lumpia',
        'category': 'Appetizer',
        'time': '40 min',
        'difficulty': 'Hard',
        'image':
            'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=400&h=250&fit=crop',
        'bgColor': const Color(0xFFF3E8FF),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Recipes',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B4332),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cook with fresh ingredients\nfrom your local market',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Featured recipe
                    Text(
                      'Featured Recipe',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeaturedRecipe(context, recipes[0]),
                    const SizedBox(height: 24),
                    // All recipes
                    Text(
                      'More Recipes',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipes.length - 1,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRecipeCard(context, recipes[index + 1]),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedRecipe(BuildContext context, Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageTransitions.slideFromRight(
            RecipeDetailsScreen(
              recipe: {
                'name': recipe['title'],
                'imageUrl': recipe['image'],
                'description': '${recipe['category']} • ${recipe['difficulty']} • ${recipe['time']}',
                'time': recipe['time'],
              },
            ),
          ),
        );
      },
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
                recipe['image'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    color: recipe['bgColor'] as Color,
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
                    color: recipe['bgColor'] as Color,
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
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
            ),
            // Content overlay
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
                      recipe['category'],
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
                    recipe['title'],
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
                        recipe['time'],
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
                        recipe['difficulty'],
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

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageTransitions.slideFromRight(
            RecipeDetailsScreen(
              recipe: {
                'name': recipe['title'],
                'imageUrl': recipe['image'],
                'description': '${recipe['category']} • ${recipe['difficulty']} • ${recipe['time']}',
                'time': recipe['time'],
              },
            ),
          ),
        );
      },
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
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                recipe['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: recipe['bgColor'] as Color,
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
                    color: recipe['bgColor'] as Color,
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
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'],
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe['category'],
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
                        recipe['time'],
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
                        recipe['difficulty'],
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
}
