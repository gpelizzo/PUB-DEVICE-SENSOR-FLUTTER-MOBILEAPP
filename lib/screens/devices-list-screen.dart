import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './../models/client-model.dart';
import './../widgets/main-drawer-widget.dart';
import './../widgets/snackbar-error-widget.dart';
import '../models/global-exception-model.dart';
import './../services/app-settings-service.dart';
import './../services/api-service.dart';
import './../widgets/device-card-widget.dart';
import './../models/device-measures-model.dart';
import 'clients-list-screen.dart';

class DevicesListScreen extends StatefulWidget {
  @override
  DevicesListState createState() => DevicesListState();
}

class DevicesListState extends State<DevicesListScreen> {
  List<DeviceMeasuresModel> _listDeviceMeasures = [];

  ClientModel _currentClient = ClientModel.fromClientModel();

  void initState() {
    super.initState();

    _currentClient = AppSettingsService.favoriteClient;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentClient.isEmpty()) {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => ClientsListScreen(false)))
            .then((result) {
          _currentClient = ClientModel((result['client'] as ClientModel).strId,
              (result['client'] as ClientModel).strNickName);

          retrieveMeasures();
        });
      }
    });

    if (!_currentClient.isEmpty()) {
      retrieveMeasures().catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBarErrorWidget((error as GlobalException).buildMessage()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentClient.strNickName),
      ),
      drawer: MainDrawerWidget(onChangeClient: (ClientModel client) {
        setState(() {
          _currentClient = client;
          retrieveMeasures();
        });
      }),
      body: RefreshIndicator(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: _listDeviceMeasures
              .map((DeviceMeasuresModel deviceMeasuresElement) {
            return DeviceCardWidget(deviceMeasuresElement);
          }).toList(),
        ),
        onRefresh: () async {
          retrieveMeasures();
        },
      ),
    );
  }

  Future retrieveMeasures() async {
    return ApiService()
        .getClientLastMeasures(_currentClient.strId)
        .then((dynamic response) {
      //List<DeviceMeasuresModel> plistDevices
      if (response.runtimeType
              .toString()
              .indexOf('List<DeviceMeasuresModel>') !=
          -1) {
        _listDeviceMeasures = response;
        setState(() {});
      } else {
        throw response;
      }
    }).catchError((error) {
      throw error;
    });
  }
}
