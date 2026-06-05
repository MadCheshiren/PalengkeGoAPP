import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/recipes/domain/recipe.dart';

class SavedRecipesNotifier extends Notifier<List<Recipe>> {
  @override
  List<Recipe> build() {
    return [];
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
  }
}

final savedRecipesProvider = NotifierProvider<SavedRecipesNotifier, List<Recipe>>(() {
  return SavedRecipesNotifier();
});
