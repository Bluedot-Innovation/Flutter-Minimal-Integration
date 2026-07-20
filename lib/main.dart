import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bluedot_point_sdk_push/bluedot_point_sdk_push.dart';
import 'geo_triggering_page.dart';
import 'helpers/app_config.dart';
import 'helpers/push_notification_manager.dart';
import 'home_page.dart';
import 'initial_page.dart';
import 'push_notifications_page.dart';
import 'tempo_page.dart';

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
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.locationWhenInUse.request();
    // Notification permission and push listener are only needed when push is
    // enabled — avoids prompts and Firebase wiring on builds without FCM.
    if (await AppConfig.isPushEnabled()) {
      await Permission.notification.request();
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
