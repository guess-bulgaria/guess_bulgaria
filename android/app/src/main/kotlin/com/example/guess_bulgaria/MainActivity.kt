package com.example.guess_bulgaria

import android.app.ActionBar
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val bar: ActionBar? = actionBar
        bar?.setBackgroundDrawable(ColorDrawable(0xFF0b6e4f.toInt()))
    }
}
