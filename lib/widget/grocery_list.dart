import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/data/dummy_items.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/widget/new_item.dart';
import 'package:grocery_app/widget/product_detail.dart';
import 'package:http/http.dart' as http;
import 'package:grocery_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';


class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryList();
}


class _GroceryList extends State<GroceryList> {
 
List<GroceryItem> groceryItem = [];

void initState(){
  super.initState();
  loadItems();
}


void loadItems() async {
  final url = Uri.parse(
    'https://groceryapp-cf2a5-default-rtdb.firebaseio.com/shopping-List.json'
  );
     
  try {
    final response = await http.get(url);
    
    if (response.statusCode >= 400) {
      setState(() {
        groceryItem = [];
      });
      return;
    }

    if (response.body == 'null' || response.body.isEmpty) {
      setState(() {
        groceryItem = [];
      });
      return;
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    listData.forEach((key, value) {
      final category = categoriesData.entries
          .firstWhere((categoryItem) => 
              categoryItem.value.title == value['category'])
          .value;
      
      loadedItems.add(
        GroceryItem(
          id: key,
          name: value['name'],
          quantity: value['quantity'],
          category: category,
        ),
      );
    });

    setState(() {
      groceryItem = loadedItems;
    });
  } catch (error) {
    setState(() {
      groceryItem = [];
    });
  }
}


// void addItem(BuildContext context)async{
//     await Navigator.of(context).push<GroceryItem>(
//     MaterialPageRoute(
//       builder: (ctx)=> NewItem(),
//     ));
// }


  void addItem(BuildContext context) async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem != null) {
      final existingItemIndex = groceryItem.indexWhere((item) => item.name == newItem.name);

      if (existingItemIndex != -1) {
        // Item already exists, add new quantity to existing quantity
        final updatedQuantity = groceryItem[existingItemIndex].quantity + newItem.quantity;
        
        // Update the quantity on Firebase first
        final existingItemId = groceryItem[existingItemIndex].id;
        final url = Uri.https(
          'groceryapp-cf2a5-default-rtdb.firebaseio.com',
          '/shopping-List/$existingItemId.json',
        );

        try {
          final response = await http.patch(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'quantity': updatedQuantity,
            })
          );

          if (response.statusCode >= 400) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update quantity.'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          // Only update state if Firebase update was successful
          setState(() {
            groceryItem[existingItemIndex] = GroceryItem(
              id: groceryItem[existingItemIndex].id,
              name: groceryItem[existingItemIndex].name,
              quantity: updatedQuantity,
              category: groceryItem[existingItemIndex].category,
            );
          });
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update quantity.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add new item to Firebase
        final url = Uri.https(
          'groceryapp-cf2a5-default-rtdb.firebaseio.com',
          '/shopping-List.json',
        );

        try {
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': newItem.name,
              'quantity': newItem.quantity,
              'category': newItem.category.title
            })
          );

          if (response.statusCode >= 400) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to add item.'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          final Map<String, dynamic> responseData = json.decode(response.body);
          
          // Only update state if Firebase add was successful
          setState(() {
            groceryItem.add(
              GroceryItem(
                id: responseData['name'],
                name: newItem.name,
                quantity: newItem.quantity,
                category: newItem.category,
              ),
            );
          });
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add item.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }


  void _removeItem(GroceryItem item){
        setState(() {
          groceryItem.remove(item);
        });
      }


  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No items in your list",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );

    if (groceryItem.isNotEmpty) {
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: groceryItem.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Dismissible(
              key: ValueKey(groceryItem[index].id),
              background: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Item'),
                    content: Text(
                      'Are you sure you want to remove ${groceryItem[index].name} from the list?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        child: Text(
                          'No',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) async {
                final url = Uri.https(
                  'groceryapp-cf2a5-default-rtdb.firebaseio.com',
                  '/shopping-List/${groceryItem[index].id}.json',
                );

                final deletedItem = groceryItem[index];
                
                setState(() {
                  groceryItem.removeAt(index);
                });

                try {
                  final response = await http.delete(url);
                  
                  if (response.statusCode >= 400) {
                    // If deletion fails, reinsert the item
                    setState(() {
                      groceryItem.insert(index, deletedItem);
                    });
                    
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete item.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${deletedItem.name} removed from the list.',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (error) {
                  // If there's an error, reinsert the item
                  setState(() {
                    groceryItem.insert(index, deletedItem);
                  });
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete item.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Card(
                child: ListTile(
                  onTap: () async {
                    final result = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (ctx) => ProductDetail(item: groceryItem[index]),
                      ),
                    );
                    
                    if (result == 'refresh') {
                      loadItems();
                    }
                  },
                  title: Text(
                    groceryItem[index].name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: groceryItem[index].category.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      groceryItem[index].quantity.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(milliseconds: 300),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
                Future.delayed(Duration(milliseconds: 500)).then((value) {
                  setState(() {

                  });
                },);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                addItem(context);
              },
            ),
          ],
        ),
        body: content,
      ),
    );
  }
}

  