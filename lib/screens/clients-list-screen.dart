import 'package:flutter/material.dart';

import './../models/global-exception-model.dart';
import './../widgets/snackbar-error-widget.dart';
import './../services/api-service.dart';
import './../models/client-model.dart';

class ClientsListScreen extends StatefulWidget {
  final bool _bShowAppBar;

  ClientsListScreen(this._bShowAppBar);

  @override
  ClientsListState createState() => ClientsListState(_bShowAppBar);
}

class ClientsListState extends State<ClientsListScreen> {
  List<ClientModel> _clientsList = [];
  bool _bShowAppBar = false;

  ClientsListState(this._bShowAppBar) {
    _retrieveClientsList().catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBarErrorWidget((error as GlobalException).buildMessage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clients list'),
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: this._bShowAppBar,
      ),
      body: ListView.builder(
        itemCount: _clientsList.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Card(
              child: ListTile(
                title: Text(_clientsList[index].strNickName),
                onTap: () {
                  Navigator.pop(context, {'client': _clientsList[index]});
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future _retrieveClientsList() async {
    ApiService().getClients().then((dynamic response) {
      if (response.runtimeType.toString().indexOf('List<ClientModel>') != -1) {
        setState(() {
          _clientsList = response;
        });
      } else {
        throw response;
      }
    }).catchError((error) {
      throw error;
    });
  }
}
