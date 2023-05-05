import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../common/navigation.dart';
import '../common/string_ext.dart';
import '../data/model/restaurant.dart';
import '../ui/home_page.dart';

class NotificationHelper {
  static const _channelId = "01";
  static const _channelName = "channel_01";
  static const _channelDesc = "Restaurant Channel";
  static NotificationHelper? _instance;

  BehaviorSubject<String?> selectNotificationSubject =
      BehaviorSubject<String?>();

  NotificationHelper._internal() {
    _instance = this;
  }

  factory NotificationHelper() => _instance ?? NotificationHelper._internal();

  Future<void> initNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    selectNotificationSubject = BehaviorSubject<String?>();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        selectNotificationSubject.add(payload);
      },
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url));
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    Restaurant restaurant,
    String bodyNotification,
  ) async {
    var bigPicturePath = await _downloadAndSaveFile(
      restaurant.pictureId?.mediumImage() ?? '',
      'bigPicture',
    );

    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      contentTitle: restaurant.name,
      summaryText: bodyNotification,
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      styleInformation: bigPictureStyleInformation,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final packageInfo = await PackageInfo.fromPlatform();

    await flutterLocalNotificationsPlugin.show(
      0,
      packageInfo.appName.capitalize(),
      bodyNotification,
      platformChannelSpecifics,
      payload: restaurant.id,
    );
  }

  void configureSelectNotificationSubject(BuildContext context, String route) {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigation.notificationWithData(
        HomePage.routeName,
        arguments: payload,
      );
    });
  }

  void closeStream() {
    selectNotificationSubject.close();
  }
}
