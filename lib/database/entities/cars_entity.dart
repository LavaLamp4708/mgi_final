import 'package:floor/floor.dart';

@entity
class CarsEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String brand;
  final String model;
  final int numberOfPassengers;
  final double gasTankOrBatterySize; // Litres or kWh

  CarsEntity(
      this.id,
      this.brand,
      this.model,
      this.numberOfPassengers,
      this.gasTankOrBatterySize
      ) {
    ID = id > ID ? id+1 : ID;
  }
}