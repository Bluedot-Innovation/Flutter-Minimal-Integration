package io.bluedot.flutter_minimal_app

import android.os.Bundle
import android.os.PersistableBundle
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    val appSecret = "APPCENTER_SECRET_ANDROID"
    private val CHANNEL = "io.bluedot.flutter_minimal_app/config"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AppCenter.start(
            application, appSecret,
            Analytics::class.java,
            Crashes::class.java
        )
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPushEnabled" -> result.success(BuildConfig.PUSH_ENABLED)
                else -> result.notImplemented()
            }
        }
    }
}
