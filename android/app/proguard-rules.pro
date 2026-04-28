# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Suppress warnings for Flutter Play Store deferred components (not used in this app)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# AppCenter
-keep class com.microsoft.appcenter.** { *; }

# Bluedot PointSDK
-keep class au.com.bluedot.** { *; }

# WorkManager - prevent R8 from removing generated database implementations
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }

