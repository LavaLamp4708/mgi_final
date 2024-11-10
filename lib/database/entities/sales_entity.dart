import 'package:floor/floor.dart';

@entity
class SalesEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String sale;

  SalesEntity(this.id, this.sale) {
    ID = id > ID ? id+1 : ID;
  }
}