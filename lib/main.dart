import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'common/common.dart';
import 'common/navigation.dart';
import 'common/styles.dart';
import 'data/api/api_service.dart';
import 'provider/favorite_provider.dart';
import 'provider/home_provider.dart';
import 'provider/restaurant_provider.dart';
import 'provider/setting_provider.dart';
import 'ui/home_page.dart';
import 'ui/restaurant_page.dart';
import 'ui/setting_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
          create: (_) => SettingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => SettingProvider(),
        builder: (context, child) {
          final provider = Provider.of<SettingProvider>(context);
          return MaterialApp(
            title: 'Restaurant Kekinian',
            locale: provider.locale,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              primaryColor: primaryColor,
              scaffoldBackgroundColor: secondaryColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: myTextTheme.apply(bodyColor: Colors.white),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: secondaryColor,
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: primaryColor,
                titleTextStyle:
                    myTextTheme.apply(bodyColor: Colors.white).headline6,
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey.withOpacity(0.7),
                backgroundColor: primaryColor,
                type: BottomNavigationBarType.fixed,
              ),
              unselectedWidgetColor: Colors.grey.withOpacity(0.7),
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Material(
              child: HomePage(),
            ),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case HomePage.routeName:
                  String? restaurantId = settings.arguments as String;
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
