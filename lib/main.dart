import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/widget/grocery_list.dart';
import 'package:firebase_core/firebase_core.dart';


void main(){

  // WidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp();

  runApp(
    DevicePreview(
      enabled: true, // Set to false in production
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Groceries',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 147, 229, 250),
          brightness: Brightness.dark,
          surface: Color.fromARGB(255, 42, 51, 59),
          ),
          scaffoldBackgroundColor: Color.fromARGB(255, 50, 58, 60)
      ),
     
      home:  GroceryList(),
    );
  }
}
