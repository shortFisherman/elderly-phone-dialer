package com.elderly.phone_call2

import android.content.Intent
import android.net.Uri
import android.media.AudioManager
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.elderly.phone_call2/phone"
    private var speakerphoneListener: PhoneStateListener? = null

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
                        setupSpeakerphoneOnCall()

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

    private fun setupSpeakerphoneOnCall() {
        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager

        speakerphoneListener = object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                when (state) {
                    TelephonyManager.CALL_STATE_OFFHOOK -> {
                        // Call connected — enable speakerphone
                        audioManager.mode = AudioManager.MODE_IN_CALL
                        audioManager.isSpeakerphoneOn = true
                    }
                    TelephonyManager.CALL_STATE_IDLE -> {
                        // Call ended — reset and remove listener
                        audioManager.isSpeakerphoneOn = false
                        audioManager.mode = AudioManager.MODE_NORMAL
                        telephonyManager.listen(
                            this, PhoneStateListener.LISTEN_NONE
                        )
                        speakerphoneListener = null
                    }
                }
            }
        }

        telephonyManager.listen(
            speakerphoneListener,
            PhoneStateListener.LISTEN_CALL_STATE
        )
    }

    override fun onDestroy() {
        speakerphoneListener?.let {
            try {
                val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
                telephonyManager.listen(it, PhoneStateListener.LISTEN_NONE)
            } catch (_: Exception) {}
            speakerphoneListener = null
        }
        super.onDestroy()
    }
}
