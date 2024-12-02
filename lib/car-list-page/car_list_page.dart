import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:mgi_final/database/database.dart';
import 'package:mgi_final/database/entities/cars_entity.dart';

import '../database/DAOs/cars_dao.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({super.key, required this.title});
  final String title;

  @override
  State<CarListPage> createState() => _CarsListPageState();
}

class _CarsListPageState extends State<CarListPage> {
  List<CarsEntity> _carsList = [];
  late final CarsDAO carsDAO;
  bool _showCarsForm = false;
  int _selectedCar = -1;
  bool _preferencesAreLoaded = false;

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _numberOfPassengersController;
  late TextEditingController _gasTankOrBatterySizeController;

  late FocusNode _brandFocus;
  late FocusNode _modelFocus;
  late FocusNode _numberOfPassengersFocus;
  late FocusNode _gasTankOrBatterySizeFocus;

  Future<void> _initializeDB() async {
    $FloorMGIFinalDatabase
      .databaseBuilder('mgi_final_database.db')
      .build()
      .then((database){
        carsDAO = database.carsDAO;
        carsDAO.getAll().then((listOfItems){
          setState(() {
            _carsList.clear();
            _carsList.addAll(listOfItems);
          });
        });
      });
  }

  @override
  void initState(){
    super.initState();

    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _numberOfPassengersController = TextEditingController();
    _gasTankOrBatterySizeController = TextEditingController();

    _brandFocus = FocusNode();
    _modelFocus = FocusNode();
    _numberOfPassengersFocus = FocusNode();
    _gasTankOrBatterySizeFocus = FocusNode();

    _initializeDB();
  }

  @override
  void dispose(){

    _brandFocus.dispose();
    _modelFocus.dispose();
    _numberOfPassengersFocus.dispose();
    _gasTankOrBatterySizeFocus.dispose();

    _brandController.dispose();
    _modelController.dispose();
    _numberOfPassengersController.dispose();
    _gasTankOrBatterySizeController.dispose();

    super.dispose();
  }
  
