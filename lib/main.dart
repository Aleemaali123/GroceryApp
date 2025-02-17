import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/widget/grocery_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grocery_app/config/theme.dart';
import 'package:grocery_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Grocery App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const GroceryList(),
        );
      },
    );
  }
}
