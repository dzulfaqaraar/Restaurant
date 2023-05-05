import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/common.dart';
import '../common/localization.dart';
import '../common/styles.dart';
import '../provider/setting_provider.dart';

class SettingPage extends StatefulWidget {
  static const routeName = '/setting';
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _selectedLanguage = 'id';
  bool _isDailyReminderEnable = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      setState(() {
        Locale appLocale = Localizations.localeOf(context);
        _selectedLanguage = appLocale.languageCode;
      });

      final settingProvider =
          Provider.of<SettingProvider>(context, listen: false);
      final isEnabled = await settingProvider.isDailyRestaurantEnabled();
      setState(() {
        _isDailyReminderEnable = isEnabled;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final info = AppLocalizations.of(context)?.restaurantInfo;
    final provider = Provider.of<SettingProvider>(context, listen: false);
    provider.updateReminderMessage(info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.setting ?? ''),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)?.language ?? '',
                    style: myTextTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                _listLanguage(),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppLocalizations.of(context)?.dailyReminder ?? '',
                    style: myTextTheme.titleLarge,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.restaurantNotification ??
                            '',
                        style: myTextTheme.bodyLarge,
                      ),
                    ),
                    Switch.adaptive(
                      value: _isDailyReminderEnable,
                      onChanged: _remiderChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listLanguage() {
    return Column(
      children: [
        ...AppLocalizations.supportedLocales.map((Locale locale) {
          final localeFlag = Localization.getFlag(locale.languageCode);
          final localeName = Localization.getName(locale.languageCode);
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedLanguage = locale.languageCode;
              });
              final provider =
                  Provider.of<SettingProvider>(context, listen: false);
              provider.setLocale(locale);
            },
            child: Row(
              children: [
                Text(
                  localeFlag,
                  style: myTextTheme.headline6,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localeName,
                    style: myTextTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 8),
                Radio<String>(
                  value: locale.languageCode,
                  groupValue: _selectedLanguage,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedLanguage = locale.languageCode;
                    });
                    final provider =
                        Provider.of<SettingProvider>(context, listen: false);
                    provider.setLocale(locale);
                  },
                  activeColor: Colors.white,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _remiderChanged(bool value) {
    setState(() {
      _isDailyReminderEnable = value;
    });

    final settingProvider = Provider.of<SettingProvider>(
      context,
      listen: false,
    );

    settingProvider.initNotifications();
    settingProvider.setSchedule(context, value);
  }
}
