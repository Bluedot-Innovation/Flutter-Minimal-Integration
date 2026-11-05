package io.bluedot.flutter_minimal_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import io.bluedot.bluedot_point_sdk.BluedotForegroundServiceLinker

/**
 * App-owned foreground service.
 *
 * Since Point SDK 19.0.0 the SDK no longer starts or owns a foreground service or
 * notification for GeoTriggering/Tempo. The host app is responsible for implementing,
 * starting, and foregrounding its own [Service], then linking it to the SDK via
 * [BluedotForegroundServiceLinker.link] (and unlinking it via
 * [BluedotForegroundServiceLinker.unlink] when it stops).
 *
 * [BluedotForegroundServiceLinker] is exposed by the bluedot_point_sdk plugin itself, so this
 * app does **not** need its own `point_sdk_android` Gradle dependency just to link/unlink the
 * foreground service - avoiding the SDK version staying in sync in two separate places.
 *
 * GeoTriggering and Tempo share a single link state, so one service/link is enough even
 * if the app uses both features.
 */
class BluedotTrackingService : Service() {

    companion object {
        private const val TAG = "BluedotTrackingService"
        private const val NOTIFICATION_ID = 9001
        private const val CHANNEL_ID = "Bluedot Flutter"
    }

    private var startError: Exception? = null

    override fun onCreate() {
        super.onCreate()
        try {
            startForeground(NOTIFICATION_ID, buildNotification())
            BluedotForegroundServiceLinker.link(applicationContext)
        } catch (e: Exception) {
            // startForeground can throw on API 31+ if called from the background, or on
            // API 34+ if the FOREGROUND_SERVICE_LOCATION permission is missing.
            Log.e(TAG, "Failed to start foreground service", e)
            startError = e
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Runs after onCreate() on the first start and on every subsequent start, so the
        // Dart caller is always notified once the link has (or hasn't) happened.
        MainActivity.onBluedotTrackingServiceStartResult(startError)
        if (startError != null) {
            stopSelf()
            return START_NOT_STICKY
        }
        return START_STICKY
    }

    override fun onDestroy() {
        if (startError == null) {
            BluedotForegroundServiceLinker.unlink(applicationContext)
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun buildNotification(): Notification {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)
            if (notificationManager.getNotificationChannel(CHANNEL_ID) == null) {
                notificationManager.createNotificationChannel(
                    NotificationChannel(CHANNEL_ID, "Bluedot Flutter", NotificationManager.IMPORTANCE_LOW)
                )
            }
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Bluedot Foreground Service")
                .setContentText("This app is running a foreground service using location services")
                .setSmallIcon(android.R.drawable.ic_menu_mylocation)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("Bluedot Foreground Service")
                .setSmallIcon(android.R.drawable.ic_menu_mylocation)
                .build()
        }
    }
}
