import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'helpers/show_error.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final textFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _serviceMethodChannel = const MethodChannel(BluedotPointSdk.BLUEDOT_SERVICE); // Method channel to listen to bluedot service events

  void _initialize() async {
    if (_formKey.currentState!.validate()) {
      var projectId = textFieldController.text;

      // Initialize project with provided [projectId]
      BluedotPointSdk.instance.initialize(projectId).then((value) {
        // Handle successful initialization
        Navigator.pushNamed(context, '/home');
      }).catchError((error) {
        // Handle failed initialization
        String errorMessage = error.toString();
        if (error is PlatformException) {
          errorMessage = error.message!;
        }
        showError('Failed to initialize project', errorMessage, context);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Handle error of Bluedot service events
    _serviceMethodChannel.setMethodCallHandler((MethodCall call) async {
      var args = call.arguments;
      switch (call.method) {
        case "onBluedotServiceError":
          debugPrint("On Bluedot Service Error: $args");
          break;
        default:
          break;
      }
    });

    BluedotPointSdk.instance.isInitialized().then((value) {
      if (value) {
        Navigator.pushNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initialize project'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'INITIALIZE PROJECT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              TextFormField(
                controller: textFieldController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Project ID goes here',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid project Id';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                  onPressed: _initialize, child: const Text('INITIALIZE')),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
