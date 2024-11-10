import 'package:floor/floor.dart';

@entity
class CarsEntity {
  static int ID = 1;

  @primaryKey
  final int id;
  final String car;

  CarsEntity(this.id, this.car) {
    ID = id > ID ? id+1 : ID;
  }
}