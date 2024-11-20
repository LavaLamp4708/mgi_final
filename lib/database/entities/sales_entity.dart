import 'package:floor/floor.dart';

@entity
class SalesEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final int customer_id;
  final int car_id;
  final int dealership_id;
  final DateTime date_of_purchase;

  SalesEntity(this.id, this.customer_id, this.car_id,
      this.dealership_id, this.date_of_purchase) {
    ID = id > ID ? id+1 : ID;
  }
}