import 'package:flutter/material.dart';
import 'package:palengkego/features/recipes/domain/recipe.dart';

class RecipeIngredientsList extends StatelessWidget {
  final Recipe recipe;
  final Set<String> checkedIngredients;
  final ValueChanged<String> onIngredientToggled;

  const RecipeIngredientsList({
    super.key,
    required this.recipe,
    required this.checkedIngredients,
    required this.onIngredientToggled,
  });

  @override
  Widget build(BuildContext context) {
    final ingredients = recipe.ingredients ?? _defaultIngredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${ingredients.length} Items',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B372B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingredients.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ingredient = ingredients[index];
            final name = ingredient.name;
            final description = ingredient.description;
            final imageUrl = ingredient.imageUrl;
            final isChecked = checkedIngredients.contains(name);

            return GestureDetector(
              onTap: () => onIngredientToggled(name),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isChecked ? const Color(0xFF0B372B) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Checkbox
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isChecked ? const Color(0xFF0B372B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isChecked ? const Color(0xFF0B372B) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isChecked ? const Color(0xFF0B372B) : const Color(0xFF1F2937),
                              decoration: isChecked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Ingredient image
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 48,
                            height: 48,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.image, size: 20, color: Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Default data for demo
  static final List<RecipeIngredient> _defaultIngredients = [
    const RecipeIngredient(name: 'Bangus (Milkfish)', description: '1 large, sliced into 3-4 pieces'),
    const RecipeIngredient(name: 'Kangkong (Water Spinach)', description: '2 bunches, trimmed and washed'),
    const RecipeIngredient(name: 'Tamarind', description: 'Fresh/powder: 1/2 cup mix'),
    const RecipeIngredient(name: 'Tomato', description: 'One piece, quartered'),
    const RecipeIngredient(name: 'Onion', description: '1 medium, sliced'),
    const RecipeIngredient(name: 'Radish', description: '1 small, sliced thinly'),
    const RecipeIngredient(name: 'Chili (Siling Habà)', description: '2-3 pieces for heat'),
  ];
}
