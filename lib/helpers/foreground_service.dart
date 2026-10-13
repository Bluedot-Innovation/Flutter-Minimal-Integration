import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Bridges to this app's own native Android foreground service
/// (`BluedotTrackingService.kt`), registered directly in the example app's
/// `MainActivity.kt` — this is "client app" code, not part of the
/// `bluedot_point_sdk` plugin.
///
/// Since Point SDK 19.0.0 the SDK no longer starts or owns a foreground
/// service/notification. The app must start and foreground its own service,
/// which links itself to the Point SDK (see `BluedotTrackingService.onCreate`).
/// [startForegroundService] resolves once the service is in the foreground
/// and linked, so it's safe to start GeoTriggering/Tempo afterwards.
class ForegroundService {
  static const _channel = MethodChannel('io.bluedot.flutter_minimal_app/foreground_service');

  static Future<void> start() {
    if (!Platform.isAndroid) return Future.value();
    return _channel.invokeMethod('start');
  }

  static Future<void> stop() {
    if (!Platform.isAndroid) return Future.value();
    return _channel.invokeMethod('stop');
  }
}
