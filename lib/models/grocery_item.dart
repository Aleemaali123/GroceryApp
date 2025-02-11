

import 'package:grocery_app/models/category.dart';

class GroceryItem{
  final String id;
  final String name;
  final int quantity;
  final CategoryModel category;

  GroceryItem({
   required this.id,
   required this.name,
   required this.quantity,
   required this.category
  }
    );

}