import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/menu_item.dart';
import '../../models/order_model.dart';
import '../../services/cart_service.dart';
import '../../services/menu_services.dart';
import '../../services/order_service.dart';
import '../../providers/language_provider.dart';
import '../auth/login_selection.dart';

class CanteenHomePage extends StatefulWidget {
  const CanteenHomePage({Key? key}) : super(key: key);

  @override
  State<CanteenHomePage> createState() => _CanteenHomePageState();
}

class _CanteenHomePageState extends State<CanteenHomePage> {
  final TextEditingController _searchController = TextEditingController();

  // Telugu translations for UI elements
  final Map<String, String> _translations = {
    'Canteen Home': 'క్యాంటీన్ హోమ్',
    'Search for food...': 'ఆహారాన్ని శోధించండి...',
    'Search food...': 'ఆహారాన్ని శోధించండి...',
    'No orders yet': 'ఇంకా ఆర్డర్లు లేవు',
    'Recent Orders': 'ఇటీవలి ఆర్డర్లు',
    'Items': 'వస్తువులు',
    'Order ID': 'ఆర్డర్ ID',
    'Location': 'స్థానం',
    'Total': 'మొత్తం',
    'Mark as Ready': 'సిద్ధంగా గుర్తించండి',
    'Mark as Delivered': 'డెలివరీ అయినట్లు గుర్తించండి',
    'Order marked as': 'ఆర్డర్ను గుర్తించారు',
    'Ready': 'సిద్ధం',
    'Delivered': 'డెలివరీ అయింది',
    'Pending': 'పెండింగ్',
    'In Stock': 'స్టాక్‌లో ఉంది',
    'Out of Stock': 'స్టాక్ లేదు',
    'Logout': 'లాగ్ అవుట్',
    'Confirm Logout': 'లాగ్ అవుట్ నిర్ధారించండి',
    'Are you sure you want to logout?': 'మీరు ఖచ్చితంగా లాగ్ అవుట్ చేయాలనుకుంటున్నారా?',
    'Cancel': 'రద్దు చేయండి',
    'Yes, Logout': 'అవును, లాగ్ అవుట్',
  };

  String _translate(String text, bool isTelugu) {
    return isTelugu ? (_translations[text] ?? text) : text;
  }

  // Helper method to get start and end of today
  Map<String, Timestamp> _getTodayRange() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return {
      'start': Timestamp.fromDate(startOfDay),
      'end': Timestamp.fromDate(endOfDay),
    };
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('canteenOrders')
          .doc(orderId)
          .update({'status': newStatus});

      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final bool isTelugu = languageProvider.isTelugu;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${_translate('Order marked as', isTelugu)} ${_translate(newStatus, isTelugu)}!",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final bool isTelugu = languageProvider.isTelugu;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _translate('Confirm Logout', isTelugu),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(_translate('Are you sure you want to logout?', isTelugu)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                _translate('Cancel', isTelugu),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginSelection()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(_translate('Yes, Logout', isTelugu)),
            ),
          ],
        );
      },
    );
  }

  void _openSearchSheet() {
    final menuService = Provider.of<MenuService>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final bool isTelugu = languageProvider.isTelugu;

    List<MenuItem> allItems = menuService.menuItems;
    List<MenuItem> filteredItems = List.from(allItems);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: _translate('Search food...', isTelugu),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              filteredItems = allItems
                                  .where((item) {
                                final searchText = value.toLowerCase();
                                final itemName = isTelugu
                                    ? item.translatedName.toLowerCase()
                                    : item.name.toLowerCase();
                                return itemName.contains(searchText);
                              })
                                  .toList();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final cartItem = cartService.cartItems.firstWhere(
                                  (cartItem) => cartItem['id'] == item.id,
                              orElse: () => {},
                            );
                            final quantity = cartItem.isNotEmpty ? cartItem['quantity'] : 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isTelugu ? item.translatedName : item.name,
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                              setState(() {
                                                final updatedItem = MenuItem(
                                                  id: item.id,
                                                  name: item.name,
                                                  price: item.price,
                                                  categoryId: item.categoryId,
                                                  inStock: val,
                                                  description: item.description,
                                                  translatedName: item.translatedName,
                                                );

                                                int itemIndex = filteredItems.indexOf(item);
                                                filteredItems[itemIndex] = updatedItem;
                                              });

                                              menuService.updateStockStatus(item.id, val);
                                            },
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _translate(item.inStock ? 'In Stock' : 'Out of Stock', isTelugu),
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTelugu = languageProvider.isTelugu;
    final todayRange = _getTodayRange();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _translate('Canteen Home', isTelugu),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF757373),
        elevation: 0,
        actions: [
          // Language Toggle
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    'EN',
                    style: TextStyle(
                      color: !isTelugu ? Colors.white : Colors.white70,
                      fontWeight: !isTelugu ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
                Switch(
                  value: isTelugu,
                  onChanged: (value) {
                    languageProvider.toggleLanguage();
                  },
                  activeColor: Colors.orange,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  inactiveThumbColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    'తె',
                    style: TextStyle(
                      color: isTelugu ? Colors.white : Colors.white70,
                      fontWeight: isTelugu ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: _openSearchSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _translate('Search for food...', isTelugu),
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  _translate('Recent Orders', isTelugu),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('canteenOrders')
                  .where('status', whereIn: ['Pending', 'Ready'])
                  .where('time', isGreaterThanOrEqualTo: todayRange['start'])
                  .where('time', isLessThanOrEqualTo: todayRange['end'])
                  .orderBy('time', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      _translate('No orders yet', isTelugu),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final orderId = docs[index].id;
                    final items = data['items'] as List<dynamic>;
                    final status = data['status'] ?? 'Pending';
                    final total = data['total'] ?? 0;
                    final location = data['location'] ?? '';
                    final time = (data['time'] as Timestamp?)?.toDate();

                    final itemNames = items
                        .map((item) {
                      // Use telugu_name from Firestore if available and Telugu is selected
                      if (isTelugu && item['telugu_name'] != null && item['telugu_name'].toString().isNotEmpty) {
                        return item['telugu_name'] as String;
                      }
                      // Fallback to translatedName if telugu_name is not available
                      else if (isTelugu && item['translatedName'] != null && item['translatedName'].toString().isNotEmpty) {
                        return item['translatedName'] as String;
                      }
                      // Default to English name
                      return item['name'] as String;
                    })
                        .toList()
                        .join(', ');

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${_translate('Items', isTelugu)}: ',
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                  TextSpan(
                                    text: itemNames,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_translate('Order ID', isTelugu)}: $orderId',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_translate('Location', isTelugu)}: $location',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (time != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Placed: ${time.toLocal().toString().split('.')[0]}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_translate('Total', isTelugu)}: ₹${total.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'Ready' ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: status == 'Ready' ? Colors.orange : Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _translate(status, isTelugu),
                                    style: TextStyle(
                                      color: status == 'Ready' ? Colors.orange : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final newStatus = status == 'Ready' ? 'Delivered' : 'Ready';
                                  await _updateOrderStatus(orderId, newStatus);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: status == 'Ready' ? Colors.blue : Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text(
                                  _translate(status == 'Ready' ? 'Mark as Delivered' : 'Mark as Ready', isTelugu),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}