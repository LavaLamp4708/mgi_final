import 'package:floor/floor.dart';

@entity
class SalesEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String customer_id;
  final String car_id;
  final String dealership_id;
  final String date_of_purchase;

  SalesEntity(
      this.id,
      this.customer_id,
      this.car_id,
      this.dealership_id,
      this.date_of_purchase
      ) {
    ID = id > ID ? id+1 : ID;
  }
}