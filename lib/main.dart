import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bluedot_point_sdk_push/bluedot_point_sdk_push.dart';
import 'geo_triggering_page.dart';
import 'helpers/push_notification_manager.dart';
import 'home_page.dart';
import 'initial_page.dart';
import 'push_notifications_page.dart';
import 'tempo_page.dart';

/// Whether push-notifications is enabled in this build.
/// Set via --dart-define=PUSH_ENABLED=true|false (driven by gradle.properties).
const bool _pushEnabled = bool.fromEnvironment('PUSH_ENABLED', defaultValue: true);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override

  void initState() {
    super.initState();
    // Request permissions for location and notification
    _requestPermission();

    // Register push notification listener when Firebase is enabled.
    // In default mode the plugin's DefaultMessagingService automatically
    // handles FCM token updates and message delivery — no extra wiring needed.
    if (_pushEnabled) {
      _setupPushListener();
    }
  }

  void _setupPushListener() {
    BluedotPointSdkPush.instance.setNotificationListener(
      onReceived: (data) {
        PushNotificationManager.instance.addEvent(
          PushNotificationEvent.fromMap('received', data),
        );
      },
      onClicked: (data) {
        PushNotificationManager.instance.addEvent(
          PushNotificationEvent.fromMap('clicked', data),
        );
      },
    );
  }

  void _requestPermission() async {
    await Permission.locationWhenInUse.request();
    await Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Minimal App',
      routes: {
        '/': (context) => const InitialPage(),
        '/home': (context) => const HomePage(),
        '/geo-triggering': (context) => const GeoTriggeringPage(),
        '/tempo': (context) => const TempoPage(),
        '/push-notifications': (context) => const PushNotificationsPage(),
      },
    );
  }
}
