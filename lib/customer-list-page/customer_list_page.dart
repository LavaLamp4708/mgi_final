// Bob Paul: Customer list view page
import 'package:flutter/material.dart';
import 'package:mgi_final/database/entities/customers_entity.dart';
import 'package:mgi_final/database/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mgi_final/customer-list-page/customer_form_page.dart';

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

  void _confirmDeleteCustomer(CustomersEntity customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteCustomer(customer);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(CustomersEntity customer) async {
    await database.customersDAO.doDelete(customer);
    _loadCustomers();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Text(
            'To add a customer, click the "+" button.\n\n'
                'To edit a customer, tap their name.\n\n'
                'To delete a customer, swipe left or click the trash icon.'),
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
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
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
              onPressed: () => _confirmDeleteCustomer(customer),
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
