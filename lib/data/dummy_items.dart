
import 'package:grocery_app/models/grocery_item.dart';

import '../models/category.dart';
import 'categories.dart';

final groceryItems = [
    GroceryItem(
        id : 'a',
        name : 'milk',
        quantity : 1,
        category : categoriesData[Categories.meat]!
    ),

    GroceryItem(
        id : 'b',
        name : 'Bananas',
        quantity : 5,
        category : categoriesData[Categories.fruit]!
    ),

    GroceryItem(
        id : 'c',
        name : 'Beef Steak',
        quantity : 1,
        category : categoriesData[Categories.meat]!
    )

];