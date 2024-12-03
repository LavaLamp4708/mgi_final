import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../database/entities/sales_entity.dart';
import '../database/DAOs/sales_dao.dart';
import '../database/database.dart';

class AddingSalesPage extends StatefulWidget {
  @override
  State<AddingSalesPage> createState() => AddingSalesPageState();
}


class AddingSalesPageState extends State<AddingSalesPage> {
  var _controllerCustomerID = TextEditingController();
  var _controllerCarID = TextEditingController();
  var _controllerDealershipID = TextEditingController();
  var _controllerPurchaseDate = TextEditingController();
  late SalesDAO my_salesDAO;
  final EncryptedSharedPreferences encryptedSharedPreferences = EncryptedSharedPreferences();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final snackBar = SnackBar(
        content: Text('You can use the last record'),
          action:SnackBarAction( label:'Load last record', onPressed: (){
            loadData();
          })
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
    $FloorMGIFinalDatabase.databaseBuilder('app_database.db').build().then((database) {
      my_salesDAO = database.salesDAO;
    });

  }

  Future<void> loadData() async{
    String? savedCustomerID = await encryptedSharedPreferences.getString("customerID");
    String? savedCarID = await encryptedSharedPreferences.getString("carID");
    String? savedDealershipID = await encryptedSharedPreferences.getString("dealershipID");
    String? savedPurchaseDate = await encryptedSharedPreferences.getString("purchaseDate");
    if (savedCustomerID != null ) {
      setState(() {
        _controllerCustomerID.text = savedCustomerID;
      });
    }
    if (savedCarID != null ) {
      setState(() {
        _controllerCarID.text = savedCarID;
      });
    }
    if (savedDealershipID != null ) {
      setState(() {
        _controllerDealershipID.text = savedDealershipID;
      });
    }
    if (savedPurchaseDate != null ) {
      setState(() {
        _controllerPurchaseDate.text = savedPurchaseDate;
      });
    }
  }

  saveData(){
    encryptedSharedPreferences.setString('customerID', _controllerCustomerID.value.text);
    encryptedSharedPreferences.setString('carID', _controllerCarID.value.text);
    encryptedSharedPreferences.setString('dealershipID', _controllerDealershipID.value.text);
    encryptedSharedPreferences.setString('purchaseDate', _controllerPurchaseDate.value.text);
  }

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
            Text('Please Enter New Sales Record',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,),),
            TextField(controller:_controllerCustomerID,decoration: InputDecoration(hintText: "Customer ID",labelText: "Customer ID"),),
            TextField(controller:_controllerCarID,decoration: InputDecoration(hintText: "Car ID",labelText: "Car ID",),),
            TextField(controller:_controllerDealershipID,decoration: InputDecoration(hintText: "Dealership ID",labelText: "Dealership ID",),),
            TextField(
              controller:_controllerPurchaseDate,
              decoration: InputDecoration(
                  labelText: "Purchase Date",
                filled:true,
                  prefixIcon: Icon(Icons.calendar_today),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none
            ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue)
                )
              ),
            readOnly: true,
            onTap: (){
              _selectDate();
            },),
            ElevatedButton(
              onPressed: () async {
                if(_controllerCustomerID.value.text.isNotEmpty
                &_controllerCarID.value.text.isNotEmpty
                &_controllerDealershipID.value.text.isNotEmpty
                &_controllerPurchaseDate.value.text.isNotEmpty) {
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
                      _controllerPurchaseDate.value.text,);
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
  Future<void> _selectDate() async{
    DateTime? purchaseDate = await showDatePicker
      (
        context: context, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (purchaseDate != null){
      setState(() {
        _controllerPurchaseDate.text = purchaseDate.toString().split(" ")[0];
      });
    }

  }

}


void main() {
  runApp(MaterialApp(
    home: AddingSalesPage(),
  ));
}

