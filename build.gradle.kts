import extensions.intProperty
import extensions.requiredProperty
import utils.configs

plugins {
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.androidLibrary) apply false
    alias(libs.plugins.composeMultiplatform) apply false
    alias(libs.plugins.composeCompiler) apply false
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.spotless) apply false
    id("project-config")
}

configs {
    minSdk = intProperty("android.minSdk")
    targetSdk = intProperty("android.targetSdk")
    compileSdk = intProperty("android.compileSdk")
    versionCode = intProperty("version.code")
    versionName = requiredProperty("version.name")
}
