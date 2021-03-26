import 'dart:math';

import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:charts_flutter/src/text_element.dart' as chartsTextElement;
import 'package:charts_flutter/src/text_style.dart' as chartsTextStyle;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import './../widgets/snackbar-error-widget.dart';
import './../models/global-exception-model.dart';
import './../services/api-service.dart';
import './../models/device-measures-model.dart';

enum ENM_MEASURES_VISUALIZATION {
  TEMPERATURE,
  HUMIDITY,
  PARTIAL_PRESSURE,
  DEW_POINT_HUMIDITY
}

enum ENM_UPDATE_VALUES { NEXT, PREVIOUS }

class ChartsMeasuresScreen extends StatefulWidget {
  @override
  ChartsMeasuresState createState() => ChartsMeasuresState();
}

class ChartsMeasuresState extends State<ChartsMeasuresScreen> {
  /*list of the measures returned by the API*/
  List<DeviceMeasuresModel> _listDeviceMeasures = [];

  /*Chart series including measures and chart parameters and behaviours*/
  List<charts.Series<DeviceMeasuresModel, DateTime>> _seriesList = [];

  /*record the measures (+date/time) pointed by the user in order to display a specific point on the chart-line*/
  PointedMeasure _pointedMeasure = new PointedMeasure();

  /*Current measure vizualized, cf ENM_MEASURES_VISUALIZATION*/
  ENM_MEASURES_VISUALIZATION _measuresVisualization =
      ENM_MEASURES_VISUALIZATION.TEMPERATURE;

  /*current client ID and dervice address*/
  String _strClientId;
  int _iDeviceAddr;

