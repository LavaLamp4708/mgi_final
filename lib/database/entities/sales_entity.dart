import 'package:floor/floor.dart';

@entity
class SalesEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String customerId;
  final String carId;
  final String dealershipId;
  final String dateOfPurchase;

  SalesEntity(
      this.id,
      this.customerId,
      this.carId,
      this.dealershipId,
      this.dateOfPurchase
      ) {
    ID = id > ID ? id+1 : ID;
  }
}