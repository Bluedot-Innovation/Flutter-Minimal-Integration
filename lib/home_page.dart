import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.projectId, required this.sdkVersion})
      : super(key: key);

  final String projectId;
  final String sdkVersion;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Flutter Bluedot Point SDK"),
            const SizedBox(height: 20),
            const Text("Install Reference"),
            const SizedBox(height: 20),
            Text(widget.projectId),
            const SizedBox(height: 20),
            const Text("SDK Version"),
            const SizedBox(height: 20),
            Text(widget.sdkVersion),
          ],
        ));
  }
}
