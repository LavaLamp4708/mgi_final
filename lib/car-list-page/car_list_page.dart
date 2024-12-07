import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mgi_final/database/database.dart';
import 'package:mgi_final/database/entities/cars_entity.dart';

import '../database/DAOs/cars_dao.dart';

/// A StatefulWidget for managing a list of cars.
/// 
/// This page uses a boolean (`_showCarsForm`) to toggle between two layouts:
/// - A list view of cars.
/// - A form for adding or editing cars.
/// 
/// Author: Peter Stainforth
class CarListPage extends StatefulWidget {
  const CarListPage({super.key, required this.title});
  final String title;

  @override
  State<CarListPage> createState() => _CarsListPageState();
}

/// The state for CarListPage.
///
/// Handles:
/// - Database initialization and CRUD operations.
/// - Form management for adding/editing cars.
/// - Shared preferences for saving and loading car data.
/// - List view management for displaying the cars.
class _CarsListPageState extends State<CarListPage> {
  /// List of cars currently stored in the database.
  List<CarsEntity> _carsList = [];

  /// Data Access Object (DAO) for interacting with the cars database.
  late final CarsDAO carsDAO;

  /// Toggles between the list view and the form view.
  bool _showCarsForm = false;

  /// The currently selected car in the list, identified by index.
  int _selectedCar = -1;

  /// Indicates whether shared preferences are loaded.
  bool _preferencesAreLoaded = false;

  /// Text controllers for form input fields.
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _numberOfPassengersController;
  late TextEditingController _gasTankOrBatterySizeController;

  /// Focus nodes for managing keyboard focus in the form.
  late FocusNode _brandFocus;
  late FocusNode _modelFocus;
  late FocusNode _numberOfPassengersFocus;
  late FocusNode _gasTankOrBatterySizeFocus;

  /// Initializes the database and loads car data.
  ///
  /// This method:
  /// - Builds the database using Floor.
  /// - Fetches the list of cars from the database.
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

  /// Initializes controllers, focus nodes, and the database.
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

  /// Disposes controllers and focus nodes to prevent memory leaks.
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
  