  bool _bButtonOpacity = true;
  bool _bEnableButtonNextDay = false;
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    /*rotate screen to landscape*/
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    //SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    /*Ensure that measures have already been retried. Otherwise, just retrieve the measures for the current day*/
    if (_listDeviceMeasures.isEmpty) {
      /*client id and device address are passed by a device-card-widget*/
      Map paramsList = ModalRoute.of(context).settings.arguments as Map;
      _strClientId = paramsList['clientId'].toString();
      _iDeviceAddr = paramsList['deviceAddress'];

      //final DateTime dtNow = DateTime.now().add(Duration(days: -2));

      /*retreive measures for the whole day*/
      _retrieveMeasures(
              DateTime(_currentDate.year, _currentDate.month, _currentDate.day,
                  0, 0, 0),
              DateTime(_currentDate.year, _currentDate.month, _currentDate.day,
                  23, 59, 59))
          .catchError((error) {
        /*Error snackbar*/
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBarErrorWidget((error as GlobalException).buildMessage()));
      });
    }

    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Scaffold(
              body: _widgetChart(context),
              floatingActionButton: AnimatedOpacity(
                opacity: _bButtonOpacity ? 0.0 : 1.0,
                duration: Duration(milliseconds: 900),
                child: _widgetCircularMenu(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  opacity: _bButtonOpacity ? 0.0 : 1.0,
                  duration: Duration(milliseconds: 900),
                  child: _widgetDateButtons(),
                )
              ],
            ),
            GestureDetector(
              onDoubleTap: () {
                setState(() {
                  _bButtonOpacity = !_bButtonOpacity;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _widgetChart(BuildContext context) {
    print(_seriesList.length);
    return _seriesList.length == 0
        ? Container()
        : charts.TimeSeriesChart(
            _seriesList,
            animate: true,
            domainAxis: charts.DateTimeAxisSpec(
              tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                hour: charts.TimeFormatterSpec(
                  format: 'HH:mm',
                  transitionFormat: 'HH:mm',
                ),
              ),
            ),
            behaviors: [
              /**/
              charts.LinePointHighlighter(
                  symbolRenderer:
                      CustomCircleSymbolRenderer(context, _pointedMeasure)),
            ],
            selectionModels: [
              charts.SelectionModelConfig(
                changedListener: (charts.SelectionModel model) {
                  try {
                    _pointedMeasure.update(
                        model.selectedSeries[0]
                            .domainFn(model.selectedDatum[0].index)
                            .toString(),
                        model.selectedSeries[0]
                            .measureFn(model.selectedDatum[0].index)
                            .toString(),
                        _getMeasureCategoryParams()['unit_symbol'].toString());
                  } catch (error) {
                    print(error.toString());
                  }
                },
              ),
            ],
            primaryMeasureAxis: charts.NumericAxisSpec(
                tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                  (num value) => (value.toInt().toString() +
                      _getMeasureCategoryParams()['unit_symbol'].toString()),
                ),
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  zeroBound: false,
                )),
          );
  }

  Widget _widgetCircularMenu() {
    return FabCircularMenu(
      ringDiameter: 350.0,
      ringWidth: 70.0,
      fabOpenColor: Colors.indigo[900],
      fabCloseColor: Colors.indigo[900],
      ringColor: Colors.indigo[900],
      fabColor: Colors.white,
      fabOpenIcon: Icon(
        Icons.menu,
        color: Colors.white,
      ),
      fabCloseIcon: Icon(
        Icons.close,
        color: Colors.white,
      ),
      children: <Widget>[
        IconButton(
            icon: SvgPicture.asset(
              'assets/temperature.svg',
              semanticsLabel: '',
              height: 25.0,
              color: Colors.white,
            ),
            onPressed: () {
              _updateValuesCategory(0);
            }),
        IconButton(
            icon: SvgPicture.asset(
              'assets/drop.svg',
              semanticsLabel: '',
              height: 25.0,
              color: Colors.white,
            ),
            onPressed: () {
              _updateValuesCategory(1);
            }),
        IconButton(
            icon: SvgPicture.asset(
              'assets/partial-pressure.svg',
              semanticsLabel: '',
              height: 25.0,
              color: Colors.white,
            ),
            onPressed: () {
              _updateValuesCategory(2);
            }),
        IconButton(
            icon: SvgPicture.asset(
              'assets/dew-point-temperature.svg',
              semanticsLabel: '',
              height: 25.0,
              color: Colors.white,
            ),
            onPressed: () {
              _updateValuesCategory(3);
            }),
        IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    );
  }

  Widget _widgetDateButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //previous button
        FloatingActionButton(
          heroTag: 'retreive previous values',
          child: Icon(Icons.arrow_back),
          onPressed: () {
            _updateValuesRange(ENM_UPDATE_VALUES.PREVIOUS);
          },
          backgroundColor: Colors.indigo[900],
          mini: true,
        ),
        //next button
        SizedBox(
          width: 10.0,
        ),
        Text(
          DateFormat('yyyy-MM-dd').format(_currentDate).toString(),
          style: TextStyle(
            fontSize: 20,
            color: Colors.indigo[900],
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        FloatingActionButton(
          heroTag: 'retreive next values',
          child: Icon(Icons.arrow_forward),
          onPressed: _bEnableButtonNextDay
              ? () {
                  _updateValuesRange(ENM_UPDATE_VALUES.NEXT);
                }
              : null,
          backgroundColor:
              _bEnableButtonNextDay ? Colors.indigo[900] : Colors.grey[300],
          mini: true,
        ),
      ],
    );
  }

  void _updateValuesRange(ENM_UPDATE_VALUES pType) {
    setState(() {
      if (pType == ENM_UPDATE_VALUES.NEXT) {
        _currentDate = _currentDate.add(const Duration(days: 1));
      } else {
        _currentDate = _currentDate.subtract(const Duration(days: 1));
      }

      if (_currentDate.add(const Duration(days: 1)).isBefore(DateTime.now())) {
        _bEnableButtonNextDay = true;
      } else {
        _bEnableButtonNextDay = false;
      }
    });

    _retrieveMeasures(
        DateTime(
            _currentDate.year, _currentDate.month, _currentDate.day, 0, 0, 0),
        DateTime(_currentDate.year, _currentDate.month, _currentDate.day, 23,
            59, 59));
  }

  void _updateValuesCategory(int index) {
    switch (index) {
      case 0:
        _measuresVisualization = ENM_MEASURES_VISUALIZATION.TEMPERATURE;
        break;

      case 1:
        _measuresVisualization = ENM_MEASURES_VISUALIZATION.HUMIDITY;
        break;

      case 2:
        _measuresVisualization = ENM_MEASURES_VISUALIZATION.PARTIAL_PRESSURE;
        break;

      case 3:
        _measuresVisualization = ENM_MEASURES_VISUALIZATION.DEW_POINT_HUMIDITY;
        break;

      default:
        break;
    }

    setState(() {
      _updateChartSerie();
    });
  }

  void _updateChartSerie() {
    _seriesList = [
      charts.Series(
        id: 'temperature',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(
            _getMeasureCategoryParams()['color']),
        domainFn: (DeviceMeasuresModel series, _) => series.dtDateTimeMeasures,
        measureFn: (DeviceMeasuresModel series, _) {
          switch (_measuresVisualization) {
            case ENM_MEASURES_VISUALIZATION.TEMPERATURE:
              return series.dTemperature;

            case ENM_MEASURES_VISUALIZATION.HUMIDITY:
              return series.dHumidity;

            case ENM_MEASURES_VISUALIZATION.PARTIAL_PRESSURE:
              return series.dPartialPressure;

            case ENM_MEASURES_VISUALIZATION.DEW_POINT_HUMIDITY:
              return series.dDewPointTemperature;

            default:
              return null;
          }
        },
        data: _listDeviceMeasures,
      )
    ];
  }

  Future _retrieveMeasures(DateTime pdtFrom, DateTime pdtTo) async {
    return ApiService()
        .getRangeDeviceMeasures(_strClientId, _iDeviceAddr, pdtFrom, pdtTo)
        .then((dynamic response) {
      if (response.runtimeType
              .toString()
              .indexOf('List<DeviceMeasuresModel>') !=
          -1) {
        _listDeviceMeasures = response;
        setState(() {
          _updateChartSerie();
        });
      } else {
        throw response;
      }
    }).catchError((error) {
      throw error;
    });
  }

  Map _getMeasureCategoryParams() {
    switch (_measuresVisualization) {
      case ENM_MEASURES_VISUALIZATION.TEMPERATURE:
        return {'unit_symbol': '°', 'color': Colors.red};
      case ENM_MEASURES_VISUALIZATION.HUMIDITY:
        return {'unit_symbol': '%', 'color': Colors.indigo};
      case ENM_MEASURES_VISUALIZATION.PARTIAL_PRESSURE:
        return {'unit_symbol': 'mmHg', 'color': Colors.teal};
      case ENM_MEASURES_VISUALIZATION.DEW_POINT_HUMIDITY:
        return {'unit_symbol': '°', 'color': Colors.amber};

      default:
        return {'unit_symbol': '°', 'color': Colors.green};
    }
  }
}

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  PointedMeasure _pointedMeasure;
  BuildContext _context;

  CustomCircleSymbolRenderer(this._context, this._pointedMeasure);

  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      charts.Color fillColor,
      charts.FillPatternType fillPattern,
      charts.Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds);

    final textStyle = chartsTextStyle.TextStyle();
    textStyle.color = charts.Color.white;
    textStyle.fontSize = 15;

    final chartsTextElement.TextElement textElement = chartsTextElement.TextElement(
        '${_pointedMeasure.getFormattedDateTime()}: ${_pointedMeasure.getFormattedMeasureValue()}',
        style: textStyle);

    num rectWidth = bounds.left -
        5 +
        bounds.width +
        textElement.measurement.horizontalSliceWidth;
    num correction = 0;
    if (_context != null) {
      num screenWidth = MediaQuery.of(_context).size.width;

      if (rectWidth > screenWidth) {
        correction = rectWidth - screenWidth;
      }
    }

    Rectangle rect = Rectangle(
        bounds.left - 5 - correction,
        bounds.top - 30,
        bounds.width + textElement.measurement.horizontalSliceWidth,
        bounds.height + 10);
    canvas.drawRect(rect, fill: charts.ColorUtil.fromDartColor(Colors.black));

    canvas.drawText(textElement, (bounds.left - correction).round(),
        (bounds.top - 28).round());
  }
}

class PointedMeasure {
  double _dMeasureValue;
  DateTime _MeasureDateTime;
  String _strUnitSymbol;

  PointedMeasure();

  void update(String pstrMeasureDateTime, String pstrMeasureValue,
      String pstrUnitSymbol) {
    _MeasureDateTime = DateTime.parse(pstrMeasureDateTime);
    _dMeasureValue = double.parse(pstrMeasureValue);
    this._strUnitSymbol = pstrUnitSymbol;
  }

  String getFormattedDateTime() {
    return DateFormat("HH'h'mm").format(_MeasureDateTime).toString();
  }

  String getFormattedMeasureValue() {
    return _dMeasureValue.toStringAsFixed(1) + _strUnitSymbol;
  }
}
