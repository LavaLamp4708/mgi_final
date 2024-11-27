import 'package:floor/floor.dart';
import 'package:mgi_final/database/entities/car_dealerships_entity.dart';

@dao
abstract class CarDealershipsDAO{
  @Query('SELECT * FROM CarDealershipsEntity')
  Future<List<CarDealershipsEntity>> getAll();

  @insert
  Future<void> doInsert(CarDealershipsEntity carDealership);

  @update
  Future<void> doUpdate(CarDealershipsEntity carDealership);

  @delete
  Future<void> doDelete(CarDealershipsEntity carDealership);
}