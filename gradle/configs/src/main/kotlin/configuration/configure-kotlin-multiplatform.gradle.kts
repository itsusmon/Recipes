import extensions.kotlinMultiplatform
import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinAndroidTarget
import utils.Config

@OptIn(ExperimentalKotlinGradlePluginApi::class)
kotlinMultiplatform {
    val config = Config.requireInstance()

    applyDefaultHierarchyTemplate {
        common {
            group("commonJvm") {
                withCompilations {
                    it.target.targetName == "desktop" || it.target is KotlinAndroidTarget
                }
            }
            group("nonAndroid") {
                withNative()
                withCompilations {
                    it.target.targetName == "desktop"
                }
            }
        }
    }

    androidTarget {
        compilerOptions {
            jvmTarget = config.jvmTarget
        }
    }
    jvm("desktop") {
        compilerOptions {
            jvmTarget = config.jvmTarget
        }
    }

    macosX64()
    macosArm64()

    iosArm64()
    iosX64()
    iosSimulatorArm64()

    compilerOptions {
        freeCompilerArgs.add("-Xexpect-actual-classes")
    }
}
