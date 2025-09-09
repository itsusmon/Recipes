import com.diffplug.gradle.spotless.SpotlessExtension

plugins.apply("com.diffplug.spotless")

configure<SpotlessExtension> {
    val libs = extensions.getByType<VersionCatalogsExtension>().named("libs")

    kotlin {
        target("**/*.kt")
        targetExclude("**/build/**/*.kt")
        ktlint(libs.findVersion("ktlint").get().toString())
            .editorConfigOverride(
                mapOf(
                    "ktlint_standard_function-naming" to "disabled",
                )
            )
        trimTrailingWhitespace()
        leadingTabsToSpaces()
        endWithNewline()
    }
    kotlinGradle {
        target("**/*.kts")
        targetExclude("**/build/**/*.kts")
        ktlint(libs.findVersion("ktlint").get().toString())
        trimTrailingWhitespace()
        leadingTabsToSpaces()
        endWithNewline()
    }
}
