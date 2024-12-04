import 'package:floor/floor.dart';

@Entity(tableName: 'CarDealershipsEntity')
class CarDealershipsEntity {
  static int ID = 1;

  @primaryKey
  final int? id;  // Nullable primary key for auto-increment
  final String streetAddress;
  final String city;
  final String postalCode;
  final String carDealershipName;

  CarDealershipsEntity({
    this.id,  // id is nullable for auto-increment
    required this.streetAddress,
    required this.city,
    required this.postalCode,
    required this.carDealershipName
  });
}

