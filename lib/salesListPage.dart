import 'package:flutter/material.dart';
import 'package:mgi_final/database/DAOs/sales_dao.dart';
import 'package:mgi_final/database/entities/sales_entity.dart';
import 'package:mgi_final/database/database.dart';
import 'addingSalesPage.dart';

void main() {
  runApp(const MaterialApp());
}

class SalesListPage extends StatefulWidget {
  final String title;

  const SalesListPage({Key? key, required this.title}) : super(key: key);

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  var sale_records = <SalesEntity>[];
  TextEditingController _input = TextEditingController();
  late SalesDAO my_salesDAO;
  SalesEntity? selected_sale_record = null;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: reactiveLayout(),
    );
  }

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

  Widget ToDoList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/addingSalesPage");
              },
              child: Text("Add"),
            ),
          ],
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
                      Text("Item $rowNum:"),
                      Text(sale_records[rowNum].date_of_purchase),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget DetailsPage() {
    if (selected_sale_record != null) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(selected_sale_record!.car_id),
            Text(selected_sale_record!.dealership_id),
            Text(selected_sale_record!.date_of_purchase),
            Text('${selected_sale_record!.id}'),
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
            )
          ],
        ),
      );
    } else {
      return Expanded(child: Text(""));
    }
  }
}
