import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import './../screens/charts-screen.dart';
import './../models/device-measures-model.dart';

class DeviceCardWidget extends StatelessWidget {
  final DeviceMeasuresModel _deviceMeasures;

  DeviceCardWidget(this._deviceMeasures);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WGCardTitle(context),
            SizedBox(
              height: 20.0,
            ),
            WGTempHum(),
            SizedBox(
              height: 20.0,
            ),
            WGPartialPressureDewPointTemp(),
            SizedBox(
              height: 30.0,
            ),
            WGFooter(context),
          ],
        ),
      ),
    );
  }

  Widget WGPartialPressureDewPointTemp() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Container(
        height: 40.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.indigo[800],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/partial-pressure.svg',
                    height: 15.0,
                    color: Colors.red[900],
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    this._deviceMeasures.dPartialPressure.toStringAsFixed(1) +
                        'mmHg',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.indigo[900],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/dew-point-temperature.svg',
                    height: 15.0,
                    color: Colors.red[900],
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    this
                            ._deviceMeasures
                            .dDewPointTemperature
                            .toStringAsFixed(1) +
                        '°',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.indigo[900],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget WGFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(5.0, 0, 0, 0),
          child: Text(
            DateFormat('yyyy/MM/dd - HH:mm:ss')
                .format(this._deviceMeasures.dtDateTimeMeasures),
            //this.mDeviceValues.mdtDateTime.toString(),
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
          child: Container(
            height: 30.0,
            width: 30.0,
            child: FittedBox(
              child: FloatingActionButton(
                backgroundColor: Colors.indigo[900],
                heroTag: this._deviceMeasures.iDeviceAddr.toString(),
                onPressed: () async {
                  //print('click: ' + this.mDeviceValues.miAddress.toString());
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChartsMeasuresScreen(),
                        settings: RouteSettings(
                          arguments: {
                            'clientId': this._deviceMeasures.strClientId,
                            'deviceAddress': this._deviceMeasures.iDeviceAddr,
                          },
                        ),
                      ));
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                },
                child: SvgPicture.asset(
                  'assets/chart.svg',
                  height: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget WGTempHum() {
    return Column(
      children: [
        Container(
            child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(2.0),
              child: SvgPicture.asset(
                'assets/temperature.svg',
                semanticsLabel: '',
                height: 25.0,
                color: Colors.red[900],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.0),
              child: Text(
                this._deviceMeasures.dTemperature.toStringAsFixed(1) + '°',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.0,
                  color: Colors.indigo[900],
                ),
              ),
            ),
          ],
        )),
        SizedBox(
          height: 15.0,
        ),
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.all(2.0),
              child: SvgPicture.asset(
                'assets/drop.svg',
                semanticsLabel: '',
                height: 20.0,
                color: Colors.red[900],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(2.0, 2.0, 8.0, 2.0),
              child: Text(
                this._deviceMeasures.dHumidity.toStringAsFixed(1) + '%',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.0,
                  color: Colors.indigo[900],
                ),
              ),
            ),
          ],
        ))
      ],
    );
  }

  Widget WGCardTitle(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor, //Colors.indigo[700],
      height: 45.0,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Center(
                child: Text(
                  this._deviceMeasures.strDeviceName,
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
