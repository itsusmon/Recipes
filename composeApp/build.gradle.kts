import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidApplication)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
    alias(libs.plugins.spotless)
    alias(libs.plugins.detekt)
}

kotlin {
    androidTarget {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }

    listOf(
        iosArm64(),
        iosSimulatorArm64(),
    ).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "ComposeApp"
            isStatic = true
        }
    }

    sourceSets {
        androidMain.dependencies {
            implementation(compose.preview)
            implementation(libs.androidx.activity.compose)
        }
        commonMain.dependencies {
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)
            implementation(compose.ui)
            implementation(compose.components.resources)
            implementation(compose.components.uiToolingPreview)
            implementation(libs.androidx.lifecycle.viewmodelCompose)
            implementation(libs.androidx.lifecycle.runtimeCompose)
            implementation(libs.voyager.navigator)
            implementation(libs.voyager.screenModel)
            implementation(libs.voyager.transitions)
            implementation(libs.voyager.koin)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }

    compilerOptions {
        optIn.add("kotlin.uuid.ExperimentalUuidApi")
    }
}

android {
    namespace = "app.recipes"
    compileSdk = property("android.compileSdk").toString().toInt()

    defaultConfig {
        applicationId = "app.recipes"
        minSdk = property("android.minSdk").toString().toInt()
        targetSdk = property("android.targetSdk").toString().toInt()
        versionCode = 1
        versionName = "1.0"
    }
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    debugImplementation(compose.uiTooling)
    detektPlugins(libs.detekt.formatting)
}

spotless {
    kotlin {
        target("**/*.kt")
        targetExclude("**/build/**/*.kt")
        if (project.hasProperty("spotlessFiles")) {
            target(project.property("spotlessFiles").toString().split(','))
        }
        ktlint(libs.versions.ktlint.get())
            .editorConfigOverride(
                mapOf(
                    "ktlint_standard_function-naming" to "disabled",
                ),
            )
        trimTrailingWhitespace()
        leadingTabsToSpaces()
        endWithNewline()
    }
    kotlinGradle {
        target("**/*.kts")
        targetExclude("**/build/**/*.kts")
        if (project.hasProperty("spotlessFiles")) {
            target(project.property("spotlessFiles").toString().split(','))
        }
        ktlint(libs.versions.ktlint.get())
        trimTrailingWhitespace()
        leadingTabsToSpaces()
        endWithNewline()
    }
}

// Configure Detekt
detekt {
    config.setFrom(rootProject.layout.projectDirectory.file("config/detekt/detekt.yml"))
    buildUponDefaultConfig = true
}
