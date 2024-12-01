import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../database/entities/sales_entity.dart';
import '../database/DAOs/sales_dao.dart';
import '../database/database.dart';

/// The [AddingSalesPage] widget is responsible for displaying a form
/// that allows the user to enter new sales records and submit them to the database.
///
/// This page includes:
/// - Input fields for Customer ID, Car ID, Dealership ID, and Purchase Date.
/// - A submit button to insert the sales record into the database.
/// - A Snackbar that shows the last saved record for quick access.
/// - A function to load saved data (if any) when the page is accessed.
class AddingSalesPage extends StatefulWidget {
  @override
  State<AddingSalesPage> createState() => AddingSalesPageState();
}

/// The [AddingSalesPageState] manages the state for [AddingSalesPage], including:
/// - Handling the input fields and their controllers.
/// - Loading and saving data using [EncryptedSharedPreferences].
/// - Inserting new sales records into the database.
/// - Managing the display of a SnackBar for reloading the last saved record.
class AddingSalesPageState extends State<AddingSalesPage> {
  var _controllerCustomerID = TextEditingController();
  var _controllerCarID = TextEditingController();
  var _controllerDealershipID = TextEditingController();
  var _controllerPurchaseDate = TextEditingController();

  late SalesDAO my_salesDAO;

  final EncryptedSharedPreferences encryptedSharedPreferences = EncryptedSharedPreferences();

  /// Initializes the state of the page and sets up the database connection.
  /// Also shows a Snackbar with an option to load the last saved record.
  @override
  void initState() {
    super.initState();

    // Show Snackbar with option to load last saved record
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final snackBar = SnackBar(
        content: Text('You can use the last record'),
        action: SnackBarAction(
          label: 'Load last record',
          onPressed: (){
            loadData();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    // Initialize the database connection
    $FloorMGIFinalDatabase.databaseBuilder('app_database.db').build().then((database) {
      my_salesDAO = database.salesDAO;
    });
  }

  /// Loads the saved data (if any) from the [EncryptedSharedPreferences]
  /// and populates the corresponding input fields.
  Future<void> loadData() async {
    String? savedCustomerID = await encryptedSharedPreferences.getString("customerID");
    String? savedCarID = await encryptedSharedPreferences.getString("carID");
    String? savedDealershipID = await encryptedSharedPreferences.getString("dealershipID");
    String? savedPurchaseDate = await encryptedSharedPreferences.getString("purchaseDate");

    // Set values if found in saved preferences
    if (savedCustomerID != null) {
      setState(() {
        _controllerCustomerID.text = savedCustomerID;
      });
    }
    if (savedCarID != null) {
      setState(() {
        _controllerCarID.text = savedCarID;
      });
    }
    if (savedDealershipID != null) {
      setState(() {
        _controllerDealershipID.text = savedDealershipID;
      });
    }
    if (savedPurchaseDate != null) {
      setState(() {
        _controllerPurchaseDate.text = savedPurchaseDate;
      });
    }
  }

  /// Saves the data entered in the input fields to [EncryptedSharedPreferences]
  void saveData() {
    encryptedSharedPreferences.setString('customerID', _controllerCustomerID.value.text);
    encryptedSharedPreferences.setString('carID', _controllerCarID.value.text);
    encryptedSharedPreferences.setString('dealershipID', _controllerDealershipID.value.text);
    encryptedSharedPreferences.setString('purchaseDate', _controllerPurchaseDate.value.text);
  }

  /// Builds the UI for the AddingSalesPage, including the input fields and the submit button.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Adding new sales record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info), // Action Item icon
            onPressed: () {
              // Show AlertDialog with instructions
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Instructions'),
                    content: const Text(
                        '1. Use the Snackbar to reload the last record.\n'
                            '2. Tap submit to insert record to database.\n'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Please Enter New Sales Record', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            // Customer ID input field
            TextField(controller: _controllerCustomerID, decoration: InputDecoration(hintText: "Customer ID", labelText: "Customer ID")),
            // Car ID input field
            TextField(controller: _controllerCarID, decoration: InputDecoration(hintText: "Car ID", labelText: "Car ID")),
            // Dealership ID input field
            TextField(controller: _controllerDealershipID, decoration: InputDecoration(hintText: "Dealership ID", labelText: "Dealership ID")),
            // Purchase Date input field with date picker
            TextField(
              controller: _controllerPurchaseDate,
              decoration: InputDecoration(
                labelText: "Purchase Date",
                filled: true,
                prefixIcon: Icon(Icons.calendar_today),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
              readOnly: true,
              onTap: () {
                _selectDate();
              },
            ),
            // Submit Button
            ElevatedButton(
              onPressed: () async {
                if (_controllerCustomerID.value.text.isNotEmpty &&
                    _controllerCarID.value.text.isNotEmpty &&
                    _controllerDealershipID.value.text.isNotEmpty &&
                    _controllerPurchaseDate.value.text.isNotEmpty) {
                  final allRecords = await my_salesDAO.getAll();
                  final nextID = (allRecords.isNotEmpty
                      ? allRecords.map((record) => record.id).reduce((a, b) => a > b ? a : b)
                      : 0) + 1;
                  setState(() {
                    saveData();
                    var newSalesRecord = SalesEntity(nextID,
                        _controllerCustomerID.value.text,
                        _controllerCarID.value.text,
                        _controllerDealershipID.value.text,
                        _controllerPurchaseDate.value.text);
                    my_salesDAO.doInsert(newSalesRecord);
                    _controllerCustomerID.text = "";
                    _controllerCarID.text = "";
                    _controllerDealershipID.text = "";
                    _controllerPurchaseDate.text = "";
                  });
                  Navigator.pushNamed(context, "/salesListPage");
                } else {
                  var snackBar = SnackBar(content: Text("Input field is required!"));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a date picker for the purchase date.
  Future<void> _selectDate() async {
    DateTime? purchaseDate = await showDatePicker(
        context: context, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (purchaseDate != null) {
      setState(() {
        _controllerPurchaseDate.text = purchaseDate.toString().split(" ")[0];
      });
    }
  }
}

/// Main entry point for the application.
/// Launches the [AddingSalesPage] as the home page.
void main() {
  runApp(MaterialApp(
    home: AddingSalesPage(),
  ));
}
