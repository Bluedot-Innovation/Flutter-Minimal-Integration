import 'package:flutter/services.dart';

class AppConfig {
  static const _channel = MethodChannel('io.bluedot.flutter_minimal_app/config');

  static Future<bool> isPushEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isPushEnabled');
      return result;
    } on Exception {
      return false; // default to disabled on error, consistent with Info.plist
    }
  }
}

