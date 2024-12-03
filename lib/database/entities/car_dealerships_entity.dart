import 'package:floor/floor.dart';

@Entity(tableName: 'CarDealershipsEntity')
class CarDealershipsEntity {
  @primaryKey
  final int? id;  // Nullable primary key for auto-increment
  final String streetAddress;
  final String city;
  final String postalCode;

  CarDealershipsEntity({
    this.id,  // id is nullable for auto-increment
    required this.streetAddress,
    required this.city,
    required this.postalCode,
  });
}

