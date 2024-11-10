import 'package:floor/floor.dart';

@entity
class CarDealershipsEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String carDealership;

  CarDealershipsEntity(this.id, this.carDealership) {
    ID = id > ID ? id+1 : ID;
  }
}