package com.example.geo_silent

import android.app.*
import android.content.Context
import android.content.Intent
import android.location.Location
import android.media.AudioManager
import android.os.Build
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import org.json.JSONArray

class RingerService : Service() {

    companion object {
        const val CHANNEL_ID = "geo_silent_channel"
        const val NOTIFICATION_ID = 1
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
        const val ACTION_UPDATE_ZONES = "ACTION_UPDATE_ZONES"
        const val EXTRA_ZONES = "EXTRA_ZONES"

        // Shared state accessible from MainActivity via platform channel
        var zones: List<ZoneData> = emptyList()
        var isRunning = false
    }

    data class ZoneData(
        val lat: Double,
        val lng: Double,
        val radius: Double,
        val soundProfile: Int // 0=silent, 1=vibration, 2=normal
    )

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private lateinit var audioManager: AudioManager
    private var previousRingerMode: Int = AudioManager.RINGER_MODE_NORMAL
    private var isInSilentZone = false

    override fun onCreate() {
        super.onCreate()
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel()
        setupLocationCallback()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val zonesJson = intent.getStringExtra(EXTRA_ZONES)
                if (zonesJson != null) {
                    zones = parseZones(zonesJson)
                }
                startForeground(NOTIFICATION_ID, buildNotification("Monitoring ${zones.size} zone(s)..."))
                startLocationUpdates()
                isRunning = true
            }
            ACTION_STOP -> {
                stopLocationUpdates()
                restoreNormalMode()
                isRunning = false
                stopSelf()
            }
            ACTION_UPDATE_ZONES -> {
                val zonesJson = intent.getStringExtra(EXTRA_ZONES)
                if (zonesJson != null) {
                    zones = parseZones(zonesJson)
                }
                updateNotification("Monitoring ${zones.size} zone(s)...")
            }
        }
        return START_STICKY
    }

    private fun setupLocationCallback() {
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                val location = result.lastLocation ?: return
                checkZones(location)
            }
        }
    }

    private fun startLocationUpdates() {
        val request = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 10_000L)
            .setMinUpdateDistanceMeters(10f)
            .build()

        try {
            fusedLocationClient.requestLocationUpdates(
                request,
                locationCallback,
                Looper.getMainLooper()
            )
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }

    private fun stopLocationUpdates() {
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }

    private fun checkZones(location: Location) {
        var enteredZone: ZoneData? = null

        for (zone in zones) {
            val results = FloatArray(1)
            Location.distanceBetween(
                location.latitude, location.longitude,
                zone.lat, zone.lng,
                results
            )
            if (results[0] <= zone.radius) {
                enteredZone = zone
                break
            }
        }

        if (enteredZone != null && !isInSilentZone) {
            // Entered a zone — save current mode and apply zone mode
            isInSilentZone = true
            previousRingerMode = audioManager.ringerMode
            applyRingerMode(enteredZone.soundProfile)
            updateNotification("🔕 Silent zone active")
        } else if (enteredZone == null && isInSilentZone) {
            // Left all zones — restore previous mode
            isInSilentZone = false
            restoreNormalMode()
            updateNotification("Monitoring ${zones.size} zone(s)...")
        }
    }

    private fun applyRingerMode(profile: Int) {
        try {
            // Request DND permission if needed
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !notificationManager.isNotificationPolicyAccessGranted) {
                // Can't control DND — fall back to vibrate
                audioManager.ringerMode = AudioManager.RINGER_MODE_VIBRATE
                return
            }
            audioManager.ringerMode = when (profile) {
                0 -> AudioManager.RINGER_MODE_SILENT
                1 -> AudioManager.RINGER_MODE_VIBRATE
                else -> AudioManager.RINGER_MODE_NORMAL
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun restoreNormalMode() {
        try {
            audioManager.ringerMode = previousRingerMode
        } catch (e: Exception) {
            audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
        }
    }

    private fun parseZones(json: String): List<ZoneData> {
        val result = mutableListOf<ZoneData>()
        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                if (obj.optBoolean("isActive", true)) {
                    result.add(
                        ZoneData(
                            lat = obj.getDouble("latitude"),
                            lng = obj.getDouble("longitude"),
                            radius = obj.getDouble("radius"),
                            soundProfile = obj.optInt("soundProfile", 0)
                        )
                    )
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return result
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Geo Silent",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Geo Silent zone monitoring"
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(text: String): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Geo Silent")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_lock_silent_mode)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun updateNotification(text: String) {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, buildNotification(text))
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopLocationUpdates()
        restoreNormalMode()
        isRunning = false
        super.onDestroy()
    }
}
