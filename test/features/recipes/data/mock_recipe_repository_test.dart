import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/features/recipes/data/mock_recipe_repository.dart';

void main() {
  group('MockRecipeRepository', () {
    test('returns featured recipe first', () {
      final repository = MockRecipeRepository();

      final recipe = repository.getFeaturedRecipe();

      expect(recipe.title, 'Sinigang na Hipon');
      expect(recipe.category, 'Seafood');
      expect(recipe.time, '30 min');
      expect(recipe.backgroundColor, const Color(0xFFE0F2FE));
    });

    test('returns all recipes in display order', () {
      final repository = MockRecipeRepository();

      final recipes = repository.getRecipes();

      expect(recipes, hasLength(5));
      expect(recipes.first.title, 'Sinigang na Hipon');
      expect(recipes.last.title, 'Fresh Lumpia');
    });

    test('returns more recipes without the featured recipe', () {
      final repository = MockRecipeRepository();

      final recipes = repository.getMoreRecipes();

      expect(recipes, hasLength(4));
      expect(
        recipes.any((recipe) => recipe.title == 'Sinigang na Hipon'),
        isFalse,
      );
      expect(recipes.first.title, 'Chicken Adobo');
    });

    test('creates details map compatible with recipe details screen', () {
      final repository = MockRecipeRepository();

      final recipe = repository.getFeaturedRecipe();
      final details = recipe.toDetailsMap();

      expect(details['name'], 'Sinigang na Hipon');
      expect(details['imageUrl'], recipe.imageUrl);
      expect(details['description'], 'Seafood • Easy • 30 min');
      expect(details['time'], '30 min');
    });
  });
}
