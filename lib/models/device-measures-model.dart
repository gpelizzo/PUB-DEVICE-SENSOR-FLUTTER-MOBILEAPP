class DeviceMeasuresModel {
  String strClientId;
  int iDeviceAddr;
  String strDeviceName;
  DateTime dtDateTimeMeasures;
  double dTemperature;
  double dHumidity;
  double dPartialPressure;
  double dDewPointTemperature;

  DeviceMeasuresModel(
      this.strClientId,
      this.iDeviceAddr,
      this.strDeviceName,
      this.dtDateTimeMeasures,
      this.dTemperature,
      this.dHumidity,
      this.dPartialPressure,
      this.dDewPointTemperature);
}
