import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../ui/restaurant_page.dart';
import '../utils/background_service.dart';
import '../utils/date_time_helper.dart';
import '../utils/notification_helper.dart';

const String dailyInfoPrefs = 'dailyInfo';
const String dailyRestaurantPrefs = 'dailyRestaurant';
const int dailyRestaurantId = 31074;

class SettingProvider extends ChangeNotifier {
  Locale _locale = const Locale("id");
  Locale get locale => _locale;
  final NotificationHelper _notificationHelper = NotificationHelper();

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  Future<bool> isDailyRestaurantEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(dailyRestaurantPrefs) ?? false;
  }

  void updateReminderMessage(String? info) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(dailyInfoPrefs, info ?? '');
  }

  void initNotifications() async {
    await _notificationHelper.initNotifications(
      flutterLocalNotificationsPlugin,
    );
  }

  void setSchedule(BuildContext context, bool isEnabled) async {
    if (isEnabled) {
      _notificationHelper.configureSelectNotificationSubject(
        context,
        RestaurantPage.routeName,
      );

      await AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        dailyRestaurantId,
        BackgroundService.callback,
        startAt: DateTimeHelper.format(),
        exact: true,
        wakeup: true,
      );
    } else {
      await AndroidAlarmManager.cancel(dailyRestaurantId);
      _notificationHelper.closeStream();
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(dailyRestaurantPrefs, isEnabled);
  }
}
