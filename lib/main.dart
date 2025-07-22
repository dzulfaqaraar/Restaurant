import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'common/common.dart';
import 'common/navigation.dart';
import 'common/styles.dart';
import 'utils/notification_helper.dart';
import 'data/api/api_service.dart';
import 'provider/favorite_provider.dart';
import 'provider/home_provider.dart';
import 'provider/restaurant_provider.dart';
import 'provider/reminder_provider.dart';
import 'provider/setting_provider.dart';
import 'ui/home_page.dart';
import 'ui/restaurant_page.dart';
import 'ui/setting_page.dart';
import 'ui/alarm_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize alarm for both iOS and Android
  await Alarm.init();

  // Initialize notifications for iOS and Android
  final notificationHelper = NotificationHelper();
  await notificationHelper.initNotifications();

  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp(notificationHelper: notificationHelper));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  final NotificationHelper notificationHelper;
  
  const MyApp({super.key, required this.notificationHelper});

  @override
  Widget build(BuildContext context) {
    // Configure notification tap handling
    notificationHelper.configureSelectNotificationSubject(context, '/restaurant');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            apiService: ApiService(client: http.Client()),
            connectivity: Connectivity(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RestaurantProvider(
            apiService: ApiService(client: http.Client()),
            connectivity: Connectivity(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(),
        ),
      ],
      child: Consumer<SettingProvider>(
        builder: (context, settingProvider, child) {
          return MaterialApp(
            title: 'Restaurant Kekinian',
            locale: settingProvider.locale,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                secondary: secondaryColor,
              ),
              scaffoldBackgroundColor: secondaryColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: myTextTheme.apply(bodyColor: Colors.white),
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: primaryColor,
                titleTextStyle:
                    myTextTheme.apply(bodyColor: Colors.white).headlineSmall,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey.withValues(alpha: 0.7),
                backgroundColor: primaryColor,
                type: BottomNavigationBarType.fixed,
              ),
              unselectedWidgetColor: Colors.grey.withValues(alpha: 0.7),
              useMaterial3: true,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Material(
              child: HomePage(),
            ),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case HomePage.routeName:
                  String? restaurantId = settings.arguments as String?;
                  return MaterialPageRoute(
                    builder: (_) => HomePage(restaurantId: restaurantId),
                    settings: settings,
                  );
                case RestaurantPage.routeName:
                  final restaurantId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (_) => RestaurantPage(restaurantId: restaurantId),
                    settings: settings,
                  );
                case SettingPage.routeName:
                  return MaterialPageRoute(builder: (_) => const SettingPage());
                case AlarmPage.routeName:
                  return MaterialPageRoute(builder: (_) => const AlarmPage());
                default:
                  return MaterialPageRoute(
                    builder: (_) {
                      return const Scaffold(
                        body: Center(
                          child: Text('Page not found :('),
                        ),
                      );
                    },
                  );
              }
            },
          );
        },
      ),
    );
  }
}