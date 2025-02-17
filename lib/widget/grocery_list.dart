import 'package:flutter/material.dart';
import 'package:grocery_app/data/dummy_items.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/widget/new_item.dart';


class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryList();
}


class _GroceryList extends State<GroceryList> {
 
final List<GroceryItem> groceryItem = [];


void addItem(BuildContext context)async{
  final newItem  = await Navigator.of(context).push<GroceryItem>(
    MaterialPageRoute(
      builder: (ctx)=> NewItem(),
    ));

    if(newItem == null){
      return;
    }
  
      setState((){
        groceryItem.add(newItem);
      });

       
  
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
              width: 24,
              height: 24,
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

  