import 'package:grocery_app/data/categoris.dart';
import 'package:grocery_app/models/categorry.dart';
import 'package:grocery_app/models/grocery_item.dart';

final groceryItems = [
    GroceryItem(
        id : 'a',
        name : 'milk',
        quantity : 1,
        category : categories[Categories.dairy]!
    ),

    GroceryItem(
        id : 'b',
        name : 'Bananas',
        quantity : 5,
        category : categories[Categories.fruit]!
    ),

    GroceryItem(
        id : 'c',
        name : 'Beef Steak',
        quantity : 1,
        category : categories[Categories.meat]!
    )

];