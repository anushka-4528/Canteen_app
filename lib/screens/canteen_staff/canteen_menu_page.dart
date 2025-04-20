import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart';
import '../../services/menu_services.dart';

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

  @override
  void initState() {
    super.initState();
    final service = Provider.of<MenuService>(context, listen: false);
    _selectedCategoryId = widget.initialCategory.isNotEmpty
        ? widget.initialCategory
        : (service.categories.isNotEmpty ? service.categories.first.id : '');
    service.fetchMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Menu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF757373),
        elevation: 4,
      ),
      body: Consumer<MenuService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.error.isNotEmpty) {
            return Center(child: Text(service.error));
          }

          final items = service.getItemsByCategory(
            service.menuItems,
            _selectedCategoryId,
          );

          return Row(
            children: [
              Container(
                width: 120,
                color: Colors.grey[200],
                child: ListView.builder(
                  itemCount: service.categories.length,
                  itemBuilder: (context, index) {
                    final category = service.categories[index];
                    return _buildCategoryButton(category);
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
                                  item.name,
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
                                    item.inStock ? 'In Stock' : 'Out of Stock',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item.inStock ? Colors.green : Colors.red,
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
    );
  }

  Widget _buildCategoryButton(Category category) {
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
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(category.imageAsset, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF757373) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
