import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './../screens/settings-screen.dart';
import './../models/client-model.dart';
import './../screens/clients-list-screen.dart';

class MainDrawerWidget extends StatelessWidget {
  final ValueChanged<ClientModel> onChangeClient;

  const MainDrawerWidget({Key key, this.onChangeClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              AppLocalizations.of(context).main_drawer_screen_menu_title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
            child: Card(
              elevation: 0,
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)
                      .main_drawer_screen_clients_item_title,
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () async {
                  dynamic result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ClientsListScreen(true)));

                  if (result != null) {
                    onChangeClient(ClientModel(
                        (result['client'] as ClientModel).strId,
                        (result['client'] as ClientModel).strNickName));

                    /**close menu */
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Card(
              elevation: 0,
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)
                      .main_drawer_screen_settings_item_title,
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext builder) => SettingsScreen()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
