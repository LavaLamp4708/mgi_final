import 'package:floor/floor.dart';

@entity
class SalesEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final int customerId;
  final int carId;
  final int dealershipId;
  final String datOfPurchase;

  SalesEntity(
    this.id, 
    this.customerId, 
    this.carId, 
    this.dealershipId, 
    this.datOfPurchase
  ) {
    ID = id > ID ? id+1 : ID;
  }
}