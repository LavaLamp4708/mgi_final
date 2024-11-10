// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $MGIFinalDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $MGIFinalDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $MGIFinalDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<MGIFinalDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorMGIFinalDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $MGIFinalDatabaseBuilderContract databaseBuilder(String name) =>
      _$MGIFinalDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $MGIFinalDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$MGIFinalDatabaseBuilder(null);
}

class _$MGIFinalDatabaseBuilder implements $MGIFinalDatabaseBuilderContract {
  _$MGIFinalDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $MGIFinalDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $MGIFinalDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<MGIFinalDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$MGIFinalDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$MGIFinalDatabase extends MGIFinalDatabase {
  _$MGIFinalDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CarDealershipsDAO? _carDealershipsDAOInstance;

  CarsDAO? _carsDAOInstance;

  CustomersDAO? _customersDAOInstance;

  SalesDAO? _salesDAOInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CarDealershipsEntity` (`id` INTEGER NOT NULL, `carDealership` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CarsEntity` (`id` INTEGER NOT NULL, `car` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CustomersEntity` (`id` INTEGER NOT NULL, `customer` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SalesEntity` (`id` INTEGER NOT NULL, `sale` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CarDealershipsDAO get carDealershipsDAO {
    return _carDealershipsDAOInstance ??=
        _$CarDealershipsDAO(database, changeListener);
  }

  @override
  CarsDAO get carsDAO {
    return _carsDAOInstance ??= _$CarsDAO(database, changeListener);
  }

  @override
  CustomersDAO get customersDAO {
    return _customersDAOInstance ??= _$CustomersDAO(database, changeListener);
  }

  @override
  SalesDAO get salesDAO {
    return _salesDAOInstance ??= _$SalesDAO(database, changeListener);
  }
}

class _$CarDealershipsDAO extends CarDealershipsDAO {
  _$CarDealershipsDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _carDealershipsEntityInsertionAdapter = InsertionAdapter(
            database,
            'CarDealershipsEntity',
            (CarDealershipsEntity item) => <String, Object?>{
                  'id': item.id,
                  'carDealership': item.carDealership
                }),
        _carDealershipsEntityDeletionAdapter = DeletionAdapter(
            database,
            'CarDealershipsEntity',
            ['id'],
            (CarDealershipsEntity item) => <String, Object?>{
                  'id': item.id,
                  'carDealership': item.carDealership
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CarDealershipsEntity>
      _carDealershipsEntityInsertionAdapter;

  final DeletionAdapter<CarDealershipsEntity>
      _carDealershipsEntityDeletionAdapter;

  @override
  Future<List<CarDealershipsEntity>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM CarDealershipsEntity',
        mapper: (Map<String, Object?> row) => CarDealershipsEntity(
            row['id'] as int, row['carDealership'] as String));
  }

  @override
  Future<void> doInsert(CarDealershipsEntity carDealership) async {
    await _carDealershipsEntityInsertionAdapter.insert(
        carDealership, OnConflictStrategy.abort);
  }

  @override
  Future<void> doDelete(CarDealershipsEntity carDealership) async {
    await _carDealershipsEntityDeletionAdapter.delete(carDealership);
  }
}

class _$CarsDAO extends CarsDAO {
  _$CarsDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _carsEntityInsertionAdapter = InsertionAdapter(
            database,
            'CarsEntity',
            (CarsEntity item) =>
                <String, Object?>{'id': item.id, 'car': item.car}),
        _carsEntityDeletionAdapter = DeletionAdapter(
            database,
            'CarsEntity',
            ['id'],
            (CarsEntity item) =>
                <String, Object?>{'id': item.id, 'car': item.car});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CarsEntity> _carsEntityInsertionAdapter;

  final DeletionAdapter<CarsEntity> _carsEntityDeletionAdapter;

  @override
  Future<List<CarsEntity>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM CarsEntity',
        mapper: (Map<String, Object?> row) =>
            CarsEntity(row['id'] as int, row['car'] as String));
  }

  @override
  Future<void> doInsert(CarsEntity car) async {
    await _carsEntityInsertionAdapter.insert(car, OnConflictStrategy.abort);
  }

  @override
  Future<void> doDelete(CarsEntity car) async {
    await _carsEntityDeletionAdapter.delete(car);
  }
}

class _$CustomersDAO extends CustomersDAO {
  _$CustomersDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customersEntityInsertionAdapter = InsertionAdapter(
            database,
            'CustomersEntity',
            (CustomersEntity item) =>
                <String, Object?>{'id': item.id, 'customer': item.customer}),
        _customersEntityDeletionAdapter = DeletionAdapter(
            database,
            'CustomersEntity',
            ['id'],
            (CustomersEntity item) =>
                <String, Object?>{'id': item.id, 'customer': item.customer});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CustomersEntity> _customersEntityInsertionAdapter;

  final DeletionAdapter<CustomersEntity> _customersEntityDeletionAdapter;

  @override
  Future<List<CustomersEntity>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM CustomersEntity',
        mapper: (Map<String, Object?> row) =>
            CustomersEntity(row['id'] as int, row['customer'] as String));
  }

  @override
  Future<void> doInsert(CustomersEntity customer) async {
    await _customersEntityInsertionAdapter.insert(
        customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> doDelete(CustomersEntity customer) async {
    await _customersEntityDeletionAdapter.delete(customer);
  }
}

class _$SalesDAO extends SalesDAO {
  _$SalesDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _salesEntityInsertionAdapter = InsertionAdapter(
            database,
            'SalesEntity',
            (SalesEntity item) =>
                <String, Object?>{'id': item.id, 'sale': item.sale}),
        _salesEntityDeletionAdapter = DeletionAdapter(
            database,
            'SalesEntity',
            ['id'],
            (SalesEntity item) =>
                <String, Object?>{'id': item.id, 'sale': item.sale});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SalesEntity> _salesEntityInsertionAdapter;

  final DeletionAdapter<SalesEntity> _salesEntityDeletionAdapter;

  @override
  Future<List<SalesEntity>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM SalesEntity',
        mapper: (Map<String, Object?> row) =>
            SalesEntity(row['id'] as int, row['sale'] as String));
  }

  @override
  Future<void> doInsert(SalesEntity sale) async {
    await _salesEntityInsertionAdapter.insert(sale, OnConflictStrategy.abort);
  }

  @override
  Future<void> doDelete(SalesEntity sale) async {
    await _salesEntityDeletionAdapter.delete(sale);
  }
}
