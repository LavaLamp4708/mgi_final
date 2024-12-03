import 'package:flutter/material.dart';
import 'package:mgi_final/database/database.dart';
import 'package:mgi_final/database/entities/car_dealerships_entity.dart';

class CarDealershipListPage extends StatefulWidget {
  final String title;
  const CarDealershipListPage({Key? key, required this.title}) : super(key: key);

  @override
  State<CarDealershipListPage> createState() => _CarDealershipListPageState();
}

class _CarDealershipListPageState extends State<CarDealershipListPage> {
  late final MGIFinalDatabase _database;
  List<CarDealershipsEntity> _dealerships = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();
  bool _copyPrevious = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await $FloorMGIFinalDatabase
        .databaseBuilder('mgi_final.db')
        .build();
    _loadDealerships();
  }

  Future<void> _loadDealerships() async {
    final dealerships = await _database.carDealershipsDAO.getAll();
    setState(() {
      _dealerships = dealerships;
    });
  }

  Future<void> _addOrUpdateDealership({CarDealershipsEntity? existing}) async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _postalCodeController.text.isEmpty) {
      _showErrorDialog('All fields must be filled!');
      return;
    }

    final dealership = CarDealershipsEntity(
      existing?.id ?? CarDealershipsEntity.ID,
      _nameController.text,
      _addressController.text,
      _cityController.text,
      _postalCodeController.text,
    );

    if (existing == null) {
      await _database.carDealershipsDAO.doInsert(dealership);
    } else {
      await _database.carDealershipsDAO.doUpdate(dealership);
    }

    _clearFields();
    _loadDealerships();
  }

  Future<void> _deleteDealership(CarDealershipsEntity dealership) async {
    await _database.carDealershipsDAO.doDelete(dealership);
    _loadDealerships();
  }

  void _clearFields() {
    setState(() {
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
      _postalCodeController.clear();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({CarDealershipsEntity? existing}) {
    if (existing != null) {
      _nameController.text = existing.carDealershipName;
      _addressController.text = existing.streetAddress;
      _cityController.text = existing.city;
      _postalCodeController.text = existing.postalCode;
    } else if (_copyPrevious && _dealerships.isNotEmpty) {
      final last = _dealerships.last;
      _nameController.text = last.carDealershipName;
      _addressController.text = last.streetAddress;
      _cityController.text = last.city;
      _postalCodeController.text = last.postalCode;
    } else {
      _clearFields();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Dealership' : 'Edit Dealership'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Street Address'),
            ),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: _postalCodeController,
              decoration: const InputDecoration(labelText: 'Postal Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearFields();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addOrUpdateDealership(existing: existing);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Switch(
            value: _copyPrevious,
            onChanged: (value) {
              setState(() {
                _copyPrevious = value;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _dealerships.length,
              itemBuilder: (context, index) {
                final dealership = _dealerships[index];
                return ListTile(
                  title: Text(dealership.carDealershipName),
                  subtitle: Text('${dealership.streetAddress}, ${dealership.city}'),
                  onTap: () => _showAddEditDialog(existing: dealership),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteDealership(dealership),
                  ),
                );
              },
            ),
          ),
          FloatingActionButton(
            onPressed: () => _showAddEditDialog(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
