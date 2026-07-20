import 'dart:async';

import 'package:flutter/material.dart';
import 'helpers/push_notification_manager.dart';

class PushNotificationsPage extends StatefulWidget {
  const PushNotificationsPage({Key? key}) : super(key: key);

  @override
  State<PushNotificationsPage> createState() => _PushNotificationsPageState();
}

class _PushNotificationsPageState extends State<PushNotificationsPage> {
  late final List<PushNotificationEvent> _events;
  late final StreamSubscription<PushNotificationEvent> _subscription;

  @override
  void initState() {
    super.initState();
    // Snapshot the current list plus subscribe for live updates.
    _events = List.from(PushNotificationManager.instance.events);
    _subscription = PushNotificationManager.instance.stream.listen((event) {
      if (mounted) {
        setState(() => _events.add(event));
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
      ),
      body: _events.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No push notification events yet.\n\n'
                  'Received and clicked Bluedot push notifications will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _events.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                // Show newest first.
                final event = _events[_events.length - 1 - index];
                final isReceived = event.type == 'received';
                return ListTile(
                  leading: Icon(
                    isReceived
                        ? Icons.notifications_active
                        : Icons.touch_app,
                    color: isReceived ? Colors.blue : Colors.green,
                  ),
                  title: Text(
                    event.title.isNotEmpty ? event.title : '(no title)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.body.isNotEmpty ? event.body : '(no body)'),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${event.type}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (event.campaignId.isNotEmpty)
                        Text(
                          'Campaign: ${event.campaignId}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (event.zoneId.isNotEmpty)
                        Text(
                          'Zone: ${event.zoneId}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      Text(
                        _formatTimestamp(event.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')} '
        '${dt.day}/${dt.month}/${dt.year}';
  }
}

