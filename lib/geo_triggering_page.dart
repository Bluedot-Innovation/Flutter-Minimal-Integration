import 'dart:io';
import 'dart:convert';

import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_minimal_integration/helpers/shared_preferences.dart';
import 'helpers/constants.dart';
import 'helpers/show_alert.dart';

class GeoTriggeringPage extends StatefulWidget {
  const GeoTriggeringPage({Key? key}) : super(key: key);

  @override
  State<GeoTriggeringPage> createState() => _GeoTriggeringPageState();
}

class _GeoTriggeringPageState extends State<GeoTriggeringPage> {
  bool _isGeoTriggeringRunning = false;
  bool _isBackgroundLocationUpdateEnabled = true;
  final geoTriggeringEventChannel = const MethodChannel(BluedotPointSdk
      .geoTriggering); // Method channel to listen to geo triggering events

  /// Start Geo triggering in iOS and Android (background mode)
  void _startGeoTriggering() {
    BluedotPointSdk.instance.geoTriggeringBuilder().start().then((value) {
      // Successfully started geo triggering, delay updating geo triggering status to wait for sdk to update geo-triggering status
      Future.delayed(const Duration(milliseconds: 500), () {
        _updateGeoTriggeringStatus();
      });
    }).catchError((error) {
      // Failed to start geo triggering, handle error in here
      String errorMessage = error.toString();
      if (error is PlatformException) {
        errorMessage = error.message!;
      }
      showAlert('Fail to start geo triggering', errorMessage, context);
    });
  }

  /// Start Geo Triggering in iOS and Android (foreground mode)
  void _startGeoTriggeringNotification() {
     if (Platform.isIOS) {
      String iosAppRestartNotificationTitle =
          'Restart Bluedot Service';
      String iosAppRestartNotificationButtonText =
          'Restart';

      BluedotPointSdk.instance
          .geoTriggeringBuilder().iosNotification(
        iosAppRestartNotificationTitle,
        iosAppRestartNotificationButtonText)
          .start()
          .then((value) {
        // Handle successful start of geo-triggering
        _updateGeoTriggeringStatus();
      }).catchError((error) {
        // Handle failed start of geo-triggering, handle error in here
        String errorMessage = error.toString();
        if (error is PlatformException) {
          errorMessage = error.message!;
        }
        showAlert('Fail to start geo triggering with notification',
            errorMessage, context);
      });
    } else {

      String androidNotificationTitle =
          'Bluedot Foreground Service - Geo-triggering';
      String androidNotificationContent =
          'This app is running a foreground service using location service';
      int androidNotificationId = 123;

      // Setting notification details for Android foreground service
      BluedotPointSdk.instance
          .geoTriggeringBuilder().androidNotification(
              bluedotChannelId,
              bluedotChannelName,
              androidNotificationTitle,
              androidNotificationContent,
              androidNotificationId)
          .start()
          .then((value) {
        // Handle successful start of geo-triggering
        _updateGeoTriggeringStatus();
      }).catchError((error) {
          // Handle failed start of geo-triggering, handle error in here
          String errorMessage = error.toString();
          if (error is PlatformException) {
             errorMessage = error.message!;
          }
          showAlert('Fail to start geo triggering with notification',
              errorMessage, context);
      });
     }
  }

  /// Stop Geo-Triggering
  void _stopGeoTriggering() {
    BluedotPointSdk.instance.stopGeoTriggering().then((value) {
      // Successfully stop geo triggering
      _updateGeoTriggeringStatus();
    }).catchError((error) {
      // Failed to stop geo triggering, handle error in here
      String errorMessage = error.toString();
      if (error is PlatformException) {
        errorMessage = error.message!;
      }
      showAlert('Fail to stop geo triggering', errorMessage, context);
    });
  }

  /// Retrieve isGeoTriggeringRunning
  void _updateGeoTriggeringStatus() {
    BluedotPointSdk.instance.isGeoTriggeringRunning().then((value) {
      setState(() {
        debugPrint('Is Geo Running $value');
        _isGeoTriggeringRunning = value;
      });
    });
  }

  void _allowsBackgroundLocationUpdates(bool value) {
    BluedotPointSdk.instance.backgroundLocationAccessForWhileUsing(value);
    setState(() {
      _isBackgroundLocationUpdateEnabled = value;
      saveBool(isBackgroundLocationUpdateString, value);
    });
  }

