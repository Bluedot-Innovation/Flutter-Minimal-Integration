import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:flutter_minimal_integration/helpers/constants.dart';
import 'package:flutter_minimal_integration/helpers/shared_preferences.dart';
import 'helpers/show_alert.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final textFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _serviceMethodChannel = const MethodChannel(BluedotPointSdk.bluedotService); // Method channel to listen to bluedot service events

  void _initialize() async {
    if (_formKey.currentState!.validate()) {
      var projectId = textFieldController.text.trim();

      // Initialize project with the provided [projectId]
      BluedotPointSdk.instance.initialize(projectId).then((value) {
        // Handle successful initialization
        saveString(projectIdString, projectId);
        Navigator.pushNamed(context, '/home');
      }).catchError((error) {
        // Handle failed initialization
        String errorMessage = error.toString();
        if (error is PlatformException) {
          errorMessage = error.message!;
        }
        showAlert('Failed to initialize project', errorMessage, context);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Handle error of Bluedot service events
    _serviceMethodChannel.setMethodCallHandler((MethodCall call) async {
      var args = call.arguments;
      var bluedotServiceAlertTitle = 'Bluedot Service Events';
      switch (call.method) {
        case BluedotServiceEvents.onBluedotServiceError:
          debugPrint('On Bluedot Service Error: $args');
          showAlert(bluedotServiceAlertTitle, 'On Bluedot Service Error: $args', context);
          break;
          // iOS-only events
        case BluedotServiceEvents.locationAuthorizationDidChange:
          debugPrint('Location Authorization Did Change: $args');
          showAlert(bluedotServiceAlertTitle, 'Location Authorization Did Change: $args', context);
          break;
        case BluedotServiceEvents.lowPowerModeDidChange:
          debugPrint('Low Power Mode Did Change: $args');
          showAlert(bluedotServiceAlertTitle, 'Low Power Mode Did Change: $args', context);
          break;
        case BluedotServiceEvents.accuracyAuthorizationDidChange:
          debugPrint('Accuracy Authorization Did Change: $args');
          showAlert(bluedotServiceAlertTitle, 'Accuracy Authorization Did Change: $args', context);
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
    clearSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    child: Scaffold(
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
    ),
    );
  }
}
