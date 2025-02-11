import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:grocery_app/models/categorry.dart';



var categories = {

  Categories.vegitables: Category(
    'Vegitables',
    Color.fromARGB(255,0,255,128),
  ),

   Categories.fruit: Category(
    'Fruit',
    Color.fromARGB(255,145,255,0),
  ),

  Categories.meat: Category(
    'Meat',
    Color.fromARGB(255,255,102,0),
  ),

  Categories.dairy: Category(
    'Dairy',
    Color.fromARGB(255,0,208,255),
  ),

  Categories.carbs: Category(
    'Carbs',
    Color.fromARGB(255,0,60,255),
  ),
}