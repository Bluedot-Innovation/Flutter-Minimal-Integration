package io.bluedot.flutter_minimal_app

import android.content.Intent
import android.os.Bundle
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    val appSecret = "APPCENTER_SECRET_ANDROID"
    private val CHANNEL = "io.bluedot.flutter_minimal_app/config"

    companion object {
        private const val FOREGROUND_SERVICE_CHANNEL = "io.bluedot.flutter_minimal_app/foreground_service"

        // This is "client app" code, not part of the bluedot_point_sdk plugin: the app is
        // responsible for implementing and owning its own foreground service, then linking
        // it to the Point SDK (see BluedotTrackingService).
        private var pendingStartResult: MethodChannel.Result? = null

        fun onBluedotTrackingServiceStartResult(error: Exception?) {
            val result = pendingStartResult
            pendingStartResult = null
            if (error == null) {
                result?.success(null)
            } else {
                result?.error("foreground_service_start_failed", error.message, error.toString())
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AppCenter.start(
            application, appSecret,
            Analytics::class.java,
            Crashes::class.java
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPushEnabled" -> result.success(BuildConfig.PUSH_ENABLED)
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FOREGROUND_SERVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> startBluedotTrackingService(result)
                    "stop" -> stopBluedotTrackingService(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun startBluedotTrackingService(result: MethodChannel.Result) {
        synchronized(MainActivity::class.java) {
            pendingStartResult?.error("start_superseded", "A newer start() call replaced this one", null)
            pendingStartResult = result
        }
        try {
            val intent = Intent(this, BluedotTrackingService::class.java)
            startForegroundService(intent)
        } catch (e: Exception) {
            onBluedotTrackingServiceStartResult(e)
        }
    }

    private fun stopBluedotTrackingService(result: MethodChannel.Result) {
        stopService(Intent(this, BluedotTrackingService::class.java))
        result.success(null)
    }
}
