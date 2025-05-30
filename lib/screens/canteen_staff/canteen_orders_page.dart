import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class CanteenOrdersPage extends StatefulWidget {
  const CanteenOrdersPage({super.key});

  @override
  State<CanteenOrdersPage> createState() => _CanteenOrdersPageState();
}

class _CanteenOrdersPageState extends State<CanteenOrdersPage> {
  String selectedFilter = 'All';

  // Telugu translations for all UI elements
  final Map<String, String> _translations = {
    // App Bar
    'Canteen Orders': 'క్యాంటీన్ ఆర్డర్లు',

    // Filter Labels
    'All Orders': 'అన్ని ఆర్డర్లు',
    'Completed Orders': 'పూర్తయిన ఆర్డర్లు',
    'Pending': 'పెండింగ్',
    'Ready for Pickup': 'పికప్ కోసం సిద్ధం',

    // Order Card Labels
    'Order ID': 'ఆర్డర్ ID',
    'Delivery Address': 'డెలివరీ చిరునామా',
    'Placed': 'ఆర్డర్ చేసిన సమయం',
    'Total': 'మొత్తం',
    'Mark as Ready': 'సిద్ధంగా గుర్తించండి',
    'Mark as Delivered': 'డెలివరీ అయినట్లు గుర్తించండి',
    'Order Completed': 'ఆర్డర్ పూర్తయింది',

    // Status Labels
    'Ready': 'సిద్ధం',
    'Delivered': 'డెలివరీ అయింది',

    // Messages
    'Something went wrong': 'ఏదో తప్పు జరిగింది',
    'No orders found': 'ఆర్డర్లు కనుగొనబడలేదు',
    'Order marked as': 'ఆర్డర్ను గుర్తించారు',
    'Error updating order': 'ఆర్డర్ అప్‌డేట్ చేయడంలో లోపం',

    // Filter values for internal use
    'All': 'అన్నీ',
    'Completed': 'పూర్తయింది',
    'Ready': 'సిద్ధం',
  };

  String _translate(String text, bool isTelugu) {
    return isTelugu ? (_translations[text] ?? text) : text;
  }

  // Get start and end of current day
  DateTime get _startOfDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _endOfDay {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
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
          content: Text('${_translate('Order marked as', isTelugu)} ${_translate(newStatus, isTelugu)}!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final bool isTelugu = languageProvider.isTelugu;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_translate('Error updating order', isTelugu)}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<DocumentSnapshot> _filterOrders(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'Pending';

      switch (selectedFilter) {
        case 'Completed':
          return status == 'Delivered';
        case 'Pending':
          return status == 'Pending';
        case 'Ready':
          return status == 'Ready';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isTelugu = languageProvider.isTelugu;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _translate('Canteen Orders', isTelugu),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF757373),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterGrid(isTelugu),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('canteenOrders')
                    .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfDay))
                    .where('time', isLessThanOrEqualTo: Timestamp.fromDate(_endOfDay))
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(_translate("Something went wrong", isTelugu))
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  final filteredDocs = _filterOrders(docs);

                  if (filteredDocs.isEmpty) {
                    return Center(
                        child: Text(_translate("No orders found", isTelugu))
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data() as Map<String, dynamic>;
                      final orderId = filteredDocs[index].id;
                      return _buildOrderCard(data, orderId, isTelugu);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterGrid(bool isTelugu) {
    return SizedBox(
      height: 220,
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.0,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildFilterTile(
            label: _translate("All Orders", isTelugu),
            filter: "All",
            icon: Icons.list,
            color: Colors.blue.shade50,
            borderColor: Colors.blue,
            iconColor: Colors.blue,
          ),
          _buildFilterTile(
            label: _translate("Completed Orders", isTelugu),
            filter: "Completed",
            icon: Icons.check_circle_outline,
            color: Colors.orange.shade50,
            borderColor: Colors.orange,
            iconColor: Colors.orange,
          ),
          _buildFilterTile(
            label: _translate("Pending", isTelugu),
            filter: "Pending",
            icon: Icons.hourglass_bottom,
            color: Colors.red.shade50,
            borderColor: Colors.red,
            iconColor: Colors.red,
          ),
          _buildFilterTile(
            label: _translate("Ready for Pickup", isTelugu),
            filter: "Ready",
            icon: Icons.check_circle,
            color: Colors.green.shade50,
            borderColor: Colors.green,
            iconColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTile({
    required String label,
    required String filter,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required Color iconColor,
  }) {
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? borderColor.withOpacity(0.2) : color,
          border: Border.all(color: isSelected ? borderColor : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> data, String orderId, bool isTelugu) {
    final items = data['items'] as List<dynamic>;

    // Use telugu_name from Firestore if available and Telugu is selected
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
        .join(', ');

    final total = data['total'] ?? 0;
    final status = data['status'] ?? 'Pending';
    final location = data['location'] ?? '';
    final time = (data['time'] as Timestamp?)?.toDate();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemNames,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              '${_translate('Order ID', isTelugu)}: $orderId',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '${_translate('Delivery Address', isTelugu)}: $location',
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                '${_translate('Placed', isTelugu)}: ${time.toLocal().toString().split('.')[0]}',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_translate('Total', isTelugu)}: ₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _translate(status, isTelugu),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (status != 'Delivered') ...[
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
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  _translate('Order Completed', isTelugu),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Ready':
        return Colors.orange;
      case 'Pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}