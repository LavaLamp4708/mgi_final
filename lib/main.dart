import 'package:flutter/material.dart';

import 'package:mgi_final/HomePage.dart';
import 'car_dealership_list_page/car_dealership_list_page.dart';
import 'customer-list-page/customer_list_page.dart';
import 'sales_list_page/salesListPage.dart';
import 'sales_list_page/addingSalesPage.dart';
import 'customer-list-page/customer_list_page.dart';
import 'car-list-page/car_list_page.dart';

import 'car-list-page/car_list_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CST2334 Final Group Project',
      home: const HomePage(title: 'Home Page'),
      routes: {
        // These will be the pages that the user navigates to from the homepage
        //
        // Uncomment your page when you're Done with it

        '/customerListPage': (context) =>       const CustomerListPage(title: 'Customers List'),
        '/carListPage': (context) =>            const CarListPage(title: 'Cars List'),
        '/carDealershipListPage': (context) =>  const CarDealershipListPage(title: 'Car List'),
        '/carListPage': (context) =>            const CarListPage(title: 'Cars List'),
        '/carDealershipListPage': (context) => const CarDealershipListPage(title: 'Car Dealerships List'),
        '/salesListPage': (context) =>          const SalesListPage(title: 'Sales List'),
        '/addingSalesPage': (context) => AddingSalesPage(),
        '/customerListPage': (context) => const CustomerListPage(title: 'Customers',)
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true
      ),
    );
  }
}


