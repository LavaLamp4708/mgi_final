import 'package:flutter/material.dart';
import 'package:mgi_final/database/entities/customers_entity.dart';
// bob paul
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

    // Pre-fill fields if editing an existing customer
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
      // Create or update customer
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
