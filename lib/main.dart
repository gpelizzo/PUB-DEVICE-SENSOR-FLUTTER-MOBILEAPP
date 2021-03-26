import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';

import 'services/app-settings-service.dart';
import 'screens/wrapper-screen.dart';
import 'services/authenticate-service.dart';
import 'models/user-model.dart';

void main() async {
  /*MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    localeListResolutionCallback: (locale, supportedLocales) {
      print(supportedLocales);
      return Locale('fr', '');
    },
    supportedLocales: [
      //const Locale('en', ''), // English, no country code
      const Locale('fr', ''), // French, no country code
    ],
  );*/

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //initializeDateFormatting();

  DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  bool _bIsPhysicalDevice = true;

  if (Platform.isAndroid) {
    AndroidDeviceInfo _androidInfo = await _deviceInfo.androidInfo;
    _bIsPhysicalDevice = _androidInfo.isPhysicalDevice;
  } else {
    IosDeviceInfo _iosInfo = await _deviceInfo.iosInfo;
    _bIsPhysicalDevice = _iosInfo.isPhysicalDevice;
  }

  if (!_bIsPhysicalDevice) {
    SharedPreferences.setMockInitialValues({
      'client_id': 'zzl65Uykk',
      'client_nick_name': 'Gilles',
      'api_url': 'api.gepeo.fr',
      'api_token': ''
    });
  }

  /*Retrieve App settings from local storage*/
  await AppSettingsService.init();

  runApp(MainApp(_bIsPhysicalDevice));
}

class MainApp extends StatelessWidget {
  bool _bIsPhysicalDevice = false;

  MainApp(this._bIsPhysicalDevice);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: !_bIsPhysicalDevice ? Locale('fr', '') : null,
      home: StreamProvider<UserModel>.value(
        value: AuthenticateService.user,
        initialData: null,
        child: Wrapper(),
      ),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
        ),
        backgroundColor: Colors.indigo[700],
      ),
    );
  }
}
