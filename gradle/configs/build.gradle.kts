plugins {
    `kotlin-dsl`
}

dependencies {
    compileOnly(gradleApi())
    compileOnly(libs.plugin.android)
    compileOnly(libs.plugin.kotlin)
    compileOnly(libs.plugin.spotless)
}
