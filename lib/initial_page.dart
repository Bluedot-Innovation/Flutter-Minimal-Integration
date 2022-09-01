import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_minimal_integration/home_page.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {

  final textFieldController = TextEditingController();
  final _bluedotPointSdk = BluedotPointSdk();
  final _formKey = GlobalKey<FormState>();

  void validate() {
    if (_formKey.currentState!.validate()) {
      initialize();
    }
  }

  void initialize() async {
    debugPrint(textFieldController.text);
    var projectId = textFieldController.text;
    var sdkVersion = await _bluedotPointSdk.getSDKVersion();
      _bluedotPointSdk.initialize(projectId).then((value) {
        debugPrint("Initialized");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(projectId: projectId, sdkVersion: sdkVersion)
            )
        );
      }).catchError((error) {
        String errorMessage = error.toString();
        if (error is PlatformException) {
          errorMessage = error.message!;
        }
        showDialog(context: context,
            builder: (_) => AlertDialog(
              title: const Text("Failed to initialize project"),
              content: Text(errorMessage),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, 'Ok'),
                    child: const Text("Ok"))
              ],
            ),
          barrierDismissible: false,
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Initialize project"),
      ),
      body:
      Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "INITIALIZE PROJECT",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                child: TextFormField(
                  controller: textFieldController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Project ID goes here",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid project Id';
                    }
                    return null;
                  },
                )
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: validate,
                child: const Text("INITIALIZE")),
          ],
        ),
      ),
    );
  }
}