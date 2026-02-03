import 'dart:async';

import 'package:flutter/services.dart';

class NotificationListenerService {
  NotificationListenerService({
    required this.onNotificationText,
    required this.onPermissionStatus,
  });

  final void Function(String text, DateTime timestamp) onNotificationText;
  final void Function(bool granted) onPermissionStatus;

  static const EventChannel _eventChannel =
      EventChannel('yape_notifications/events');
  static const MethodChannel _methodChannel =
      MethodChannel('yape_notifications/methods');

  StreamSubscription<dynamic>? _subscription;

  Future<void> initialize() async {
    _subscription ??= _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          final text = event['text'] as String?;
          final timestamp = event['timestamp'] as int?;
          if (text != null && timestamp != null) {
            onNotificationText(
              text,
              DateTime.fromMillisecondsSinceEpoch(timestamp),
            );
          }
        }
      },
    );
    final permission = await _methodChannel.invokeMethod<bool>('hasPermission');
    onPermissionStatus(permission ?? false);
  }

  Future<void> openNotificationSettings() async {
    await _methodChannel.invokeMethod('openSettings');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