  void _updateBackgroundLocationStatus() async {
    var backgroundLocationStatus =
        await getBoolForKey(isBackgroundLocationUpdateString);
    setState(() {
      _isBackgroundLocationUpdateEnabled = backgroundLocationStatus;
    });
  }

  void _getZonesAndFences() {
    BluedotPointSdk.instance.getZonesAndFences().then((zones) {
      debugPrint('Zones and Fences received');
      debugPrint('Zones and Fences received: ${jsonEncode(zones)}');
      for (var zone in zones) {
        if (Platform.isIOS) {
          debugPrint('Zone: ${zone['name']} (ID: ${zone['ID']})');
          // Access destination->customData
          if (zone['destination'] != null) {
            var destination = zone['destination'];
            debugPrint('Destination: ${destination['name']}');

            if (destination['customData'] != null) {
              var customData = destination['customData'];
              debugPrint('Destination Custom Data: $customData');
              showAlert(
                  'On Zone Info Update', 'Destination Custom Data: $customData',
                  context);
            } else {
              debugPrint('No custom data for destination');
            }
          } else {
            debugPrint('No destination for zone: ${zone['name']}');
          }
        } else if (Platform.isAndroid) {
          debugPrint('Zone: ${zone['zoneName']} (ID: ${zone['zoneId']})');
          // Access destination->customData
          if (zone['destination'] != null) {
            var destination = zone['destination'];
            debugPrint('Destination: ${destination['name']}');

            if (destination['customData'] != null) {
              var customData = destination['customData'];
              debugPrint('Destination Custom Data: $customData');
              showAlert(
                  'On Zone Info Update', 'Destination Custom Data: $customData',
                  context);
            } else {
              debugPrint('No custom data for destination');
            }
          } else {
            debugPrint('No destination for zone: ${zone['zoneName']}');
          }
        }

      }
      }).catchError((error) {
      debugPrint('Error getting zones and fences: $error');
    });
  }

  @override
  void initState() {
    super.initState();

    /// set a custom notification icon for GeoTriggering/Tempo service Foreground Notification in Android
    /// By default the Bluedot PointSDK uses `ic_stat_name`, only need to call this if you want to set a different icon.
    /// IMPORTANT: Make sure setNotificationIcon()  is called prior to starting GeoTriggering
    // BluedotPointSdk.instance.setNotificationIcon('some_notification_icon');

    // Handle geo triggering events
    geoTriggeringEventChannel.setMethodCallHandler((MethodCall call) async {
      var args = call.arguments;
      var geoTriggeringAlertTitle = 'Geo-Triggering Events';
      switch (call.method) {
        case GeoTriggeringEvents.didUpdateZoneInfo:
          debugPrint('On Zone Info Update: $args');
          
          _getZonesAndFences();
          break;
        case GeoTriggeringEvents.didEnterZone:
          debugPrint('Did Enter Zone: $args');
          showAlert(geoTriggeringAlertTitle, 'Did Enter Zone: $args', context);
          break;
        case GeoTriggeringEvents.didExitZone:
          debugPrint('Did Exit Zone: $args');
          showAlert(geoTriggeringAlertTitle, 'Did Exit Zone: $args', context);
          break;
        default:
          break;
      }
    });
    _updateGeoTriggeringStatus();
    _updateBackgroundLocationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('GEO-TRIGGERING'),
        ),
        body: Center(
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'GEO TRIGGERING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (Platform.isIOS) ...[
                    const Text('Allow Background Location Updates'),
                    Switch.adaptive(
                        value: _isBackgroundLocationUpdateEnabled,
                        onChanged: (newValue) =>
                            _allowsBackgroundLocationUpdates(newValue)),
                    Text(
                        'Is Background Location Enabled: $_isBackgroundLocationUpdateEnabled'),
                  ],
                  Text('Is Geo Triggering Running: $_isGeoTriggeringRunning'),
                  if (!_isGeoTriggeringRunning) ...[
                      ElevatedButton(
                          onPressed: _startGeoTriggeringNotification,
                          child: const Text('Start with android notification')),

                    ElevatedButton(
                        onPressed: _startGeoTriggering,
                        child: const Text('Start')),
                  ] else ...[
                    ElevatedButton(
                        onPressed: _stopGeoTriggering,
                        child: const Text('Stop')),
                  ],
                ],
              )),
        ));
  }
}
