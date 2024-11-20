import 'package:flutter/material.dart';
import 'package:lab2/todo_dao.dart';
import 'package:lab2/todo_item.dart';
import 'package:lab2/database.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var items = <TodoItem>[];
  TextEditingController _input = TextEditingController();
  late ToDoDAO myDAO;
  TodoItem? selectedItem  = null;

  @override
  void initState() {
    super.initState();

    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((database) {
      myDAO = database.todoDao;
      myDAO.getAllItems().then((listOfItems){
        setState(() {
          items.clear();
          items.addAll(listOfItems);
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

    if((width > height) && (width > 720)) {
      // Tablet Layout
      return Row(children: [
        Expanded(
            flex: 1,
            child: ToDoList()),
        Expanded(
            flex: 2,
            child: DetailsPage()),
      ],);
    } else {
      // Mobile Layout
      if(selectedItem == null){
        return ToDoList() ;// reuse the code from the tablet Left side,
      }
      else
      {
        return DetailsPage(); //reuse the code from the tablet Right side
      }
    }
  }
  Widget ToDoList() {
    return Column(

      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        Row(children: [
          ElevatedButton(onPressed: (){
            if(_input.value.text.isNotEmpty) {
              setState(() {
                var newItem = TodoItem(TodoItem.ID++, _input.value.text);
                myDAO.insertItem(newItem);
                items.add(newItem);
                _input.text = "";
              });
            } else {
              var snackBar = SnackBar(content: Text("Input field is required!"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }, child: Text("Add"),),

          Flexible(child: TextField(
            controller: _input,
            decoration: InputDecoration(hintText: "Enter a todo item"),)),
        ],),

        Expanded(
          child: items.isEmpty
              ?Text("There are no items in the list")
              :ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, rowNum){
                return GestureDetector(
                  onTap: (){

                    setState(() {
                      selectedItem = items[rowNum]; // Set the selected item
                    });

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Item $rowNum:"),
                      Text(items[rowNum].todoItem)
                    ],
                  ),
                );
              }),
        )

      ],
    );
  }
  Widget DetailsPage() {
    if(selectedItem != null){
      return Expanded(
        child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(selectedItem!.todoItem),
              Text('${selectedItem!.id}'),
              ElevatedButton(
                onPressed: ()  {

                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Remove item'),
                      content: Text('Do you want to remove this item?'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: ()  {
                            setState(() {
                              myDAO.deleteItem(selectedItem!);
                              items.remove(selectedItem);
                              selectedItem = null;
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
            ]),
      );

    }
    else{

      return Expanded(child: Text(""));
    }
  }
}