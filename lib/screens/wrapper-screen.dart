import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wine_cellar/models/client-model.dart';
import 'package:wine_cellar/services/authenticate-service.dart';

import './../services/app-settings-service.dart';
import 'clients-list-screen.dart';
import 'devices-list-screen.dart';
import 'home-screen.dart';
import 'authenticate-screen.dart';
import './../models/user-model.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserModel user = Provider.of<UserModel>(context);

    if (AppSettingsService.apiUrl.isEmpty) {
      return HomeScreen();
    } else {
      if (user == null) {
        return AuthenticateScreen();
      } else {
        return DevicesListScreen(); //HomeScreen();
      }
    }
  }
}

/*
WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => ClientsListScreen()))
            .then((result) {
          _currentClient = ClientModel((result['client'] as ClientModel).strId,
              (result['client'] as ClientModel).strNickName);

          retrieveMeasures().catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBarErrorWidget((error as GlobalException).buildMessage()));
          });
        });
      });
*/