import 'dart:async';

/// A single push notification event (received or clicked).
class PushNotificationEvent {
  final String type; // 'received' or 'clicked'
  final String title;
  final String body;
  final String campaignId;
  final String zoneId;
  final String notificationId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  PushNotificationEvent({
    required this.type,
    required this.title,
    required this.body,
    required this.campaignId,
    required this.zoneId,
    required this.notificationId,
    required this.data,
    required this.timestamp,
  });

  factory PushNotificationEvent.fromMap(String type, Map<String, dynamic> map) {
    return PushNotificationEvent(
      type: type,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      campaignId: map['campaignId'] as String? ?? '',
      zoneId: map['zoneId'] as String? ?? '',
      notificationId: map['notificationId'] as String? ?? '',
      data: (map['data'] as Map?)?.cast<String, dynamic>() ?? {},
      timestamp: DateTime.now(),
    );
  }
}

/// Singleton that receives push notification callbacks and exposes them as a stream.
class PushNotificationManager {
  PushNotificationManager._();
  static final instance = PushNotificationManager._();

  final _controller = StreamController<PushNotificationEvent>.broadcast();
  final List<PushNotificationEvent> events = [];

  /// Stream of push notification events (received & clicked).
  Stream<PushNotificationEvent> get stream => _controller.stream;

  void addEvent(PushNotificationEvent event) {
    events.add(event);
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