  /// Saves the form data to encrypted shared preferences.
  ///
  /// Fields saved:
  /// - Brand
  /// - Model
  /// - Number of passengers
  /// - Gas tank or battery size
  Future<void> _savePreferences() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    await prefs.setString('brand', _brandController.text);
    await prefs.setString('model', _modelController.text);
    await prefs.setString('numberOfPassengers', _numberOfPassengersController.text);
    await prefs.setString('gasTankOrBatterySize', _gasTankOrBatterySizeController.text);
  }

  /// Loads the form data from encrypted shared preferences.
  ///
  /// Updates the form controllers with the loaded values.
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

  /// Removes form data from encrypted shared preferences.
  Future<void> _removePreferences() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    await prefs.remove('brand');
    await prefs.remove('model');
    await prefs.remove('numberOfPassengers');
    await prefs.remove('gasTankOrBatterySize');
  }

  /// Adds a new car to the list and database.
  ///
  /// Validates the input fields and creates a new `CarsEntity`.
  /// Updates the list and saves preferences upon success.
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
  
  /// Updates an existing car in the list and database.
  ///
  /// Validates the input fields and updates the selected `CarsEntity`.
  /// Updates the list upon success.
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

  /// Deletes a car from the list and database.
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

  /// Displays a confirmation dialog for deleting a car from the list.
  ///
  /// This method shows an `AlertDialog` with the following:
  /// - **Title**: A prompt to confirm the deletion.
  /// - **Content**: A message asking the user to confirm their choice.
  /// - **Actions**:
  ///   - **Delete**: Deletes the selected car from the list and closes the dialog.
  ///   - **Cancel**: Closes the dialog without making changes.
  ///
  /// [context]: The build context used to show the dialog.
  void _showDeleteDialog(BuildContext context){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion", textAlign: TextAlign.center, style: GoogleFonts.varelaRound(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to delete this item?", style: GoogleFonts.varelaRound(fontSize: 15)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: (){
                _deleteFromList();
                Navigator.of(context).pop();
              },
              child: Text("Delete", style: GoogleFonts.varelaRound(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold))
            ),
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: GoogleFonts.varelaRound(fontSize: 15, fontWeight: FontWeight.bold))
            )
          ]
        );
      }
    );
  }

  /// Displays a form for adding or editing car details.
  ///
  /// This method dynamically adjusts its UI based on the value of `_selectedCar`:
  /// - If `_selectedCar` is negative, it displays the form for adding a new car.
  /// - If `_selectedCar` is a valid index, it pre-fills the form with data for editing.
  ///
  /// The form includes:
  /// - Input fields for:
  ///   - **Brand**
  ///   - **Model**
  ///   - **Number of Passengers**
  ///   - **Gas Tank size (L) or Battery capacity (kWh)**.
  /// - Buttons for actions:
  ///   - **Submit**: Adds a new car.
  ///   - **Update**: Updates an existing car.
  ///   - **Cancel**: Cancels the form.
  ///   - **Delete**: Deletes the selected car (only visible in edit mode).
  ///
  /// **Note**: If shared preferences are not loaded, this method triggers
  /// `_loadPreferences()` to load saved data.
  ///
  /// Returns a `Column` widget containing the form UI.
  Widget _displayCarsForm(){
    if (!_preferencesAreLoaded) {
      Future.microtask(() => _loadPreferences());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _selectedCar < 0 ? 
        Text("Add Car", style: GoogleFonts.varelaRound(fontSize: 40)) 
        : 
        Text("Car #${_selectedCar + 1}", style: GoogleFonts.varelaRound(fontSize: 40)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: TextField(
            style: GoogleFonts.varelaRound(),
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
            style: GoogleFonts.varelaRound(),
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
            style: GoogleFonts.varelaRound(),
            keyboardType: TextInputType.number,
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
            style: GoogleFonts.varelaRound(),
            keyboardType: TextInputType.number,
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton(
              onPressed: _addToList, 
              child: Text("Submit", style: GoogleFonts.varelaRound(fontSize: 20))
            ),
          )
          :
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton(
              onPressed: _updateList, 
              child: Text("Update", style: GoogleFonts.varelaRound(fontSize: 20))
            ),
          ),
          _selectedCar < 0 ?
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton(
              onPressed: () { setState(() {
                _selectedCar = -1;
                _showCarsForm = false;
              });}, 
              child: Text("Cancel", style: GoogleFonts.varelaRound(fontSize: 20))),
          )
          :
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: ElevatedButton(
              onPressed: (){_showDeleteDialog(context);}, 
              child: Text("Delete", style: GoogleFonts.varelaRound(fontSize: 20))
            ),
          )
        ],)
      ],
    );
  }

  /// Displays the list of cars stored in the database.
  ///
  /// Each list item shows:
  /// - The car's brand and model.
  /// - The item number in the list.
  ///
  /// Features:
  /// - **Tap on an item**: Opens the form pre-filled with the car's details for editing.
  /// - **"Add New Car" button**: Opens the form for adding a new car.
  ///
  /// Returns a `Column` widget containing the list UI.
  Widget _displayList(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50,),
        ElevatedButton(onPressed: (){setState(() {_showCarsForm = true; _selectedCar = -1;});}, child: Text("Add New Car", style: GoogleFonts.varelaRound(fontSize: 40))),
        const SizedBox(height: 25,),
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
                    Text("Item ${rowNum + 1}.", style: GoogleFonts.varelaRound(fontSize: 20),),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text("${_carsList[rowNum].brand} ${_carsList[rowNum].model}", style: GoogleFonts.varelaRound(fontSize: 20))
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

  /// Builds the UI for the page.
  ///
  /// Displays either the car list or the form based on `_showCarsForm`.
  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.varelaRound(),),
        actions: [
          // Action button to display help menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Add/Edit':
                  _showHelpDialog(
                    context,
                    title: 'Add/Edit Form',
                    message:
                        'The Add/Edit form allows you to enter details about a car, '
                        'including brand, model, number of passengers, and fuel/battery size. '
                        'You can submit new entries or update existing ones.',
                  );
                  break;
                case 'List':
                  _showHelpDialog(
                    context,
                    title: 'Car List',
                    message:
                        'The Car List displays all cars saved in the database. '
                        'Tap an item to edit it, or use the "Add New Car" button to create a new entry.',
                  );
                  break;
                case 'Preferences':
                  _showHelpDialog(
                    context,
                    title: 'Shared Preferences',
                    message:
                        'Shared preferences save the form data securely so you can resume later. '
                        'Data will reload automatically when you revisit the form.',
                  );
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'Add/Edit',
                  child: Text('How to use Add/Edit Form'),
                ),
                const PopupMenuItem(
                  value: 'List',
                  child: Text('How to use the Car List'),
                ),
                const PopupMenuItem(
                  value: 'Preferences',
                  child: Text('How Shared Preferences Work'),
                ),
              ];
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: _showCarsForm ? _displayCarsForm() : _displayList()
    );
  }

  /// Displays a help dialog with instructions on how to use a specific feature.
  ///
  /// [context]: The build context used to show the dialog.
  /// [title]: The title of the dialog.
  /// [message]: The instructional message to display inside the dialog.
  void _showHelpDialog(BuildContext context, {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}