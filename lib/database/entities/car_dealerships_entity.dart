import 'package:floor/floor.dart';

@entity
class CarDealershipsEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String carDealershipName;
  final String streetAddress;
  final String city;
  final String postalCode;

  CarDealershipsEntity(
    this.id, 
    this.carDealershipName, 
    this.streetAddress, 
    this.city, 
    this.postalCode
  ) {
    ID = id > ID ? id+1 : ID;
  }
}