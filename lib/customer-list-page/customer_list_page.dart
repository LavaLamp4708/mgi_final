import 'package:flutter/material.dart';
import 'package:mgi_final/database/entities/customers_entity.dart';
import 'package:mgi_final/database/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Required for encrypted shared preferences

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key, required this.title});
  final String title;

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late MGIFinalDatabase database;
  List<CustomersEntity> customers = [];

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    database = await $FloorMGIFinalDatabase.databaseBuilder('mgi_final.db').build();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customerList = await database.customersDAO.getAll();
    setState(() {
      customers = customerList;
    });
  }

  Future<void> _saveLastCustomer(CustomersEntity customer) async {
    await storage.write(key: 'lastFirstName', value: customer.firstName);
    await storage.write(key: 'lastLastName', value: customer.lastName);
    await storage.write(key: 'lastAddress', value: customer.address);
    await storage.write(key: 'lastBirthDate', value: customer.birthDate);
  }

  Future<CustomersEntity?> _getLastCustomer() async {
    final firstName = await storage.read(key: 'lastFirstName');
    final lastName = await storage.read(key: 'lastLastName');
    final address = await storage.read(key: 'lastAddress');
    final birthDate = await storage.read(key: 'lastBirthDate');

    if (firstName != null && lastName != null && address != null && birthDate != null) {
      return CustomersEntity(CustomersEntity.ID++, firstName, lastName, address, birthDate);
    }
    return null;
  }

  void _addCustomer() async {
    CustomersEntity? lastCustomer = await _getLastCustomer();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormPage(
          onSave: (customer) {
            _saveLastCustomer(customer);
            database.customersDAO.doInsert(customer);
            _loadCustomers();
          },
          initialCustomer: lastCustomer,
        ),
      ),
    );
  }

  void _editCustomer(CustomersEntity customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormPage(
          onSave: (updatedCustomer) {
            database.customersDAO.doUpdate(updatedCustomer);
            _loadCustomers();
          },
          initialCustomer: customer,
        ),
      ),
    );
  }

  void _deleteCustomer(CustomersEntity customer) async {
    await database.customersDAO.doDelete(customer);
    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return ListTile(
            title: Text('${customer.firstName} ${customer.lastName}'),
            subtitle: Text('Address: ${customer.address}'),
            onTap: () => _editCustomer(customer),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCustomer(customer),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CustomerFormPage extends StatefulWidget {
  final Function(CustomersEntity) onSave;
  final CustomersEntity? initialCustomer;

  const CustomerFormPage({
    Key? key,
    required this.onSave,
    this.initialCustomer,
  }) : super(key: key);

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialCustomer != null) {
      _firstNameController.text = widget.initialCustomer!.firstName;
      _lastNameController.text = widget.initialCustomer!.lastName;
      _addressController.text = widget.initialCustomer!.address;
      _birthDateController.text = widget.initialCustomer!.birthDate;
    }
  }

  bool _validateFields() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _birthDateController.text.isNotEmpty;
  }

  void _submitForm() {
    if (_validateFields()) {
      final customer = CustomersEntity(
        widget.initialCustomer?.id ?? CustomersEntity.ID++,
        _firstNameController.text,
        _lastNameController.text,
        _addressController.text,
        _birthDateController.text,
      );
      widget.onSave(customer);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _birthDateController,
              decoration: const InputDecoration(labelText: 'Birth Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
