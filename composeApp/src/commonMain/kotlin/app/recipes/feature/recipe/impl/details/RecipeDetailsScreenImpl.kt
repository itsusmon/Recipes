package app.recipes.feature.recipe.impl.details

import androidx.compose.runtime.Composable
import app.recipes.feature.recipe.api.details.RecipeDetailsScreen
import kotlin.uuid.Uuid

internal class RecipeDetailsScreenImpl(
    override val recipeId: Uuid,
) : RecipeDetailsScreen {

    @Composable
    override fun Content() {

    }
}
