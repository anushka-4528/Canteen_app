import 'package:flutter/material.dart';
import 'package:flutter_application5/screens/auth/login_selection.dart';
import 'package:flutter_application5/screens/student/previous_orders.dart';
import 'package:flutter_application5/screens/student/student_favorites_page.dart';
import 'package:provider/provider.dart';
import '../../services/menu_services.dart';
import '../../models/category.dart';
import '../../models/menu_item.dart';
import '../../services/cart_service.dart';
import '../../services/address_service.dart';
import '../../models/address_model.dart';
import 'student_profile_page.dart';
import 'student_address_page.dart';
import 'student_main_page.dart';


class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedAddress = '';
  final TextEditingController _searchController = TextEditingController();
  String _categoryId = 'cat_rice';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuService = Provider.of<MenuService>(context, listen: false);
      final addressService = Provider.of<AddressService>(
          context, listen: false);

      final menuItems = menuService.menuItems;
      menuService.getItemsByCategory(menuItems, _categoryId);

      final List<String> popularItemIds = [
        'item_paneer_tikka',
        'item_noodles_mix',
        'item_meals',
        'item_mix_fried_rice',
        'item_shanghai_roll',
        'item_veg_biryani',
        'item_pasta',
      ];
      menuService.getPopularItems(popularItemIds);

      final addresses = addressService.addresses;
      if (addresses.isNotEmpty) {
        setState(() {
          _selectedAddress = addresses.first.title;
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final addressService = Provider.of<AddressService>(context);

    return Scaffold(

      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(addressService),
            _buildSearchBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFoodBanner(),
                    _buildCategories(),
                    _buildPopularOrders(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AddressService addressService) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 18),
                  SizedBox(width: 4),
                  DropdownButton<String>(
                    value: addressService.selectedAddress,
                    underline: SizedBox(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        addressService.selectAddress(newValue);
                      }
                    },
                    items: addressService.addresses.map((address) {
                      return DropdownMenuItem<String>(
                        value: address.title,
                        child: Text(address.title),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.person, size: 28),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey there, Food lover!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => FavoritesScreen()), // Navigate to Favorites Page
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.favorite, color: Colors.red),
                                      SizedBox(height: 8),
                                      Text('Favorites'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => PreviousOrdersPage()), // Navigate to Order History Page
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.history, color: Colors.blue),
                                      SizedBox(height: 8),
                                      Text('Order History'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => LoginSelection()), // Navigate to LoginSelection Page
                                    (route) => false, // Remove all previous routes
                              );
                            },
                            icon: Icon(Icons.logout),
                            label: Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )

        ],
      ),
    );
  }

  // Updated _buildSearchBar
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => _openSearchSheet(),
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Search for food...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _openSearchSheet() {
    final menuService = Provider.of<MenuService>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);
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
                          decoration: InputDecoration(
                            hintText: 'Search food...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              filteredItems = allItems
                                  .where((item) => item.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
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
                            final isInStock = item.inStock;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text('₹${item.price.toString()}'),
                                      SizedBox(height: 8),
                                      if (isInStock && quantity == 0)
                                        ElevatedButton(
                                          onPressed: () async {
                                            await cartService.addItemToCart({
                                              'id': item.id,
                                              'name': item.name,
                                              'price': item.price,
                                            });
                                            setState(() {}); // update UI
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text("Add to Cart", style: TextStyle(color: Colors.white)),
                                        ),
                                      if (isInStock && quantity > 0)
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade400),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove, size: 18),
                                                onPressed: () async {
                                                  await cartService.decreaseQuantity(item.id);
                                                  setState(() {});
                                                },
                                              ),
                                              Text('$quantity', style: TextStyle(fontSize: 16)),
                                              IconButton(
                                                icon: Icon(Icons.add, size: 18),
                                                onPressed: () async {
                                                  await cartService.increaseQuantity(item.id);
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (!isInStock)
                                        Text(
                                          'Out of Stock',
                                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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


  Widget _buildFoodBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('assets/images/banner1.jpg', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCategories() {
    return Consumer<MenuService>(
      builder: (context, menuService, child) {
        if (menuService.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (menuService.error.isNotEmpty) {
          return Center(child: Text(menuService.error));
        }

        List<Category> categories = menuService.categories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text("What's on the menu?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(categories[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StudentMainPage(
                  initialTabIndex: 1,
                  initialCategory: category.id,
                ),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 4)
                ],
              ),
              child: Image.asset(category.imageAsset, fit: BoxFit.contain),
            ),
            SizedBox(height: 8),
            Text(category.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularOrders() {
    return Consumer2<MenuService, CartService>(
      builder: (context, menuService, cartService, child) {
        if (menuService.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (menuService.error.isNotEmpty) {
          return Center(child: Text(menuService.error));
        }

        List<MenuItem> popularItems = menuService.popularItems;

        if (popularItems.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('No popular items available.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'The Crowd Pleasers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: popularItems.length,
              itemBuilder: (context, index) {
                final item = popularItems[index];
                final isInStock = item.inStock;
                final cartItem = cartService.cartItems.firstWhere(
                      (cartItem) => cartItem['id'] == item.id,
                  orElse: () => {},
                );
                final quantity = cartItem.isNotEmpty ? cartItem['quantity'] : 0;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text('₹${item.price.toString()}'),
                        SizedBox(height: 8),
                        if (isInStock && quantity == 0)
                          ElevatedButton(
                            onPressed: () async {
                              await cartService.addItemToCart({
                                'id': item.id,
                                'name': item.name,
                                'price': item.price,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Add to Cart",style:TextStyle(color: Colors.white),),
                          ),
                        if (isInStock && quantity > 0)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, size: 18),
                                  color: Colors.black,
                                  onPressed: () async {
                                    await cartService.decreaseQuantity(item.id);
                                  },
                                ),
                                Text(
                                  '$quantity',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, size: 18),
                                  color: Colors.black,
                                  onPressed: () async {
                                    await cartService.increaseQuantity(item.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        if (!isInStock)
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Out of Stock',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.grey.shade600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text("Add to Cart"),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
