import org.jetbrains.kotlin.gradle.dsl.KotlinProjectExtension

configure<KotlinProjectExtension> {
    sourceSets.all {
        languageSettings {
            optIn("kotlin.uuid.ExperimentalUuidApi")
        }
    }
}
