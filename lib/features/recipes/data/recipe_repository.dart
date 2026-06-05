import 'package:palengkego/features/recipes/domain/recipe.dart';

abstract class RecipeRepository {
  List<Recipe> getRecipes();

  Recipe getFeaturedRecipe();

  List<Recipe> getMoreRecipes();
}
