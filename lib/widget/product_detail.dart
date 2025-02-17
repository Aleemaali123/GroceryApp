import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class ProductDetail extends StatefulWidget {
  final GroceryItem item;

  const ProductDetail({super.key, required this.item});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late GroceryItem currentItem;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    currentItem = widget.item;
    _quantityController = TextEditingController(text: currentItem.quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${currentItem.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteItem() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    final url = Uri.https(
      'groceryapp-cf2a5-default-rtdb.firebaseio.com',
      '/shopping-List/${currentItem.id}.json',
    );

    try {
      final response = await http.delete(url);
      
      if (response.statusCode >= 400) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete item.')),
        );
        return;
      }

      if (!context.mounted) return;
      Navigator.of(context).pop('refresh'); // Return 'refresh' instead of true
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item.')),
      );
    }
  }

  Future<void> _updateQuantity() async {
    if (!_formKey.currentState!.validate()) return;
    
    final newQuantity = int.parse(_quantityController.text);
    
    final url = Uri.https(
      'groceryapp-cf2a5-default-rtdb.firebaseio.com',
      '/shopping-List/${currentItem.id}.json',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode >= 400) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update quantity.')),
        );
        return;
      }

      setState(() {
        currentItem = GroceryItem(
          id: currentItem.id,
          name: currentItem.name,
          quantity: newQuantity,
          category: currentItem.category,
        );
        isEditing = false;
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity updated successfully!')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update quantity.')),
      );
    }
  }

  void _goBack() {
    Navigator.of(context).pop('refresh'); // Return 'refresh' instead of true
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false; // We handle the back navigation ourselves
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteItem,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            currentItem.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Category:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                color: currentItem.category.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentItem.category.title,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ID:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            currentItem.id,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quantity:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (!isEditing)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => setState(() => isEditing = true),
                                ),
                            ],
                          ),
                          if (isEditing) ...[
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Enter new quantity',
                              ),
                              validator: (value) {
                                if (value == null || 
                                    value.isEmpty || 
                                    int.tryParse(value) == null || 
                                    int.tryParse(value)! <= 0) {
                                  return 'Please enter a valid positive number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => setState(() => isEditing = false),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _updateQuantity,
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          ] else
                            Text(
                              currentItem.quantity.toString(),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 