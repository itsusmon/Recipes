package utils

import org.gradle.api.JavaVersion
import org.gradle.api.Project
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

data class Config(
    val minSdk: Int,
    val targetSdk: Int,
    val compileSdk: Int,
    val versionCode: Int,
    val versionName: String,
    val javaVersion: JavaVersion,
    val jvmTarget: JvmTarget,
) {
    class Builder {
        var minSdk: Int = 26
        var targetSdk: Int = 33
        var compileSdk: Int = 33
        var versionCode: Int = 1
        var versionName: String = "1.0.0"
        var javaVersion: Int = 21
        var jvmTarget: Int = javaVersion

        internal fun build() = Config(
            minSdk = minSdk,
            targetSdk = targetSdk,
            compileSdk = compileSdk,
            versionCode = versionCode,
            versionName = versionName,
            javaVersion = JavaVersion.toVersion(javaVersion),
            jvmTarget = JvmTarget.fromTarget(jvmTarget.toString()),
        )
    }

    companion object {
        var instance: Config? = null

        fun requireInstance(): Config {
            return instance ?: error("Config not initialized")
        }
    }
}

fun Project.configs(block: Config.Builder.() -> Unit) {
    if (this != rootProject) {
        error("Cannot initialize Config from non-root project")
    }
    val builder = Config.Builder()
    Config.instance = builder.apply(block).build()
}
