import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/canteen_menu_service.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart';
import '../../providers/language_provider.dart';

class CanteenMenuPage extends StatefulWidget {
  final String initialCategory;

  const CanteenMenuPage({
    Key? key,
    required this.initialCategory,
  }) : super(key: key);

  @override
  _CanteenMenuPageState createState() => _CanteenMenuPageState();
}

class _CanteenMenuPageState extends State<CanteenMenuPage> {
  late String _selectedCategoryId;

  // App theme colors
  final Color primaryColor = const Color(0xFF757373);
  final Color accentColor = Colors.blue; // More vibrant accent color

  @override
  void initState() {
    super.initState();
    final service = Provider.of<CanteenMenuService>(context, listen: false);
    _selectedCategoryId = widget.initialCategory.isNotEmpty
        ? widget.initialCategory
        : (service.categories.isNotEmpty ? service.categories.first.id : '');
    service.fetchMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTelugu = Provider
        .of<LanguageProvider>(context)
        .isTelugu;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Canteen Menu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Add your exit functionality here, e.g., navigate back to role selection page
            },
          ),
        ],
      ),
      body: Consumer<CanteenMenuService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (service.error.isNotEmpty) {
            return Center(child: Text(service.error));
          }

          final items = service.getItemsByCategory(_selectedCategoryId);

          return Row(
            children: [
              Container(
                width: 120,
                color: Colors.grey[200],
                child: ListView.builder(
                  itemCount: service.categories.length,
                  itemBuilder: (context, index) {
                    final category = service.categories[index];
                    return _buildCategoryButton(category, isTelugu);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  isTelugu ? item.translatedName : item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: item.inStock
                                        ? Colors.black87
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: item.inStock,
                                    activeColor: Colors.green,
                                    inactiveThumbColor: Colors.red[300],
                                    onChanged: (val) {
                                      service.updateStockStatus(item.id, val);
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isTelugu
                                        ? (item.inStock
                                        ? 'స్టాక్‌లో ఉంది'
                                        : 'స్టాక్ లేదు')
                                        : (item.inStock
                                        ? 'In Stock'
                                        : 'Out of Stock'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item.inStock
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenuItemDialog(context),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(Category category, bool isTelugu) {
    final isSelected = _selectedCategoryId == category.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = category.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey[400]!),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? primaryColor : Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(category.imageAsset, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(
              isTelugu ? category.translatedName : category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context) async {
    final _nameController = TextEditingController();
    final _teluguNameController = TextEditingController(); // Added Telugu name controller
    final _descController = TextEditingController();
    final _priceController = TextEditingController();
    String? _selectedCategory;
    bool _inStock = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Add New Menu Item',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.grey[50],
          elevation: 8,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Dropdown
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Colors.black,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory ?? _selectedCategoryId,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    items: Provider.of<CanteenMenuService>(context)
                        .categories
                        .map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Name Input Field (English)
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name (English)',
                    labelStyle: TextStyle(color: primaryColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                // Telugu Name Input Field
                TextField(
                  controller: _teluguNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name (Telugu)',
                    labelStyle: TextStyle(color: primaryColor),
                    hintText: 'తెలుగులో వంటకం పేరు',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                // Description Input Field
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: primaryColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Price Input Field
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: primaryColor),
                    prefixText: '₹ ',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Stock Status Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'In Stock',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _inStock,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _inStock = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red[400]),
              ),
            ),
            // Add Item Button with enhanced UI
            ElevatedButton(
              onPressed: () async {
                final service = Provider.of<CanteenMenuService>(context, listen: false);
                final name = _nameController.text.trim();
                final teluguName = _teluguNameController.text.trim();
                final desc = _descController.text.trim();
                final price = double.tryParse(_priceController.text.trim()) ?? 0;

                // Validate that all required fields are correctly filled
                if (name.isEmpty || price <= 0 || _selectedCategory == null || _selectedCategory!.isEmpty) {
                  // Show validation error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please fill all required fields correctly.'),
                      backgroundColor: Colors.red[400],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }

                final newItem = MenuItem(
                  id: '', // This will be set later by Firestore
                  name: name,
                  description: desc,
                  categoryId: _selectedCategory!,
                  price: price,
                  inStock: _inStock,
                  translatedName: teluguName.isNotEmpty ? teluguName : name, // Use Telugu name if provided, otherwise fallback to English
                );

                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  );

                  // Add item to Firestore
                  await service.addMenuItem(newItem);

                  // Close loading dialog
                  Navigator.pop(context);

                  // Close dialog and show success message
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item successfully added!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } catch (e) {
                  // Close loading dialog
                  Navigator.pop(context);

                  // Handle errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add item: $e'),
                      backgroundColor: Colors.red[400],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}