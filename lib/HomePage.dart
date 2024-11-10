import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontSize: 36, color: Colors.black),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child:
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child:
                  SizedBox.expand(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/customerListPage');
                      }, 
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder()
                      ),
                      child: const Text("Customers Page", 
                        style: TextStyle(fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ),
                Expanded(child:
                  SizedBox.expand(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/carListPage');
                      },  
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder()
                      ),
                      child: const Text("Cars Page", 
                        style: TextStyle(fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                    )
                  )
                )
              ]
            )
          ),
          Expanded(child:
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child:
                  SizedBox.expand(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/carDealershipListPage');
                      },  
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder()
                      ),
                      child: const Text("Car Dealerships Page", 
                        style: TextStyle(fontSize: 26),
                        textAlign: TextAlign.center,
                      )
                    ),
                  )
                ),
                Expanded(child: 
                  SizedBox.expand(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/salesListPage');
                      },  
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder()
                      ),
                      child: const Text("Sales Page", 
                        style: TextStyle(fontSize: 26),
                        textAlign: TextAlign.center,
                      )
                    ),
                  )
                )
              ],
            )
          )
        ],
      ),
    );
  }
}