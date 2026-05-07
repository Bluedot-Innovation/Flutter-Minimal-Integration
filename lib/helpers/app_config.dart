import 'package:flutter/services.dart';

class AppConfig {
  static const _channel = MethodChannel('io.bluedot.flutter_minimal_app/config');

  static Future<bool> isPushEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isPushEnabled');
      return result;
    } on PlatformException {
      return true; // default to enabled on error
    }
  }
}

