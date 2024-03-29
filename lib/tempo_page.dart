import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:flutter_minimal_integration/helpers/constants.dart';
import 'package:flutter_minimal_integration/helpers/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'helpers/show_alert.dart';
import 'dart:math';

class TempoPage extends StatefulWidget {
  const TempoPage({Key? key}) : super(key: key);

  @override
  State<TempoPage> createState() => _TempoPageState();
}

class _TempoPageState extends State<TempoPage> {
  final textFieldController = TextEditingController();
  final _tempoFormKey = GlobalKey<FormState>();
  final tempoEventChannel = const MethodChannel(BluedotPointSdk.tempo); // Method channel to listen to tempo events
  bool _isTempoRunning = false;

  /// Start tempo tracking
  void _startTempo() {
    if (_tempoFormKey.currentState!.validate()) {

      String androidNotificationTitle = 'Bluedot Foreground Service - Tempo';
      String androidNotificationContent =
          'This app is running a foreground service using location service';
      int androidNotificationId = 123;

      var destinationId = textFieldController.text.trim();

      // Set custom event metadata.
      // We suggest to set the Custom Event Meta Data before starting GeoTriggering or Tempo.
      var metadata = {
        'hs_orderId': _generateRandomString(5),
        'hs_Customer Name': 'QA Testing'
      };
      BluedotPointSdk.instance.setCustomEventMetaData(metadata);

      BluedotPointSdk.instance
          .tempoBuilder()
          .androidNotification(bluedotChannelId, bluedotChannelName, androidNotificationTitle,
              androidNotificationContent, androidNotificationId)
          .start(destinationId)
          .then((value) {
            saveString(destinationIdString, destinationId);
            // Successfully started tempo tracking
        _updateTempoStatus();
      }).catchError((error) {
        // Failed to start tempo tracking, handle error here
        String errorMessage = error.toString();
        if (error is PlatformException) {
          errorMessage = error.message!;
        }
        showAlert('Failed to start tempo tracking', errorMessage, context);
      });
    }
  }

  // QA testing only
  String _generateRandomString(int len) {
    var r = Random();
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  void _prePopulateTextField() async {
     var destinationId = await getStringForKey(destinationIdString);
     textFieldController.text = destinationId;
  }

  /// Stop tempo tracking
  void _stopTempo() {
    BluedotPointSdk.instance.stopTempoTracking().then((value) {
      // Successfully stopped tempo tracking
      Future.delayed(const Duration(milliseconds: 500), () {
        _updateTempoStatus();
      });
    }).catchError((error) {
      // Failed to stop tempo tracking, handle error here
      String errorMessage = error.toString();
      if (error is PlatformException) {
        errorMessage = error.message!;
      }
      showAlert('Failed to stop tempo tracking', errorMessage, context);
    });
  }

  void _updateTempoStatus() {
    BluedotPointSdk.instance.isTempoRunning().then((value) {
      setState(() {
        debugPrint('Is Tempo Running $value');
        _isTempoRunning = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // Handle tempo events
    tempoEventChannel.setMethodCallHandler((MethodCall call) async {
      var args = call.arguments;
      var tempoAlertTitle = 'Tempo Events';
      switch (call.method) {
        case TempoEvents.tempoTrackingStoppedWithError:
          var errorCode = args['code'];
          var errorMessage = args['message'];
          showAlert(tempoAlertTitle, 'Tempo Tracking Stopped With Error: $errorCode $errorMessage', context);
          Future.delayed(const Duration(milliseconds: 500), () {
            _updateTempoStatus();
          });
          break;
        case TempoEvents.tempoTrackingDidUpdate:
          debugPrint('Tempo Tracking Update: $args');
          showAlert(tempoAlertTitle, 'Tempo Tracking Update: $args', context);
          break;
        default:
          break;
      }
    });
    _updateTempoStatus();
    _prePopulateTextField();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('TEMPO'),
          ),
          body: Center(
            child: Form(
                key: _tempoFormKey,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 200),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'TEMPO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text('Is Tempo Tracking Running: $_isTempoRunning'),
                        TextFormField(
                          controller: textFieldController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Destination Id goes here',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a valid destination Id';
                            }
                            return null;
                          },
                        ),
                        if (!_isTempoRunning) ...[
                          ElevatedButton(
                              onPressed: _startTempo, child: const Text('START')),
                        ] else ...[
                          ElevatedButton(
                              onPressed: _stopTempo, child: const Text('STOP')),
                        ],
                      ]),
                )),
          ),
          resizeToAvoidBottomInset: false,
        ),
    );
  }
}
