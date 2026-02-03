import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment.dart';
import '../utils/time_utils.dart';
import 'notification_listener.dart';

class PaymentController extends ChangeNotifier {
  PaymentController({required this.prefs}) {
    _notificationListener = NotificationListenerService(
      onNotificationText: _handleNotificationText,
      onPermissionStatus: _updatePermissionStatus,
    );
  }

  final SharedPreferences prefs;
  late final NotificationListenerService _notificationListener;

  final List<Payment> _payments = [];
  bool detectionEnabled = false;
  TimeOfDay startTime = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 13, minute: 0);
  bool notificationPermissionGranted = false;

  List<Payment> get payments => List.unmodifiable(_payments.reversed);

  double get totalToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _payments
        .where((payment) => payment.timestamp.isAfter(today))
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  Future<void> loadSettings() async {
    detectionEnabled = prefs.getBool('detectionEnabled') ?? false;
    final startMinutes = prefs.getInt('startMinutes');
    final endMinutes = prefs.getInt('endMinutes');
    if (startMinutes != null) {
      startTime = minutesToTimeOfDay(startMinutes);
    }
    if (endMinutes != null) {
      endTime = minutesToTimeOfDay(endMinutes);
    }
    await _notificationListener.initialize();
    notifyListeners();
  }

  Future<void> toggleDetection(bool value) async {
    detectionEnabled = value;
    await prefs.setBool('detectionEnabled', value);
    notifyListeners();
  }

  Future<void> updateSchedule({required TimeOfDay start, required TimeOfDay end}) async {
    startTime = start;
    endTime = end;
    await prefs.setInt('startMinutes', timeOfDayToMinutes(start));
    await prefs.setInt('endMinutes', timeOfDayToMinutes(end));
    notifyListeners();
  }

  Future<void> openNotificationSettings() async {
    await _notificationListener.openNotificationSettings();
  }

  void _updatePermissionStatus(bool granted) {
    notificationPermissionGranted = granted;
    notifyListeners();
  }

  void _handleNotificationText(String text, DateTime timestamp) {
    if (!detectionEnabled) {
      return;
    }
    if (!isWithinSchedule(timestamp, startTime, endTime)) {
      return;
    }
    final payment = Payment.tryParse(text, timestamp);
    if (payment == null) {
      return;
    }
    _payments.add(payment);
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationListener.dispose();
    super.dispose();
  }
}
