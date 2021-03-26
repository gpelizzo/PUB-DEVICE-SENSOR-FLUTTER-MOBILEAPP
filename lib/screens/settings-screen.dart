import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import './../models/client-model.dart';
import './../screens/clients-list-screen.dart';
import './../services/authenticate-service.dart';
import './../services/app-settings-service.dart';
import 'wrapper-screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings_screen_title),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
                AppLocalizations.of(context)
                    .settings_screen_favorite_client_title,
                style: TextStyle(color: Colors.blue[800])),
            subtitle: Text(AppSettingsService.favoriteClient.isEmpty()
                ? AppLocalizations.of(context)
                    .settings_screen_favorite_client_not_specified
                : AppSettingsService.favoriteClient.strNickName),
            trailing: Wrap(
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context)
                      .settings_screen_favorite_client_button_update),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ClientsListScreen(true))).then((result) {
                      setState(() {
                        AppSettingsService.setFavoriteClient(ClientModel(
                            (result['client'] as ClientModel).strId,
                            (result['client'] as ClientModel).strNickName));
                      });
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text(
              'API URL',
              style: TextStyle(color: Colors.blue[800]),
            ),
            subtitle: Text(AppSettingsService.apiUrl),
            trailing: Wrap(
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context)
                      .settings_screen_update_api_url),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(AppLocalizations.of(context)
                              .settings_screen_update_api_url_alertdialog_title),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                Text(AppLocalizations.of(context)
                                    .settings_screen_update_api_url_alertdialog_message),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text(AppLocalizations.of(context)
                                  .settings_screen_update_api_url_alertdialog_action_cancel),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text(AppLocalizations.of(context)
                                  .settings_screen_update_api_url_alertdialog_action_proceed),
                              onPressed: () async {
                                await AppSettingsService.reset();
                                await AuthenticateService.signOutGoogle();

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          StreamProvider.value(
                                            value: AuthenticateService.user,
                                            initialData: null,
                                            child: Wrapper(),
                                          )),
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          ListTile(
            title: Text(
                AppLocalizations.of(context).settings_screen_account_title,
                style: TextStyle(color: Colors.blue[800])),
            subtitle: Text(AuthenticateService.currentUser != null
                ? AuthenticateService.currentUser.email
                : '-'),
          ),
          SizedBox(
            height: 5,
          ),
          ListTile(
            title: Text(
              'Version',
              style: TextStyle(color: Colors.blue[800]),
            ),
            subtitle: Text(AppSettingsService.appVersion),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
      persistentFooterButtons: [
        Container(
          width: MediaQuery.of(context).copyWith().size.width,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: Text(
                      AppLocalizations.of(context)
                          .main_drawer_screen_logout_item_title,
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  onPressed: () async {
                    await AuthenticateService.signOutGoogle();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
