import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:io' show Platform;

import './../models/user-model.dart';
import './../services/authenticate-service.dart';

class AuthenticateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                AppLocalizations.of(context).authenticated_screen_signin_to_app,
                style: TextStyle(
                  fontSize: 20,
                )),
            SizedBox(
              height: 35,
            ),
            Center(
              child: SignInButton(
                Buttons.Google,
                onPressed: () async {
                  UserModel user = await AuthenticateService.signInWithGoogle();
                },
              ),
            ),
            /*Center(
              child: SignInButton(
                Buttons.Microsoft,
                onPressed: () {},
              ),
            ),
            if (Platform.isIOS)
              Center(
                child: SignInButton(
                  Buttons.Apple,
                  onPressed: () {},
                ),
              ),*/
          ],
        ),
      ),
    );
  }
}
