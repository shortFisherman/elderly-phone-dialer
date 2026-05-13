package com.elderly.phone_call2

import android.content.Context
import android.content.Intent
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.elderly.phone_call2/phone"
    private var speakerphoneEnabler: SpeakerphoneEnabler? = null

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
                        speakerphoneEnabler = SpeakerphoneEnabler(this)
                        speakerphoneEnabler?.start()

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

    override fun onDestroy() {
        speakerphoneEnabler?.stop()
        speakerphoneEnabler = null
        super.onDestroy()
    }
}

/**
 * Listens for call state changes and enables speakerphone when the call connects.
 *
 * Uses the correct API based on Android version:
 * - API 31+ (Android 12): [AudioManager.setCommunicationDevice] with built-in speaker.
 *   [AudioManager.setSpeakerphoneOn] is deprecated and non-functional from API 31.
 * - API 21-30: [AudioManager.setSpeakerphoneOn] with MODE_IN_CALL (still works).
 */
class SpeakerphoneEnabler(private val activity: MainActivity) {
    private val audioManager: AudioManager
        get() = activity.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val telephonyManager: TelephonyManager
        get() = activity.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
    private val handler = Handler(Looper.getMainLooper())
    private var callConnected = false
    private var retryCount = 0

    private val phoneStateListener = object : PhoneStateListener() {
        override fun onCallStateChanged(state: Int, phoneNumber: String?) {
            when (state) {
                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    callConnected = true
                    enableSpeakerphone()
                }
                TelephonyManager.CALL_STATE_IDLE -> {
                    if (callConnected) {
                        callConnected = false
                        resetAudio()
                    }
                }
            }
        }
    }

    fun start() {
        try {
            telephonyManager.listen(
                phoneStateListener,
                PhoneStateListener.LISTEN_CALL_STATE
            )
        } catch (_: SecurityException) {
            // READ_PHONE_STATE not granted — try delayed approach as fallback.
            handler.postDelayed({ enableSpeakerphone() }, 1500)
            handler.postDelayed({ enableSpeakerphone() }, 3000)
        }
    }

    fun stop() {
        try {
            telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        } catch (_: Exception) {}
        handler.removeCallbacksAndMessages(null)
        if (callConnected) {
            resetAudio()
        }
    }

    private fun enableSpeakerphone() {
        val am = audioManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // API 31+: setCommunicationDevice() is the replacement for setSpeakerphoneOn()
            am.mode = AudioManager.MODE_IN_COMMUNICATION

            val speaker = am.availableCommunicationDevices
                .firstOrNull { it.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER }

            if (speaker != null) {
                am.setCommunicationDevice(speaker)
            }

            // On some devices setCommunicationDevice reports success but doesn't route
            // audio. Retry a few times as a workaround.
            if (!am.isSpeakerphoneOn && retryCount < 5) {
                retryCount++
                handler.postDelayed({ enableSpeakerphone() }, 1000)
            }
        } else {
            // API 21-30: original API still works
            am.mode = AudioManager.MODE_IN_CALL
            am.isSpeakerphoneOn = true
        }
    }

    private fun resetAudio() {
        val am = audioManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            am.clearCommunicationDevice()
        }
        am.isSpeakerphoneOn = false
        am.mode = AudioManager.MODE_NORMAL
    }
}
