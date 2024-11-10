import 'package:floor/floor.dart';

@entity
class CustomersEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String customer;

  CustomersEntity(this.id, this.customer) {
    ID = id > ID ? id+1 : ID;
  }
}