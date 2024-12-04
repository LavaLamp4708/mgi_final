import 'package:floor/floor.dart';
import 'package:mgi_final/database/entities/car_dealerships_entity.dart';

@dao
abstract class CarDealershipsDAO {
  @Query('SELECT * FROM CarDealershipsEntity')
  Future<List<CarDealershipsEntity>> getAll();

  @insert
  Future<void> doInsert(CarDealershipsEntity dealership);

  @update
  Future<void> doUpdate(CarDealershipsEntity dealership);

  @delete
  Future<void> doDelete(CarDealershipsEntity dealership);
}
