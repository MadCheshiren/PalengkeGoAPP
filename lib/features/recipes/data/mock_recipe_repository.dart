import 'package:flutter/material.dart';
import 'package:palengkego/features/recipes/data/recipe_repository.dart';
import 'package:palengkego/features/recipes/domain/recipe.dart';

class MockRecipeRepository implements RecipeRepository {
  static const _recipes = <Recipe>[
    Recipe(
      title: 'Sinigang na Hipon',
      category: 'Seafood',
      time: '30 min',
      difficulty: 'Easy',
      imageUrl:
          'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400&h=250&fit=crop',
      backgroundColor: Color(0xFFE0F2FE),
    ),
    Recipe(
      title: 'Chicken Adobo',
      category: 'Chicken',
      time: '45 min',
      difficulty: 'Medium',
      imageUrl:
          'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400&h=250&fit=crop',
      backgroundColor: Color(0xFFFEE2E2),
    ),
    Recipe(
      title: 'Ginisang Ampalaya',
      category: 'Vegetables',
      time: '20 min',
      difficulty: 'Easy',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=250&fit=crop',
      backgroundColor: Color(0xFFDCFCE7),
    ),
    Recipe(
      title: 'Pork Sinigang',
      category: 'Pork',
      time: '60 min',
      difficulty: 'Medium',
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=250&fit=crop',
      backgroundColor: Color(0xFFFEF3C7),
    ),
    Recipe(
      title: 'Fresh Lumpia',
      category: 'Appetizer',
      time: '40 min',
      difficulty: 'Hard',
      imageUrl:
          'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=400&h=250&fit=crop',
      backgroundColor: Color(0xFFF3E8FF),
    ),
  ];

  @override
  List<Recipe> getRecipes() {
    return List<Recipe>.unmodifiable(_recipes);
  }

  @override
  Recipe getFeaturedRecipe() {
    return _recipes.first;
  }

  @override
  List<Recipe> getMoreRecipes() {
    return List<Recipe>.unmodifiable(_recipes.skip(1));
  }
}
