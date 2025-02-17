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

    // if (newItem == null) {
    //   return; // If the user cancels adding an item, do nothing.
    // }

    if(newItem != null){
      //check if the item already exists
      final existingItemIndex = groceryItem.indexWhere((item)=>item.name == newItem.quantity);


      if(existingItemIndex != -1){
        //item already exists, update quantity
        setState(() {
          groceryItem[existingItemIndex].quantity + newItem.quantity;
        });


        //now update the quantity on firebase for the existing item

        final existingItemId = groceryItem[existingItemIndex].id;

        final url = Uri.https(
          'groceryapp-cf2a5-default-rtdb.firebaseio.com',
          '/shopping-List/$existingItemId.json',
        );
        await http.patch(
          url,
          headers: {
            'Content - Type': 'application/json'
          },
          body: json.encode({

            'quantity':groceryItem[existingItemIndex].quantity,

          })
        );
      }
      else{
        //item doesnt exist, add item
        setState(() {
          groceryItem.add(newItem);
        });

        //add to firebase
        final url = Uri.https(
          'groceryapp-cf2a5-default-rtdb.firebaseio.com',
          '/shopping-List.json',
        );
        await http.post(url,
        headers: {
          'Content-Type': 'application/json'
        },
          body: json.encode(
            {
              'name' : newItem.name,
              'quantity' : newItem.quantity,
              'category': newItem.category.title
            }
          )


        );
      }
    }

    // setState(() {
    //   groceryItem.add(newItem!);
    // });
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
         onDismissed: (direction){
              _removeItem(groceryItem[index]);
         },
          
        

         key: ValueKey(groceryItem[index].id),
           child: 
           ListTile(
            title: Text(groceryItem[index].name),
            leading:Container(
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

  