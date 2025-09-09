package app.recipes.feature.recipe.api.details

import cafe.adriel.voyager.core.screen.Screen
import kotlin.uuid.Uuid

interface RecipeDetailsScreen : Screen {
    val recipeId: Uuid
}
