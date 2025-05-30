// import 'package:flutter/material.dart';
// import 'student_home_page.dart';
// import 'student_menu_page.dart';
// import 'student_favorites_page.dart';
// import 'student_cart_page.dart';
//
// class StudentMainPage extends StatefulWidget {
//   final int initialTabIndex;
//   final String? initialCategory;
//
//   const StudentMainPage({
//     Key? key,
//     this.initialTabIndex = 0,
//     this.initialCategory,
//   }) : super(key: key);
//
//   @override
//   State<StudentMainPage> createState() => _StudentMainPageState();
// }
//
// class _StudentMainPageState extends State<StudentMainPage> {
//   late int _selectedIndex;
//   late List<Widget> _pages;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialTabIndex;
//
//     _pages = [
//       HomeScreen(),
//       StudentMenuScreen(initialCategory: widget.initialCategory ?? 'cat_rice'),
//       FavoritesScreen(),
//       CartPage(),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_selectedIndex != 0) {
//           setState(() {
//             _selectedIndex = 0;
//           });
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         body: _pages[_selectedIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _selectedIndex,
//           onTap: (index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//           selectedItemColor: Theme.of(context).primaryColor,
//           unselectedItemColor: Colors.grey,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.restaurant_menu),
//               label: 'Menu',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.favorite),
//               label: 'Favorites',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.shopping_cart),
//               label: 'Cart',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'student_home_page.dart';
import 'student_menu_page.dart';
import 'student_favorites_page.dart';
import 'student_cart_page.dart';
import '../../services/order_service.dart';
import '../../screens/canteen_staff/order_status_page.dart'; // ✅ Adjust path if needed

class StudentMainPage extends StatefulWidget {
  final int initialTabIndex;
  final String? initialCategory;

  const StudentMainPage({
    Key? key,
    this.initialTabIndex = 0,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<StudentMainPage> createState() => _StudentMainPageState();
}

class _StudentMainPageState extends State<StudentMainPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);
    final activeOrder = orderService.activeOrder;
    final hasActiveOrder = activeOrder != null;

    // Build the list of pages dynamically
    final List<Widget> pages = [
      HomeScreen(),
      StudentMenuScreen(initialCategory: widget.initialCategory ?? 'cat_rice'),
      FavoritesScreen(),
      if (hasActiveOrder) OrderStatusPage(orderId: activeOrder.id),
      CartPage(),
    ];

    // Build the list of bottom navigation items dynamically
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
      const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
      if (hasActiveOrder)
        const BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Track'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
    ];

    // Fix the index if it’s out of range (like when Track tab disappears)
    final maxIndex = pages.length - 1;
    if (_selectedIndex > maxIndex) {
      _selectedIndex = maxIndex;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: pages[_selectedIndex],
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
          items: items,
        ),
      ),
    );
  }
}
