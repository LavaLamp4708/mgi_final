import 'package:floor/floor.dart';

@entity
class CustomersEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String birthDate;

  CustomersEntity(
      this.id,
      this.firstName,
      this.lastName,
      this.address,
      this.birthDate
      ) {
    ID = id > ID ? id+1 : ID;
  }
}