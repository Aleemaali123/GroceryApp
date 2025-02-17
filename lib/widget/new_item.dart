import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/models/category.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;


class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var enteredName = '';
  var enteredQuantity = 1;
  var selectedCategory = categoriesData[Categories.vegitables]!;


  void saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.https(
        'groceryapp-cf2a5-default-rtdb.firebaseio.com',
        '/shopping-List.json',
      );

      try {
        // First, fetch existing items
        final getResponse = await http.get(url);
        
        if (getResponse.statusCode >= 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to check existing items. Please try again.')),
          );
          return;
        }

        final Map<String, dynamic> existingItems = json.decode(getResponse.body) ?? {};
        String? existingItemId;
        int? existingQuantity;

        // Check if an item with the same name exists
        existingItems.forEach((id, item) {
          if (item['name'] == enteredName) {
            existingItemId = id;
            existingQuantity = item['quantity'];
          }
        });

        if (existingItemId != null) {
          // Update existing item's quantity
          final updateUrl = Uri.https(
            'groceryapp-cf2a5-default-rtdb.firebaseio.com',
            '/shopping-List/$existingItemId.json',
          );

          final updateResponse = await http.patch(
            updateUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'quantity': existingQuantity! + enteredQuantity,
            }),
          );

          if (updateResponse.statusCode >= 400) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update item. Please try again.')),
            );
            return;
          }

          if (!context.mounted) return;

          // Return the updated grocery item
          Navigator.of(context).pop(
            GroceryItem(
              id: existingItemId!,
              name: enteredName,
              quantity: existingQuantity! + enteredQuantity,
              category: selectedCategory,
            ),
          );
        } else {
          // Add new item if it doesn't exist
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': enteredName,
              'quantity': enteredQuantity,
              'category': selectedCategory.title,
            }),
          );

          if (response.statusCode >= 400) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add item. Please try again.')),
            );
            return;
          }

          final Map<String, dynamic> responseData = json.decode(response.body);

          if (!context.mounted) return;

          Navigator.of(context).pop(
            GroceryItem(
              id: responseData['name'],
              name: enteredName,
              quantity: enteredQuantity,
              category: selectedCategory,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('Add New Item'),
      centerTitle: true,
    ),

    body: Padding(
      padding: EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              maxLength: 50,
              decoration: InputDecoration(
                label: Text('Name'),
              ),
              validator: (value) {
                if(value == null ||
                 value.isEmpty || 
                 value.trim().length ==  1 ||
                  value.trim().length > 50 ){
                return 'Must be betweeen 1 and 50 characters.';
                }
                return null;
              },

              onSaved: (value) {
                // if(value == null){
                //   return;
                // }
                setState(() {
                  
                });
                enteredName = value!;
               
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: Text('Quantity')
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: enteredQuantity.toString(),
                    validator: (value) {
                if(value == null ||
                 value.isEmpty || 
                 int.tryParse(value)== null ||
                 int.tryParse(value) ! <= 0) {
                return 'Must be a valid, postitve number.';
                }
                return null;
              },
              onSaved: (value) {
                enteredQuantity = int.parse(value!) ;
              },
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: DropdownButtonFormField(
                    value: selectedCategory,
                    items: [
                      for(final category in categoriesData.entries)
                      DropdownMenuItem(
                        value: category.value,
                        child: Row(
                          children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                ),
                                SizedBox(width: 8,),
                                Text(category.value.title)
                          ],
                          )
                        
                        )
                    ], 
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                      
                    },
                    ),
                )
              ],
            ),
              SizedBox(
                height: 15,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                  }, 
                  child: Text('Reset')
                  ),
                  ElevatedButton(
                    onPressed: () {
                      saveItem();
                    },
                     child: Text('Add Item')
                     )
              ],
            )
          ],
        )
        )
    )
    );
  }
}