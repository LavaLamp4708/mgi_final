import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _copyPrevious = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await $FloorMGIFinalDatabase.databaseBuilder('mgi_final.db').build();
    _loadDealerships();
  }

  Future<void> _loadDealerships() async {
    final dealerships = await _database.carDealershipsDAO.getAll();
    setState(() {
      _dealerships = dealerships;
    });
  }

  Future<void> _deleteDealership(CarDealershipsEntity dealership) async {
    await _database.carDealershipsDAO.doDelete(dealership);
    _loadDealerships();
  }

  Future<CarDealershipsEntity?> loadLastDealership() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastName')) return null;
    return CarDealershipsEntity(
      id: -1,
      carDealershipName: prefs.getString('lastName')!,
      streetAddress: prefs.getString('lastAddress')!,
      city: prefs.getString('lastCity')!,
      postalCode: prefs.getString('lastPostalCode')!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Row(
            children: [
              const Text("Copy Previous"),
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
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditDealershipPage(
                          database: _database,
                          existing: dealership,
                          onSubmit: _loadDealerships,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteDealership(dealership),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          CarDealershipsEntity? lastDealership;
          if (_copyPrevious) {
            lastDealership = await loadLastDealership();
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditDealershipPage(
                database: _database,
                existing: null,
                onSubmit: _loadDealerships,
                copyPrevious: lastDealership,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditDealershipPage extends StatefulWidget {
  final MGIFinalDatabase database;
  final CarDealershipsEntity? existing;
  final Function() onSubmit;
  final CarDealershipsEntity? copyPrevious;

  const AddEditDealershipPage({
    Key? key,
    required this.database,
    required this.onSubmit,
    this.existing,
    this.copyPrevious,
  }) : super(key: key);

  @override
  State<AddEditDealershipPage> createState() => _AddEditDealershipPageState();
}

class _AddEditDealershipPageState extends State<AddEditDealershipPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();

    if (widget.existing != null) {
      _nameController.text = widget.existing!.carDealershipName;
      _addressController.text = widget.existing!.streetAddress;
      _cityController.text = widget.existing!.city;
      _postalCodeController.text = widget.existing!.postalCode;
    } else if (widget.copyPrevious != null) {
      _nameController.text = widget.copyPrevious!.carDealershipName;
      _addressController.text = widget.copyPrevious!.streetAddress;
      _cityController.text = widget.copyPrevious!.city;
      _postalCodeController.text = widget.copyPrevious!.postalCode;
    }
  }

  Future<void> _updateDealership() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _postalCodeController.text.isEmpty) {
      _showErrorDialog('All fields must be filled!');
      return;
    }

    final dealership = CarDealershipsEntity(
      id: widget.existing?.id ?? CarDealershipsEntity.ID++,
      carDealershipName: _nameController.text,
      streetAddress: _addressController.text,
      city: _cityController.text,
      postalCode: _postalCodeController.text,
    );

    if (widget.existing != null) {
      await widget.database.carDealershipsDAO.doUpdate(dealership);
    } else {
      await widget.database.carDealershipsDAO.doInsert(dealership);
    }

    widget.onSubmit();
    Navigator.pop(context);
  }

  Future<void> _deleteDealership() async {
    if (widget.existing != null) {
      await widget.database.carDealershipsDAO.doDelete(widget.existing!);
      widget.onSubmit();
      Navigator.pop(context);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add Dealership' : 'Edit Dealership'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            const SizedBox(height: 20),
            if (widget.existing != null) ...[
              ElevatedButton(
                onPressed: _updateDealership,
                child: const Text('Update'),
              ),
              ElevatedButton(
                onPressed: _deleteDealership,
                child: const Text('Delete'),
              ),
            ] else
              ElevatedButton(
                onPressed: _updateDealership,
                child: const Text('Add'),
              ),
          ],
        ),
      ),
    );
  }
}
