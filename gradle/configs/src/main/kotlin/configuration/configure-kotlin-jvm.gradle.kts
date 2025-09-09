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
}
