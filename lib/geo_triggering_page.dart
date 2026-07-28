import 'dart:io';
import 'dart:convert';

import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_minimal_integration/helpers/shared_preferences.dart';
import 'helpers/constants.dart';
import 'helpers/show_alert.dart';

// ---------------------------------------------------------------------------
// Simple model for a logged geo-triggering event
// ---------------------------------------------------------------------------
class GeoTriggerEvent {
  final String type;
  final String details;
  final DateTime timestamp;

  GeoTriggerEvent({
    required this.type,
    required this.details,
    required DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ---------------------------------------------------------------------------
// Singleton store so events survive page re-creation
// ---------------------------------------------------------------------------
class GeoTriggerEventStore {
  GeoTriggerEventStore._();
  static final instance = GeoTriggerEventStore._();

  final List<GeoTriggerEvent> events = [];

  final _listeners = <VoidCallback>[];
  void addListener(VoidCallback l) => _listeners.add(l);
  void removeListener(VoidCallback l) => _listeners.remove(l);

  void add(GeoTriggerEvent e) {
    events.add(e);
    for (final l in List.of(_listeners)) {
      l();
    }
  }
}

// ---------------------------------------------------------------------------
// Singleton channel handler – registered once so it works across navigations
// ---------------------------------------------------------------------------
class _GeoTriggeringChannelHandler {
  _GeoTriggeringChannelHandler._() {
    _channel.setMethodCallHandler(_handleCall);
  }
  static final instance = _GeoTriggeringChannelHandler._();

  final _channel = const MethodChannel(BluedotPointSdk.geoTriggering);

  Future<void> _handleCall(MethodCall call) async {
    final args = call.arguments;
    final store = GeoTriggerEventStore.instance;

    switch (call.method) {
      case GeoTriggeringEvents.didUpdateZoneInfo:
        debugPrint('On Zone Info Update: $args');
        store.add(GeoTriggerEvent(
          type: 'Zone Info Update',
          details: args?.toString() ?? '',
          timestamp: DateTime.now(),
        ));
        break;
      case GeoTriggeringEvents.didEnterZone:
        debugPrint('Did Enter Zone: $args');
        store.add(GeoTriggerEvent(
          type: 'Enter Zone',
          details: args?.toString() ?? '',
          timestamp: DateTime.now(),
        ));
        // CustomEventMetaData example
        BluedotPointSdk.instance.getCustomEventMetaData().then((value) {
          if (value != null && value.isEmpty) {
            BluedotPointSdk.instance.setCustomEventMetaData({
              'key1': 'MinApp',
              'Key2': 'TestData',
            });
          }
        });
        break;
      case GeoTriggeringEvents.didExitZone:
        debugPrint('Did Exit Zone: $args');
        store.add(GeoTriggerEvent(
          type: 'Exit Zone',
          details: args?.toString() ?? '',
          timestamp: DateTime.now(),
        ));
        break;
      case GeoTriggeringEvents.didDwellInZone:
        debugPrint('Did Dwell Zone: $args');
        store.add(GeoTriggerEvent(
          type: 'Dwell Zone',
          details: args?.toString() ?? '',
          timestamp: DateTime.now(),
        ));
        break;
      default:
        break;
    }
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class GeoTriggeringPage extends StatefulWidget {
  const GeoTriggeringPage({Key? key}) : super(key: key);

  @override
  State<GeoTriggeringPage> createState() => _GeoTriggeringPageState();
}

class _GeoTriggeringPageState extends State<GeoTriggeringPage> {
  bool _isGeoTriggeringRunning = false;
  bool _isBackgroundLocationUpdateEnabled = true;

  @override
  void initState() {
    super.initState();
    // Ensure the singleton channel handler is initialised.
    _GeoTriggeringChannelHandler.instance;

    GeoTriggerEventStore.instance.addListener(_onNewEvent);
    _updateGeoTriggeringStatus();
    _updateBackgroundLocationStatus();
  }

  @override
  void dispose() {
    GeoTriggerEventStore.instance.removeListener(_onNewEvent);
    super.dispose();
  }

  void _onNewEvent() {
    if (mounted) setState(() {});
  }

  // ---- SDK helpers ---------------------------------------------------------

  void _startGeoTriggering() {
    BluedotPointSdk.instance.geoTriggeringBuilder().start().then((_) {
      Future.delayed(const Duration(milliseconds: 500), _updateGeoTriggeringStatus);
    }).catchError((error) {
      _showError('Fail to start geo triggering', error);
    });
  }

  void _startGeoTriggeringNotification() {
    if (Platform.isIOS) {
      BluedotPointSdk.instance
          .geoTriggeringBuilder()
          .iosNotification('Restart Bluedot Service', 'Restart')
          .start()
          .then((_) => _updateGeoTriggeringStatus())
          .catchError((error) {
        _showError('Fail to start geo triggering with notification', error);
      });
    } else {
      BluedotPointSdk.instance
          .geoTriggeringBuilder()
          .androidNotification(
            bluedotChannelId,
            bluedotChannelName,
            'Bluedot Foreground Service - Geo-triggering',
            'This app is running a foreground service using location service',
            123,
          )
          .start()
          .then((_) => _updateGeoTriggeringStatus())
          .catchError((error) {
        _showError('Fail to start geo triggering with notification', error);
      });
    }
  }

  void _stopGeoTriggering() {
    BluedotPointSdk.instance.stopGeoTriggering().then((_) {
      _updateGeoTriggeringStatus();
    }).catchError((error) {
      _showError('Fail to stop geo triggering', error);
    });
  }

  void _updateGeoTriggeringStatus() {
    BluedotPointSdk.instance.isGeoTriggeringRunning().then((value) {
      if (mounted) setState(() => _isGeoTriggeringRunning = value);
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
    final v = await getBoolForKey(isBackgroundLocationUpdateString);
    if (mounted) setState(() => _isBackgroundLocationUpdateEnabled = v);
  }

  void _showError(String title, dynamic error) {
    String msg = error.toString();
    if (error is PlatformException) msg = error.message ?? msg;
    showAlert(title, msg, context);
  }

  // ---- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final events = GeoTriggerEventStore.instance.events;

    return Scaffold(
      appBar: AppBar(title: const Text('GEO-TRIGGERING')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Controls (pinned to top) ------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (Platform.isIOS) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Allow Background Location Updates'),
                      Switch.adaptive(
                        value: _isBackgroundLocationUpdateEnabled,
                        onChanged: _allowsBackgroundLocationUpdates,
                      ),
                    ],
                  ),
                  Text('Background Location Enabled: $_isBackgroundLocationUpdateEnabled'),
                  const SizedBox(height: 8),
                ],
                Text(
                  'Geo Triggering Running: $_isGeoTriggeringRunning',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (!_isGeoTriggeringRunning) ...[
                  ElevatedButton(
                    onPressed: _startGeoTriggeringNotification,
                    child: const Text('Start with notification'),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: _startGeoTriggering,
                    child: const Text('Start'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _stopGeoTriggering,
                    child: const Text('Stop'),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          // ---- Event log ---------------------------------------------------
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No geo-triggering events yet.\n\n'
                        'Events will appear here as you enter, dwell in, or exit zones.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      // Newest first
                      final event = events[events.length - 1 - index];
                      return ListTile(
                        leading: _iconForType(event.type),
                        title: Text(
                          event.type,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.details.isNotEmpty)
                              Text(event.details),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(event.timestamp),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: event.details.isNotEmpty,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _iconForType(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'Enter Zone':
        icon = Icons.login;
        color = Colors.green;
        break;
      case 'Exit Zone':
        icon = Icons.logout;
        color = Colors.red;
        break;
      case 'Dwell Zone':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.blue;
    }
    return Icon(icon, color: color);
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')} '
        '${dt.day}/${dt.month}/${dt.year}';
  }
}
