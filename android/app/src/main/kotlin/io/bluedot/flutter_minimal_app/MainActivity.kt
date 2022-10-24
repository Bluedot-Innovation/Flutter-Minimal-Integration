package io.bluedot.flutter_minimal_app

import android.os.Bundle
import android.os.PersistableBundle
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    val appSecret = "APPCENTER_SECRET_ANDROID"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AppCenter.start(
            application, appSecret,
            Analytics::class.java,
            Crashes::class.java
        )
    }
}
