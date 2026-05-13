package com.elderly.phone_call2

import android.content.Context
import android.content.Intent
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.elderly.phone_call2/phone"
    private val handler = Handler(Looper.getMainLooper())
    private var speakerphoneRunnable: Runnable? = null

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
                        startSpeakerphoneLoop()

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

    /**
     * Starts a repeating attempt to enable speakerphone.
     * Tries every 800ms, up to 15 attempts (~12 seconds).
     *
     * Uses every available API at once, because Android OEMs differ in which
     * one they actually respect during a cellular call:
     *   - setSpeakerphoneOn()        (deprecated in 31+, but still works on some)
     *   - setCommunicationDevice()   (API 31+, works on some)
     *   - AudioSystem.setForceUse()  (hidden API, works on some OEMs)
     */
    private fun startSpeakerphoneLoop() {
        stopSpeakerphoneLoop()
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxAttempts = 15
        val intervalMs = 800L

        val runnable = object : Runnable {
            var attempt = 0

            override fun run() {
                if (attempt >= maxAttempts) return
                attempt++

                // 1. Always try setSpeakerphoneOn — still functional on many devices
                audioManager.mode = AudioManager.MODE_IN_CALL
                audioManager.isSpeakerphoneOn = true

                // 2. API 31+: also try setCommunicationDevice
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val speaker = audioManager.availableCommunicationDevices
                        .firstOrNull { it.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER }
                    if (speaker != null) {
                        audioManager.setCommunicationDevice(speaker)
                    }
                }

                // 3. Try hidden API AudioSystem.setForceUse(FOR_COMMUNICATION, FORCE_SPEAKER)
                trySetForceSpeaker()

                // Continue if speakerphone still not active
                if (!audioManager.isSpeakerphoneOn && attempt < maxAttempts) {
                    handler.postDelayed(this, intervalMs)
                }
            }
        }
        speakerphoneRunnable = runnable
        handler.postDelayed(runnable, 1000) // first delay: wait for call to start connecting
    }

    private fun stopSpeakerphoneLoop() {
        speakerphoneRunnable?.let { handler.removeCallbacks(it) }
        speakerphoneRunnable = null
    }

    /**
     * Uses reflection to call the hidden API:
     *   android.media.AudioSystem.setForceUse(FOR_COMMUNICATION, FORCE_SPEAKER)
     *
     * This is a private Android API, but it's the lowest-level way to force
     * audio routing to speaker. Works on many OEM devices even when the
     * public APIs are blocked.
     */
    private fun trySetForceSpeaker() {
        try {
            val audioSystemClass = Class.forName("android.media.AudioSystem")
            val setForceUse = audioSystemClass.getMethod("setForceUse", Int::class.javaPrimitiveType!!, Int::class.javaPrimitiveType!!)
            // FOR_COMMUNICATION = 1, FORCE_SPEAKER = 1
            setForceUse.invoke(null, 1, 1)
        } catch (_: Exception) {
            // Hidden API blocked or not available — ignore
        }
    }

    override fun onDestroy() {
        stopSpeakerphoneLoop()
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            audioManager.isSpeakerphoneOn = false
            audioManager.mode = AudioManager.MODE_NORMAL
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
