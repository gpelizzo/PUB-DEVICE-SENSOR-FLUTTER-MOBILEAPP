import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import './../screens/wrapper-screen.dart';
import './../services/app-settings-service.dart';
import './../widgets/settings-item-widget.dart';
import './../services/authenticate-service.dart';

class HomeScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  String _strAPIUrl = AppSettingsService.apiUrl;
  String _strApiToken = AppSettingsService.apiToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).home_screen_title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 40.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(AppLocalizations.of(context).home_screen_message,
                style: TextStyle(
                  height: 2.0,
                  fontSize: 15,
                )),
          ),
          SizedBox(
            height: 15.0,
          ),
          Form(
            key: _formKey,
            child: SettingsItemWidget(
              title: 'API URL',
              hintText: AppLocalizations.of(context).home_screen_url_hint,
              defaultValue: _strAPIUrl,
              validatorFunc: (String value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)
                      .home_screen_url_validation_1;
                }

                if ((value.contains('http')) ||
                    (value.contains(':')) ||
                    (value.contains('//'))) {
                  return AppLocalizations.of(context)
                      .home_screen_url_validation_2;
                }
                _strAPIUrl = value;
                return null;
              },
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            child: Text(AppLocalizations.of(context).home_screen_submit_title),
            onPressed: () async {
              print('press');
              if (_formKey.currentState.validate()) {
                await AppSettingsService.setApiToken(_strApiToken);
                await AppSettingsService.setApiUrl(_strAPIUrl);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => StreamProvider.value(
                            value: AuthenticateService.user,
                            initialData: null,
                            child: Wrapper(),
                          )),
                  (route) => false,
                );
                /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)
                      .home_screen_submit_snackbar),
                ));*/
              }
            },
          ),
        ),
      ],
    );
  }
}
