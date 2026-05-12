package com.elderly.phone_call2

import android.content.Intent
import android.net.Uri
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.elderly.phone_call2/phone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "call") {
                    val phoneNumber = call.argument<String>("phoneNumber") ?: ""
                    if (phoneNumber.isEmpty()) {
                        result.error("INVALID_NUMBER", "Phone number is empty", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                        audioManager.mode = AudioManager.MODE_IN_CALL
                        audioManager.isSpeakerphoneOn = true

                        val intent = Intent(Intent.ACTION_CALL)
                        intent.data = Uri.parse("tel:$phoneNumber")
                        startActivity(intent)

                        result.success(true)
                    } catch (e: SecurityException) {
                        result.error("PERMISSION_DENIED", "CALL_PHONE permission not granted", null)
                    } catch (e: Exception) {
                        result.error("CALL_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
