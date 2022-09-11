import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'geo_triggering_page.dart';
import 'home_page.dart';
import 'initial_page.dart';
import 'tempo_page.dart';

void main() {
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
    Permission.locationWhenInUse.request();
    Permission.notification.request();
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
      },
    );
  }
}
