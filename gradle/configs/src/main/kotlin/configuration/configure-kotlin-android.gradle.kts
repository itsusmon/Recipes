import extensions.kotlinAndroid
import utils.Config

kotlinAndroid {
    val config = Config.requireInstance()
    compilerOptions {
        jvmTarget = config.jvmTarget
    }
}
