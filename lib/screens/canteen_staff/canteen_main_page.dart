import 'package:flutter/material.dart';
import 'canteen_home_page.dart';
import 'canteen_menu_page.dart';
import 'canteen_orders_page.dart';  // Assuming you will create this page
import 'canteen_transactions_page.dart';  // Assuming you will create this page

class CanteenMainPage extends StatefulWidget {
  final int initialTabIndex;
  final String? initialCategory;

  const CanteenMainPage({
    Key? key,
    this.initialTabIndex = 0,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<CanteenMainPage> createState() => _StudentMainPageState();
}

class _StudentMainPageState extends State<CanteenMainPage> {
  late int _selectedIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;

    _pages = [
      HomePage(), // Home page
      CanteenMenuPage(initialCategory: widget.initialCategory ?? 'cat_rice'), // Menu page with an initial category
      //OrdersPage(), // Orders page (you need to create this page)
      TransactionsPage(), // Transactions page (you need to create this page)
    ];
  }

  void _onExitPressed() {
    Navigator.pushReplacementNamed(context, '/roleSelection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display selected page

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}
