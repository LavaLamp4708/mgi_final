import 'package:floor/floor.dart';
import 'package:mgi_final/database/entities/car_dealerships_entity.dart';
import 'package:mgi_final/database/entities/cars_entity.dart';
import 'package:mgi_final/database/entities/customers_entity.dart';
import 'package:mgi_final/database/entities/sales_entity.dart';
import 'package:mgi_final/database/DAOs/car_dealerships_dao.dart';
import 'package:mgi_final/database/DAOs/cars_dao.dart';
import 'package:mgi_final/database/DAOs/customers_dao.dart';
import 'package:mgi_final/database/DAOs/sales_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';  // This tells Dart to generate the `database.g.dart` file

@Database(version: 1, entities: [
  CarDealershipsEntity,
  CarsEntity,
  CustomersEntity,
  SalesEntity,
])
abstract class MGIFinalDatabase extends FloorDatabase {
  CarDealershipsDAO get carDealershipsDAO;
  CarsDAO get carsDAO;
  CustomersDAO get customersDAO;
  SalesDAO get salesDAO;
}
