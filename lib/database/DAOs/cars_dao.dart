import 'package:floor/floor.dart';
import 'package:mgi_final/database/entities/cars_entity.dart';

@dao
abstract class CarsDAO{
  @Query('SELECT * FROM CarsEntity')
  Future<List<CarsEntity>> getAll();

  @insert
  Future<void> doInsert(CarsEntity car);

  @update
  Future<void> doUpdate(CarsEntity car);

  @delete
  Future<void> doDelete(CarsEntity car);
}