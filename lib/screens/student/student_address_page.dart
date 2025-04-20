// address_page.dart
import 'package:flutter/material.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of predefined addresses
    final List<Map<String, String>> addresses = [
      {'name': 'Block A', 'details': 'Enable location services'},
      {'name': 'Block B', 'details': 'Enable location services'},
      {'name': 'Block F', 'details': 'Enable location services'},
      {'name': 'Block D', 'details': 'Enable location services'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for new address',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Nearby addresses title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nearby addresses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // List of addresses
          Expanded(
            child: ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(addresses[index]['name']!),
                  subtitle: Text(addresses[index]['details']!),
                  onTap: () {
                    // Return selected address to home page
                    Navigator.pop(context, addresses[index]['name']);
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