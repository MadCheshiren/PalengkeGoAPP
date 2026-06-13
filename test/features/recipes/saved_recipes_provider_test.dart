import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/recipes/application/saved_recipes_provider.dart';
import 'package:palengkego/features/recipes/domain/recipe.dart';

void main() {
  group('SavedRecipesNotifier Tests', () {
    const testRecipe = Recipe(
      title: 'Sinigang na Hipon',
      category: 'Seafood',
      time: '30 min',
      difficulty: 'Easy',
      imageUrl:
          'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400&h=250&fit=crop',
      backgroundColor: Color(0xFFE0F2FE),
    );

    test('starts with an empty saved list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(savedRecipesProvider);
      expect(state, isEmpty);
    });

    test('toggles saving a recipe (saves a new recipe)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(savedRecipesProvider.notifier);
      expect(notifier.isSaved(testRecipe), isFalse);

      notifier.toggleSave(testRecipe);

      final state = container.read(savedRecipesProvider);
      expect(state, hasLength(1));
      expect(state.first.title, 'Sinigang na Hipon');
      expect(notifier.isSaved(testRecipe), isTrue);
    });

    test('toggles saving a recipe (removes an already saved recipe)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(savedRecipesProvider.notifier);
      notifier.toggleSave(testRecipe);
      expect(notifier.isSaved(testRecipe), isTrue);

      notifier.toggleSave(testRecipe);

      final state = container.read(savedRecipesProvider);
      expect(state, isEmpty);
      expect(notifier.isSaved(testRecipe), isFalse);
    });
  });
}
