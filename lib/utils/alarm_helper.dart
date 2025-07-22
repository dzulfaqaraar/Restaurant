import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmHelper {
  static Future<void> initializeAlarms() async {
    await Alarm.init();
  }

  // Schedule restaurant reminder alarm
  static Future<bool> scheduleRestaurantReminder({
    required int id,
    required String restaurantName,
    required DateTime dateTime,
    String? assetAudioPath,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: assetAudioPath ?? 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      warningNotificationOnKill: true,
      notificationSettings: NotificationSettings(
        title: 'Restaurant Reminder',
        body: 'Time to visit $restaurantName!',
        stopButton: 'Stop',
        icon: 'notification_icon',
      ),
    );

    return await Alarm.set(alarmSettings: alarmSettings);
  }

  // Schedule daily lunch reminder
  static Future<bool> scheduleDailyLunchReminder({
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return await scheduleRestaurantReminder(
      id: 1, // Daily reminder ID
      restaurantName: 'your favorite restaurant',
      dateTime: scheduledDate,
    );
  }

  // Get all active alarms
  static Future<List<AlarmSettings>> getActiveAlarms() async {
    return Alarm.getAlarms();
  }

  // Cancel specific alarm
  static Future<bool> cancelAlarm(int id) async {
    return await Alarm.stop(id);
  }

  // Cancel all alarms
  static Future<void> cancelAllAlarms() async {
    final alarms = await getActiveAlarms();
    for (final alarm in alarms) {
      await Alarm.stop(alarm.id);
    }
  }

  // Check if any alarm is currently active
  static Future<bool> get hasAlarm async {
    final alarms = await getActiveAlarms();
    return alarms.isNotEmpty;
  }
}