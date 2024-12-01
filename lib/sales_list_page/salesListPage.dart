import 'package:flutter/material.dart';
import 'package:mgi_final/database/DAOs/sales_dao.dart';
import 'package:mgi_final/database/entities/sales_entity.dart';
import 'package:mgi_final/database/database.dart';

/// Main entry point of the application. Starts the app.
void main() {
  runApp(const MaterialApp());
}

/// SalesListPage is a StatefulWidget that displays a list of sales records
/// and allows the user to interact with them, such as adding, updating, and deleting records.
class SalesListPage extends StatefulWidget {
  /// The title for the SalesListPage.
  final String title;

  const SalesListPage({Key? key, required this.title}) : super(key: key);

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

/// State for SalesListPage. Handles fetching sales records, updating state,
/// and managing the layout for both mobile and tablet views.
class _SalesListPageState extends State<SalesListPage> {
  var sale_records = <SalesEntity>[];
  TextEditingController _input = TextEditingController();
  late SalesDAO my_salesDAO;
  SalesEntity? selected_sale_record = null;

  /// Initializes the page, sets up the database, and fetches sales records from the database.
  @override
  void initState() {
    super.initState();

    // Initializes the database and fetches all sales records.
    $FloorMGIFinalDatabase.databaseBuilder('app_database.db').build().then((database) {
      my_salesDAO = database.salesDAO;
      my_salesDAO.getAll().then((listOfItems) {
        setState(() {
          sale_records.clear();
          sale_records.addAll(listOfItems);
        });
      });
    });
  }

  /// Builds the UI for the SalesListPage.
  /// Displays either a mobile or tablet layout based on screen size.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Shows an AlertDialog with instructions on how to use the interface.
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Instructions'),
                    content: const Text(
                      '1. Use the Update button to edit records.\n'
                          '2. Use the Delete button to remove a record.\n'
                          '3. Use the Add button to insert a new record.\n'
                          '4. Tap an item to view its details.',
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
      body: reactiveLayout(),
    );
  }

  /// Returns a responsive layout that adapts to mobile and tablet views.
  /// On tablet, displays a two-panel layout. On mobile, displays either the
  /// sales list or the details page depending on whether a sale is selected.
  Widget reactiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      // Tablet Layout
      return Row(
        children: [
          Expanded(flex: 1, child: ToDoList()),
          Expanded(flex: 2, child: DetailsPage()),
        ],
      );
    } else {
      // Mobile Layout
      if (selected_sale_record == null) {
        return ToDoList(); // reuse the code from the tablet Left side
      } else {
        return DetailsPage(); // reuse the code from the tablet Right side
      }
    }
  }

  /// Displays a list of sales records with the option to add, update, or delete.
  Widget ToDoList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/addingSalesPage");
          },
          child: Text("Add"),
        ),
        Expanded(
          child: sale_records.isEmpty
              ? Text("There are no sales list in the list")
              : ListView.builder(
              itemCount: sale_records.length,
              itemBuilder: (context, rowNum) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selected_sale_record = sale_records[rowNum]; // Set the selected item
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Sales Record $rowNum:"),
                      Text(sale_records[rowNum].date_of_purchase),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  /// Displays the details of the selected sales record and provides options to update or delete it.
  Widget DetailsPage() {
    if (selected_sale_record != null) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Customer ID: ${selected_sale_record!.customer_id}'),
            Text('Car ID: ${selected_sale_record!.car_id}'),
            Text('Dealership ID: ${selected_sale_record!.dealership_id}'),
            Text('Purchase Date: ${selected_sale_record!.date_of_purchase}'),
            Text('ID: ${selected_sale_record!.id}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final updatedRecord = await showDialog<SalesEntity>(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController customerController = TextEditingController(text: selected_sale_record!.customer_id);
                        TextEditingController carController = TextEditingController(text: selected_sale_record!.car_id);
                        TextEditingController dealershipController = TextEditingController(text: selected_sale_record!.dealership_id);
                        TextEditingController dateController = TextEditingController(text: selected_sale_record!.date_of_purchase);

                        return AlertDialog(
                          title: const Text('Update Record'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: customerController, decoration: const InputDecoration(labelText: 'Customer ID')),
                                TextField(controller: carController, decoration: const InputDecoration(labelText: 'Car ID')),
                                TextField(controller: dealershipController, decoration: const InputDecoration(labelText: 'Dealership ID')),
                                TextField(
                                  controller: dateController,
                                  decoration: const InputDecoration(labelText: 'Purchase Date (YYYY-MM-DD)'),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(SalesEntity(
                                  selected_sale_record!.id,
                                  customerController.text,
                                  carController.text,
                                  dealershipController.text,
                                  dateController.text,
                                ));
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        );
                      },
                    );

                    if (updatedRecord != null) {
                      await my_salesDAO.doUpdate(updatedRecord);
                      final updatedRecords = await my_salesDAO.getAll();
                      setState(() {
                        sale_records = updatedRecords;
                        selected_sale_record = updatedRecord;
                      });
                    }
                  },
                  child: const Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Remove item'),
                        content: Text('Do you want to remove this item?'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                my_salesDAO.doDelete(selected_sale_record!);
                                sale_records.remove(selected_sale_record);
                                selected_sale_record = null;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Yes'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Expanded(child: Text(""));
    }
  }
}
