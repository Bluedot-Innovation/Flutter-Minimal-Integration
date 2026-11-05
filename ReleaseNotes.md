# Flutter Minimal Integration v3.0.0 Release Notes

This release updates the app to **bluedot_point_sdk 3.0.0** and **bluedot_point_sdk_push 2.0.0**
(Point SDK **19.0.0** on Android), and migrates GeoTriggering and Tempo on Android to use the app's
own foreground service instead of one started by the SDK.

## App-owned foreground service (Android)

As of Point SDK 19.0.0, the SDK no longer starts or owns a foreground service or notification for
GeoTriggering or Tempo on Android. The host app is now responsible for declaring, starting and
foregrounding its own service, then linking it to the Point SDK.

This app demonstrates that migration:

- A new `BluedotTrackingService` is declared in `AndroidManifest.xml` with
  `foregroundServiceType="location"`, implemented in `BluedotTrackingService.kt`, and linked to the
  SDK via `BluedotForegroundServiceLinker.link()`/`unlink()`, which is exposed by the
  `bluedot_point_sdk` plugin itself.
- `MainActivity.kt` exposes a `foreground_service` method channel (`start`/`stop`) that the Dart side
  uses to start and stop the native service.
- A new `lib/helpers/foreground_service.dart` wraps that channel for use from Dart. On iOS this is a
  no-op, since the migration only affects Android.
- The **Geo-triggering** page starts the foreground service before starting GeoTriggering, and the
  "Start with notification" button is now **"Start with foreground service"**.
- The **Tempo** page starts the foreground service before starting Tempo tracking, and the
  `androidNotification()` builder call has been removed (no longer supported/needed).
- GeoTriggering and Tempo now share a single foreground service link. Stopping either feature only
  stops the service if the other one isn't still running, since stopping it would unlink both.
- If the foreground service becomes unlinked while Tempo is tracking, the Tempo page now shows a
  dedicated "Tempo Tracking Stopped: the foreground service is no longer linked" alert instead of a
  generic error.


## Requirements

- **iOS 15.6 or later**, or **Android 10 (API 29) or later**.
- A physical device is recommended for location-based testing.
- On Android, the `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_LOCATION` permissions must be granted
  (requested at runtime on Android 14+) for the app's foreground service to start successfully.
- Background location access is still required for GeoTriggering, Tempo and location-triggered push
  notifications to work while the app is not in the foreground.
- Campaigns must be published in Bluedot Canvas before push notifications can be delivered.
