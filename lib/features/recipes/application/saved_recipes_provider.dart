import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palengkego/features/recipes/domain/recipe.dart';
import 'package:palengkego/features/recipes/application/recipe_provider.dart';

class SavedRecipesNotifier extends Notifier<List<Recipe>> {
  static const _key = 'saved_recipes_titles';

  @override
  List<Recipe> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTitles = prefs.getStringList(_key) ?? [];
    if (savedTitles.isNotEmpty) {
      final allRecipes = await ref.read(recipeRepositoryProvider).getRecipes();
      state = allRecipes.where((r) => savedTitles.contains(r.title)).toList();
    }
  }

  Future<void> _save(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final titles = recipes.map((r) => r.title).toList();
    await prefs.setStringList(_key, titles);
  }

  bool isSaved(Recipe recipe) {
    return state.any((r) => r.title == recipe.title);
  }

  void toggleSave(Recipe recipe) {
    if (isSaved(recipe)) {
      state = state.where((r) => r.title != recipe.title).toList();
    } else {
      state = [...state, recipe];
    }
    _save(state);
  }
}

final savedRecipesProvider =
    NotifierProvider<SavedRecipesNotifier, List<Recipe>>(() {
      return SavedRecipesNotifier();
    });
