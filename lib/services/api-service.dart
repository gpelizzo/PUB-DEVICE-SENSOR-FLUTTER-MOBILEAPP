import 'dart:io';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import './../models/client-model.dart';
import '../models/global-exception-model.dart';
import './../models/device-measures-model.dart';
import 'app-settings-service.dart';

class ApiService {
  static const String API_PREFIX = 'client';
  static const String API_END_POINT__LAST_SENSORS_VALUES =
      "last-sensors-values";
  static const String API_END_POINT__CLIENTS = 'clients';
  static const String API_END_POINT__RANGE_DEVICE_VALUES =
      'range-device-values';

  Future getRangeDeviceMeasures(String pstrApiClientId, int piDeviceAddr,
      DateTime pdtFrom, DateTime pdtTo) async {
    try {
      final Uri _strUri = Uri.https(AppSettingsService.apiUrl,
          API_PREFIX + '/' + API_END_POINT__RANGE_DEVICE_VALUES, {
        'APIclientID': pstrApiClientId,
        'deviceAddr': piDeviceAddr.toString(),
        'dateFrom':
            DateFormat('yyyy-MM-dd HH:mm:ss').format(pdtFrom).toString(),
        'dateTo': DateFormat('yyyy-MM-dd HH:mm:ss').format(pdtTo).toString()
      });

      return get(_strUri,
              headers: {HttpHeaders.contentTypeHeader: 'application/json'})
          .then((Response getResponse) {
        if (getResponse.statusCode == 200) {
          final List listItems = jsonDecode(getResponse.body)['data'] as List;
          List<DeviceMeasuresModel> listMeasures = [];
          listItems.forEach((item) {
            listMeasures.add(DeviceMeasuresModel(
                pstrApiClientId,
                piDeviceAddr,
                item['name'].toString(),
                DateTime.parse(item['date_time'].toString()).add(
                    Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                double.parse(item['temperature'].toString()),
                double.parse(item['humidity'].toString()),
                double.parse(item['partial_pressure'].toString()),
                double.parse(item['dew_point_temperature'].toString())));
          });

          return listMeasures;
        } else {
          throw GlobalException(ENM_ERROR_CODE.ERROR_API_RESPONSE_STATUS_CODE,
              getResponse.statusCode);
        }
      }).catchError((error) {
        print(error.toString());
        throw GlobalException(ENM_ERROR_CODE.ERROR_API_QUERY, error);
      });
    } catch (error) {
      print(error.toString());
      throw GlobalException(ENM_ERROR_CODE.ERROR_API_QUERY, error);
    }
  }

  Future getClientLastMeasures(String pstrApiClientId) async {
    try {
      final Uri _strUri = Uri.https(
          AppSettingsService.apiUrl,
          API_PREFIX + '/' + API_END_POINT__LAST_SENSORS_VALUES,
          {'APIclientID': pstrApiClientId});

      return get(_strUri,
              headers: {HttpHeaders.contentTypeHeader: 'application/json'})
          .then((Response getResponse) {
        if (getResponse.statusCode == 200) {
          final List listItems = jsonDecode(getResponse.body)['data'] as List;
          List<DeviceMeasuresModel> listDevices = [];
          listItems.forEach((item) {
            listDevices.add(DeviceMeasuresModel(
                pstrApiClientId,
                int.parse(item['device_addr'].toString()),
                item['name'].toString(),
                DateTime.parse(item['date_time'].toString()).add(
                    Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                double.parse(item['temperature'].toString()),
                double.parse(item['humidity'].toString()),
                double.parse(item['partial_pressure'].toString()),
                double.parse(item['dew_point_temperature'].toString())));
          });

          return listDevices;
        } else {
          throw GlobalException(ENM_ERROR_CODE.ERROR_API_RESPONSE_STATUS_CODE,
              getResponse.statusCode);
        }
      }).catchError((error) {
        throw GlobalException(ENM_ERROR_CODE.ERROR_API_QUERY, error);
      });
    } catch (error) {
      throw GlobalException(ENM_ERROR_CODE.ERROR_API_QUERY, error);
    }
  }

  Future getClients() async {
    try {
      final Uri _strUri = Uri.https(
          AppSettingsService.apiUrl, API_PREFIX + '/' + API_END_POINT__CLIENTS);

      return get(_strUri,
              headers: {HttpHeaders.contentTypeHeader: 'application/json'})
          .then((Response getResponse) {
        if (getResponse.statusCode == 200) {
          final List listItems = jsonDecode(getResponse.body)['data'] as List;
          List<ClientModel> listClients = [];
          listItems.forEach((item) {
            listClients.add(ClientModel(
                item['api_client_id'].toString(), item['nickname'].toString()));
          });

          return listClients;
        } else {
          throw GlobalException(ENM_ERROR_CODE.ERROR_API_RESPONSE_STATUS_CODE,
              getResponse.statusCode);
        }
      }).catchError((error) {
        throw GlobalException(ENM_ERROR_CODE.ERROR_API_QUERY, error);
      });
    } catch (error) {
      throw GlobalException(ENM_ERROR_CODE.ERROR_API_QUERY, error);
    }
  }
}
