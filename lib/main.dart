import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application5/services/address_service.dart';
import 'package:flutter_application5/services/canteen_menu_service.dart';
import 'package:flutter_application5/services/order_service.dart';
import 'package:flutter_application5/services/payment_service.dart';
import 'package:flutter_application5/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'services/cart_service.dart';
import 'services/menu_services.dart';
import '../providers/language_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/menu_item.dart';
import '../../models/category.dart';

import 'app.dart'; // Import your custom MyApp

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // In your main.dart or initialization code


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => MenuService()),
        ChangeNotifierProvider(create: (_) => CanteenMenuService()),
        ChangeNotifierProvider(create: (_) => AddressService()),
        // ChangeNotifierProvider(
        //   // Use the context provided by the 'create' callback
        //   create: (context) => PaymentService(context),
        // ),
        ChangeNotifierProvider(create: (_) => TranslateService()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => OrderService()),

      ],
      child: const MyApp(), // Use your app from app.dart
    ),
  );
}

