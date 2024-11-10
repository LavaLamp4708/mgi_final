import 'package:floor/floor.dart';
import 'package:mgi_final/database/entities/sales_entity.dart';

@dao
abstract class SalesDAO{
  @Query('SELECT * FROM SalesEntity')
  Future<List<SalesEntity>> getAll();

  @insert
  Future<void> doInsert(SalesEntity sale);

  @delete
  Future<void> doDelete(SalesEntity sale);
}