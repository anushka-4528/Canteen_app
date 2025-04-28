import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application5/services/address_service.dart';
import 'package:flutter_application5/services/payment_service.dart';
import 'package:provider/provider.dart';
import 'services/cart_service.dart';
import 'services/menu_services.dart';

import 'app.dart'; // Import your custom MyApp

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => MenuService()),
        ChangeNotifierProvider(create: (_) => AddressService()),
        ChangeNotifierProvider(
          // Use the context provided by the 'create' callback
          create: (context) => PaymentService(context),
        ),
      ],
      child: const MyApp(), // Use your app from app.dart
    ),
  );
}
