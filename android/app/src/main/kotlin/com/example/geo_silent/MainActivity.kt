package com.example.geo_silent

import android.app.NotificationManager
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val RINGER_CHANNEL = "com.geo_silent/ringer"
        const val SERVICE_CHANNEL = "com.geo_silent/service"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Ringer mode channel ───────────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RINGER_CHANNEL
        ).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

            when (call.method) {
                "setSilentMode" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                            !notificationManager.isNotificationPolicyAccessGranted
                        ) {
                            // Open DND settings so user can grant permission
                            startActivity(Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS))
                            result.error("PERMISSION_REQUIRED", "DND permission required", null)
                        } else {
                            audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "setVibrateMode" -> {
                    try {
                        audioManager.ringerMode = AudioManager.RINGER_MODE_VIBRATE
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "setNormalMode" -> {
                    try {
                        audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "getCurrentMode" -> {
                    result.success(audioManager.ringerMode)
                }
                "hasDndPermission" -> {
                    val has = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        notificationManager.isNotificationPolicyAccessGranted
                    } else true
                    result.success(has)
                }
                "requestDndPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS))
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ── Foreground service channel ────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SERVICE_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val zonesJson = call.argument<String>("zones") ?: "[]"
                    val intent = Intent(this, RingerService::class.java).apply {
                        action = RingerService.ACTION_START
                        putExtra(RingerService.EXTRA_ZONES, zonesJson)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                "stopService" -> {
                    val intent = Intent(this, RingerService::class.java).apply {
                        action = RingerService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(null)
                }
                "updateZones" -> {
                    val zonesJson = call.argument<String>("zones") ?: "[]"
                    val intent = Intent(this, RingerService::class.java).apply {
                        action = RingerService.ACTION_UPDATE_ZONES
                        putExtra(RingerService.EXTRA_ZONES, zonesJson)
                    }
                    startService(intent)
                    result.success(null)
                }
                "isRunning" -> {
                    result.success(RingerService.isRunning)
                }
                else -> result.notImplemented()
            }
        }
    }
}
