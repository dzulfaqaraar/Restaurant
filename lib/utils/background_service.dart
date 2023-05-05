import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../data/api/api_service.dart';
import '../main.dart';
import '../provider/setting_provider.dart';
import 'notification_helper.dart';

final ReceivePort port = ReceivePort();

class BackgroundService {
  static BackgroundService? _instance;

  static final NotificationHelper _notificationHelper = NotificationHelper();

  BackgroundService._internal() {
    _instance = this;
  }

  factory BackgroundService() => _instance ?? BackgroundService._internal();

  static Future<void> callback() async {
    HttpOverrides.global = MyHttpOverrides();
    final apiService = ApiService(client: http.Client());
    final listRestaurant = await apiService.listRestaurant();
    final randomIndex = Random().nextInt(listRestaurant.length);
    final randomRestaurant = listRestaurant[randomIndex];

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final bodyNotification = prefs.getString(dailyInfoPrefs) ?? '';

    await _notificationHelper.showNotification(
      flutterLocalNotificationsPlugin,
      randomRestaurant,
      bodyNotification,
    );
  }
}
