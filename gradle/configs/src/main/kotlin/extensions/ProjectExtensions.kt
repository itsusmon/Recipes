package extensions

import org.gradle.api.Project
import org.gradle.kotlin.dsl.configure
import org.jetbrains.kotlin.gradle.dsl.KotlinAndroidExtension
import org.jetbrains.kotlin.gradle.dsl.KotlinMultiplatformExtension
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget

fun Project.hasPlugin(id: String) = plugins.hasPlugin(id)

fun Project.isAndroidLibraryModule(): Boolean = hasPlugin("com.android.library")

fun Project.isAndroidApplicationModule(): Boolean = hasPlugin("com.android.application")

fun Project.isMultiplatformModule() = hasPlugin("org.jetbrains.kotlin.multiplatform")

fun Project.kotlinMultiplatform(block: KotlinMultiplatformExtension.() -> Unit) =
    extensions.configure<KotlinMultiplatformExtension>(block)

fun Project.kotlinAndroid(block: KotlinAndroidExtension.() -> Unit) =
    extensions.configure<KotlinAndroidExtension>(block)

fun KotlinMultiplatformExtension.configureAppleTargets(block: KotlinNativeTarget.() -> Unit) {
    targets.filterIsInstance<KotlinNativeTarget>().forEach { target ->
        if (target.konanTarget.family.isAppleFamily) block(target)
    }
}
