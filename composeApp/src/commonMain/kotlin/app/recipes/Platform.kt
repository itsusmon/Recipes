package app.recipes

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform