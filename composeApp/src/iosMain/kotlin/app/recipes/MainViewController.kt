package app.recipes

import androidx.compose.ui.window.ComposeUIViewController

@Suppress("unused", "FunctionName") // Called from Swift
fun MainViewController() = ComposeUIViewController(
    configure = {
    },
    content = {
        App()
    },
)
