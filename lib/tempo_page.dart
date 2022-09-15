import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'helpers/show_error.dart';

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

      String channelId = 'Bluedot Flutter';
      String channelName = 'Bluedot Flutter';
      String androidNotificationTitle = 'Bluedot Foreground Service - Tempo';
      String androidNotificationContent =
          'This app is running a foreground service using location service';
      int androidNotificationId = 123;

      var destinationId = textFieldController.text.trim();

      // Set custom event metadata.
      // We suggest to set the Custom Event Meta Data before starting GeoTriggering or Tempo.
      var metadata = {
        'hs_orderId': 'Order Id',
        'hs_Customer Name': 'Customer Name'
      };
      BluedotPointSdk.instance.setCustomEventMetaData(metadata);

      BluedotPointSdk.instance
          .tempoBuilder()
          .androidNotification(channelId, channelName, androidNotificationTitle,
              androidNotificationContent, androidNotificationId)
          .start(destinationId)
          .then((value) {
            _saveDestinationId(destinationId);
            // Successfully started tempo tracking
        _updateTempoStatus();
      }).catchError((error) {
        // Failed to start tempo tracking, handle error here
        String errorMessage = error.toString();
        if (error is PlatformException) {
          errorMessage = error.message!;
        }
        showError('Failed to start tempo tracking', errorMessage, context);
      });
    }
  }

  void _saveDestinationId(String destinationId) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString('destinationId', destinationId);
  }

  void _prePopulateTextField() async {
     final sharedPrefs = await SharedPreferences.getInstance();
     var destinationId = sharedPrefs.getString('destinationId') ?? '';
     textFieldController.text = destinationId;
  }

  /// Stop tempo tracking
  void _stopTempo() {
    BluedotPointSdk.instance.stopTempoTracking().then((value) {
      // Successfully stopped tempo tracking
      _updateTempoStatus();
    }).catchError((error) {
      // Failed to stop tempo tracking, handle error here
      String errorMessage = error.toString();
      if (error is PlatformException) {
        errorMessage = error.message!;
      }
      showError('Failed to stop tempo tracking', errorMessage, context);
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
      switch (call.method) {
        case TempoEvents.tempoTrackingStoppedWithError:
          var errorCode = args['code'];
          var errorMessage = args['message'];
          showError('Tempo Tracking Stopped With Error', '$errorCode $errorMessage', context);
          Future.delayed(const Duration(milliseconds: 500), () {
            _updateTempoStatus();
          });
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
