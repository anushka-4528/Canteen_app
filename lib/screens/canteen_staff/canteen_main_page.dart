// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/translation_service.dart';
// import '../../providers/language_provider.dart'; // new
// import 'canteen_home_page.dart';
// import 'canteen_menu_page.dart';
// import 'canteen_orders_page.dart';
// import 'canteen_transactions_page.dart';
//
// class CanteenMainPage extends StatefulWidget {
//   final int initialTabIndex;
//   final String? initialCategory;
//
//   const CanteenMainPage({
//     Key? key,
//     this.initialTabIndex = 0,
//     this.initialCategory,
//   }) : super(key: key);
//
//   @override
//   State<CanteenMainPage> createState() => _CanteenMainPageState();
// }
//
// class _CanteenMainPageState extends State<CanteenMainPage> {
//   late int _selectedIndex;
//   late List<Widget> _pages;
//   List<String> _englishTitles = ['Home', 'Menu', 'Orders', 'Transactions'];
//   List<String> _teluguTitles = ['హోమ్', 'మెనూ', 'ఆర్డర్స్', 'ట్రాన్సాక్షన్స్']; // Spelled English in Telugu
//   final TranslateService _translateService = TranslateService();
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.initialTabIndex;
//     _pages = [
//       HomePage(),
//       CanteenMenuPage(initialCategory: widget.initialCategory ?? 'cat_rice'),
//       //OrdersPage(),
//       TransactionsPage(),
//     ];
//   }
//
//   void _onExitPressed() {
//     Navigator.pushReplacementNamed(context, '/roleSelection');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isTelugu = Provider.of<LanguageProvider>(context).isTelugu;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isTelugu ? _teluguTitles[_selectedIndex] : _englishTitles[_selectedIndex]),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.language),
//             onPressed: () {
//               Provider.of<LanguageProvider>(context, listen: false).toggleLanguage();
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             onPressed: _onExitPressed,
//           ),
//         ],
//       ),
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         selectedItemColor: Theme.of(context).primaryColor,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.home),
//             label: isTelugu ? _teluguTitles[0] : _englishTitles[0],
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.restaurant_menu),
//             label: isTelugu ? _teluguTitles[1] : _englishTitles[1],
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.list),
//             label: isTelugu ? _teluguTitles[2] : _englishTitles[2],
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.attach_money),
//             label: isTelugu ? _teluguTitles[3] : _englishTitles[3],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/translation_service.dart';
import '../../providers/language_provider.dart'; // Ensure you have a LanguageProvider
import 'canteen_home_page.dart';
import 'canteen_menu_page.dart';
import 'canteen_orders_page.dart';
import 'canteen_transactions_page.dart';

class CanteenMainPage extends StatefulWidget {
  final int initialTabIndex;
  final String? initialCategory;

  const CanteenMainPage({
    Key? key,
    this.initialTabIndex = 0,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<CanteenMainPage> createState() => _CanteenMainPageState();
}

class _CanteenMainPageState extends State<CanteenMainPage> {
  late int _selectedIndex;
  late List<Widget> _pages;
  List<String> _englishTitles = ['Home', 'Menu', 'Orders', 'Transactions'];
  List<String> _teluguTitles = ['హోమ్', 'మెనూ', 'ఆర్డర్స్', 'ట్రాన్సాక్షన్స్']; // Telugu titles

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _pages = [
      CanteenHomePage(),
      CanteenMenuPage(initialCategory: widget.initialCategory ?? 'cat_rice'),
      CanteenOrdersPage(), // Make sure this page exists
      TransactionsPage(), // Make sure this page exists
    ];
  }

  void _onExitPressed() {
    Navigator.pushReplacementNamed(context, '/roleSelection');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        bool isTelugu = languageProvider.isTelugu;

        return Scaffold(

          body: _pages[_selectedIndex],
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
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: isTelugu ? _teluguTitles[0] : _englishTitles[0],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.restaurant_menu),
                label: isTelugu ? _teluguTitles[1] : _englishTitles[1],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.list),
                label: isTelugu ? _teluguTitles[2] : _englishTitles[2],
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.attach_money),
                label: isTelugu ? _teluguTitles[3] : _englishTitles[3],
              ),
            ],
          ),
        );
      },
    );
  }
}

