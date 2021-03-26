import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

import './../models/client-model.dart';

class AppSettingsService {
  static SharedPreferences _sharedPreferences;

  //static const String _appVersion = '1.0';
  static String _strAPIUrl = '';
  static String _strAPIToken = '';
  static ClientModel _cmFavoriteClient = ClientModel.fromClientModel();
  static PackageInfo packageInfo;

  static Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();

    return await SharedPreferences.getInstance()
        .then((SharedPreferences pSharedPreferenceInstance) {
      _sharedPreferences = pSharedPreferenceInstance;

      _strAPIUrl = _sharedPreferences.containsKey('api_url')
          ? _sharedPreferences.getString('api_url')
          : '';
      _strAPIToken = _sharedPreferences.containsKey('api_token')
          ? _sharedPreferences.getString('api_token')
          : '';
      _cmFavoriteClient.strId = _sharedPreferences.containsKey('client_id')
          ? _sharedPreferences.getString('client_id')
          : '';

      _cmFavoriteClient.strNickName =
          _sharedPreferences.containsKey('client_nick_name')
              ? _sharedPreferences.getString('client_nick_name')
              : '';
    }).catchError((handleError) {
      print(handleError.toString());
    });
  }

  static String get apiUrl => _strAPIUrl;
  static Future<void> setApiUrl(String strValue) async {
    _strAPIUrl = strValue;
    await _sharedPreferences.setString('api_url', strValue);
  }

  static String get apiToken => _strAPIToken;
  static Future<void> setApiToken(String strValue) async {
    _strAPIToken = strValue;
    await _sharedPreferences.setString('api_token', strValue);
  }

  static String get appVersion => packageInfo.version;

  static setFavoriteClient(ClientModel clientModel) async {
    _cmFavoriteClient = clientModel;
    await _sharedPreferences.setString('client_id', clientModel.strId);
    await _sharedPreferences.setString(
        'client_nick_name', clientModel.strNickName);
  }

  static Future<void> reset() async {
    _strAPIUrl = '';
    await _sharedPreferences.setString('api_url', '');

    _strAPIToken = '';
    await _sharedPreferences.setString('api_token', '');

    _cmFavoriteClient = ClientModel.fromClientModel();
    await _sharedPreferences.setString('client_id', '');
    await _sharedPreferences.setString('client_nick_name', '');
  }

  static ClientModel get favoriteClient => _cmFavoriteClient;
}
