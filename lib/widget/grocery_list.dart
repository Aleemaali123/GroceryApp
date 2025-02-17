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


void addItem(BuildContext context)async{
    await Navigator.of(context).push<GroceryItem>(
    MaterialPageRoute(
      builder: (ctx)=> NewItem(),
    ));

    
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

  