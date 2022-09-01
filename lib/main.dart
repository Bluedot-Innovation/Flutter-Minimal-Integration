import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:flutter/material.dart';
import 'initial_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class _MyAppState extends State<MyApp> {
  final _bluedotPointSdk = BluedotPointSdk();

  Future<bool> isInitialized(BuildContext context) async {
    var isInitialized = await _bluedotPointSdk.isInitialized();
    return isInitialized;
  }

  @override
  Widget build(BuildContext context) {
    isInitialized(context).then((value) {
      if (value) {
        // Navigator.push(context, ""),
      }
    });
    return MaterialApp(
      home: InitialPage(),
    );
  }
}