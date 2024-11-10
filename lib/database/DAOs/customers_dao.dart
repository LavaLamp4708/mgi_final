import 'package:floor/floor.dart';
import 'package:mgi_final/database/entities/customers_entity.dart';

@dao
abstract class CustomersDAO{
  @Query('SELECT * FROM CustomersEntity')
  Future<List<CustomersEntity>> getAll();

  @insert
  Future<void> doInsert(CustomersEntity customer);

  @delete
  Future<void> doDelete(CustomersEntity customer);
}