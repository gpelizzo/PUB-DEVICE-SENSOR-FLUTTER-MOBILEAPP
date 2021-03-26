import 'package:flutter/material.dart';

class SettingsItemWidget extends StatelessWidget {
  String title;
  String defaultValue;
  String hintText;
  Function validatorFunc;

  SettingsItemWidget(
      {this.title, this.defaultValue, this.hintText, this.validatorFunc});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        this.title,
        style: TextStyle(color: Colors.blue[800]),
      ),
      subtitle: TextFormField(
        decoration: InputDecoration(
          hintText: this.hintText,
          /*fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink, width: 2.0),
          ),*/
        ),
        initialValue: this.defaultValue,
        validator: this.validatorFunc,
      ),
    );
  }
}
