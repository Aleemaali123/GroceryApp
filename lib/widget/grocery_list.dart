import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/data/dummy_items.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/widget/new_item.dart';
import 'package:http/http.dart' as http;


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


void loadItems()async{
 final url = Uri.parse(
      'https://groceryapp-cf2a5-default-rtdb.firebaseio.com/shopping-List.json'
    );
       
    final response = await http.get(url);
    //print(response.body);

    final Map<String,dynamic> listData = json.decode(response.body);

    final List<GroceryItem>loadedItems = [];

    for(final item in listData.entries){
      final category = categoriesData.entries.firstWhere((categoryItem)=> categoryItem.value.title == item.value['category']).value;
          loadedItems.add(GroceryItem(id: item.key, 
          name: item.value['name'], 
          quantity: item.value['quantity'], 
          category: category
          ));
    }

    setState(() {
      groceryItem = loadedItems;
    });
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
        // Item already exists, increment quantity by 1
        final updatedQuantity = groceryItem[existingItemIndex].quantity + 1;
        
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

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated quantity for ${newItem.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
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
        // Add to Firebase first
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
                id: responseData['name'], // Use Firebase-generated ID
                name: newItem.name,
                quantity: newItem.quantity,
                category: newItem.category,
              ),
            );
          });

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${newItem.name} to the list'),
              duration: const Duration(seconds: 2),
            ),
          );
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
      child: Text(
        "No item added yet..."
        ),
        );

        if(groceryItem.isNotEmpty){
        content=   ListView.builder(
        itemCount:groceryItem.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(groceryItem[index].id),
          background: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.75),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
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
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                    child: const Text('Yes'),
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
                  content: Text('${deletedItem.name} removed from the list.'),
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
          child: ListTile(
            title: Text(groceryItem[index].name),
            leading: Container(
              width: 28,
              height: 28,
              color: groceryItem[index].category.color,
            ),
            trailing: Text(groceryItem[index].quantity.toString()),
          ),
        ),
        
        );
        
        }
        
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(
          onPressed: () {
            addItem(context);
          }, 
          icon: Icon(Icons.add)
          )
          ],
        centerTitle: true,
      ),

      body:content
    );
  }
}

  