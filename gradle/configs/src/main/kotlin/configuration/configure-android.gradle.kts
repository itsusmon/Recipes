import com.android.build.gradle.BaseExtension
import extensions.isAndroidApplicationModule
import extensions.isAndroidLibraryModule
import extensions.isMultiplatformModule
import utils.Config

configure<BaseExtension> {
    val config = Config.requireInstance()

    compileSdkVersion(config.compileSdk)
    defaultConfig {
        minSdk = config.minSdk

        if (isAndroidApplicationModule()) {
            targetSdk = config.targetSdk
            versionCode = config.versionCode
            versionName = config.versionName
        }

        if (isAndroidLibraryModule()) {
            val proguardFilename = "consumer-rules.pro"
            if (layout.projectDirectory.file(proguardFilename).asFile.exists()) {
                consumerProguardFile(proguardFilename)
            }
        }
    }

    compileOptions {
        sourceCompatibility = config.javaVersion
        targetCompatibility = config.javaVersion
    }

    testOptions {
        unitTests.all(Test::useJUnitPlatform)
    }

    if (isMultiplatformModule()) {
        sourceSets["main"].manifest.srcFile("src/androidMain/AndroidManifest.xml")
    }
}
