package com.redtea.minddrift

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display with modern API
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Set system bar appearance for better visibility (after super.onCreate)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                window.insetsController?.let { controller ->
                    controller.systemBarsBehavior = 
                        WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                }
            } catch (e: Exception) {
                // Fallback: ignore if insets controller is not available
            }
        }
    }
}