  Future<void> _savePreferences() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    await prefs.setString('brand', _brandController.text);
    await prefs.setString('model', _modelController.text);
    await prefs.setString('numberOfPassengers', _numberOfPassengersController.text);
    await prefs.setString('gasTankOrBatterySize', _gasTankOrBatterySizeController.text);
  }

  Future<void> _loadPreferences() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();

    String? savedBrand = await prefs.getString('brand');
    String? savedModel = await prefs.getString('model');
    String? savedNumberOfPassengers = await prefs.getString('numberOfPassengers');
    String? savedGasTankOrBatterySize = await prefs.getString('gasTankOrBatterySize');

    setState(() {
      _brandController.text = savedBrand;
      _modelController.text = savedModel;
      _numberOfPassengersController.text = savedNumberOfPassengers;
      _gasTankOrBatterySizeController.text = savedGasTankOrBatterySize;
      _preferencesAreLoaded = true;
    });
  }

  Future<void> _removePreferences() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    await prefs.remove('brand');
    await prefs.remove('model');
    await prefs.remove('numberOfPassengers');
    await prefs.remove('gasTankOrBatterySize');
  }

  Future<void> _addToList() async {
    bool fieldsAreValid =
      _brandController.value.text.isNotEmpty &&
      _modelController.value.text.isNotEmpty &&
      _numberOfPassengersController.value.text.isNotEmpty &&
      _gasTankOrBatterySizeController.value.text.isNotEmpty;
    
    if(fieldsAreValid){
      
      int? numberOfPassengers = int.tryParse(_numberOfPassengersController.value.text); 
      double? gasTankOrBatterySize = double.tryParse(_gasTankOrBatterySizeController.value.text);
      
      if (numberOfPassengers != null && gasTankOrBatterySize != null) {
        
        var newCar = CarsEntity(
          CarsEntity.ID++,
          _brandController.value.text,
          _modelController.value.text,
          numberOfPassengers,
          gasTankOrBatterySize
        );
        
        setState((){
          carsDAO.doInsert(newCar);
          _carsList.add(newCar);
          _selectedCar = -1;
          _showCarsForm = false;
        });
        await _savePreferences();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("One are more fields contain invalid data. Please correct all fields.")
          )
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("One or more fields are empty. Please fill all fields.")
        )
      );
    }
  }
  
  Future<void> _updateList() async {
    bool fieldsAreValid =
      _brandController.value.text.isNotEmpty &&
      _modelController.value.text.isNotEmpty &&
      _numberOfPassengersController.value.text.isNotEmpty &&
      _gasTankOrBatterySizeController.value.text.isNotEmpty;

    if(fieldsAreValid){
      int? numberOfPassengers = int.tryParse(_numberOfPassengersController.value.text); 
      double? gasTankOrBatterySize = double.tryParse(_gasTankOrBatterySizeController.value.text);
      
      if (numberOfPassengers != null && gasTankOrBatterySize != null) {
        final car = _carsList[_selectedCar];
        final updatedCar = CarsEntity(
          car.id,
          _brandController.value.text,
          _modelController.value.text,
          numberOfPassengers,
          gasTankOrBatterySize
        );
        await carsDAO.doUpdate(updatedCar);
        setState(() {
          _carsList[_selectedCar] = updatedCar;
          _savePreferences();
          _showCarsForm = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("One are more fields contain invalid data. Please correct all fields.")
          )
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("One or more fields are empty. Please fill all fields.")
        )
      );
    }
  }

  Future<void> _deleteFromList() async {
    final car = _carsList[_selectedCar];
    await carsDAO.doDelete(car);
    setState(() {
      _carsList.removeAt(_selectedCar);
      _selectedCar = -1;
      _brandController.clear();
      _modelController.clear();
      _numberOfPassengersController.clear();
      _gasTankOrBatterySizeController.clear();
      _preferencesAreLoaded = false;
      _showCarsForm = false;
    });
  }

  void _showDeleteDialog(BuildContext context){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: (){
                _deleteFromList();
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))
            ),
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Cancel")
            )
          ]
        );
      }
    );
  }

  Widget _displayCarsForm(){
    if (!_preferencesAreLoaded) {
      Future.microtask(() => _loadPreferences());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _selectedCar < 0 ? SizedBox.shrink() : Text("Car #${_selectedCar + 1}"),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: TextField(
            focusNode: _brandFocus,
            controller: _brandController,
            decoration: const InputDecoration(
              hintText: "Brand",
              labelText: "Brand",
              border: OutlineInputBorder()
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_modelFocus);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: TextField(
            focusNode: _modelFocus,
            controller: _modelController,
            decoration: const InputDecoration(
              hintText: "Model",
              labelText: "Model",
              border: OutlineInputBorder()
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_numberOfPassengersFocus);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: TextField(
            focusNode: _numberOfPassengersFocus,
            controller: _numberOfPassengersController,
            decoration: const InputDecoration(
              hintText: "Number of Passengers",
              labelText: "Number of Passengers",
              border: OutlineInputBorder()
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_gasTankOrBatterySizeFocus);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: TextField(
            focusNode: _gasTankOrBatterySizeFocus,
            controller: _gasTankOrBatterySizeController,
            decoration: const InputDecoration(
              hintText: "Gas Tank size in L / Battery capacity in kWh",
              labelText: "Gas Tank size in L / Battery capacity in kWh",
              border: OutlineInputBorder()
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          _selectedCar < 0 ?
          ElevatedButton(
            onPressed: _addToList, 
            child: const Text("Submit")
          )
          :
          ElevatedButton(
            onPressed: _updateList, 
            child: const Text("Update")
          ),
          _selectedCar < 0 ?
          const SizedBox.shrink()
          :
          ElevatedButton(
            onPressed: (){_showDeleteDialog(context);}, 
            child: const Text("Delete")
          )
        ],)
      ],
    );
  }

  Widget _displayList(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50,),
        ElevatedButton(onPressed: (){setState(() {_showCarsForm = true;});}, child: const Text("Add New Car")),
        Expanded(
          child: ListView.builder(
            itemCount: _carsList.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(
                onTap:() {
                  setState((){
                    _selectedCar = rowNum;

                    _brandController.text = _carsList[rowNum].brand;
                    _modelController.text = _carsList[rowNum].model;
                    _numberOfPassengersController.text = _carsList[rowNum].numberOfPassengers.toString();
                    _gasTankOrBatterySizeController.text = _carsList[rowNum].gasTankOrBatterySize.toString();

                    _showCarsForm = true;
                  });
                  FocusScope.of(context).requestFocus(_brandFocus);
                },
                child: Row(
                  children: [
                    const SizedBox(width: 15),
                    Text("Item ${rowNum + 1}."),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text("${_carsList[rowNum].brand} ${_carsList[rowNum].model}")
                    )
                  ],
                )
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _showCarsForm ? _displayCarsForm() : _displayList()
    );
  }
}