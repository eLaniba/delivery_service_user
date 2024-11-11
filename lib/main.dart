import 'package:delivery_service_user/authentication/auth_screen.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/checkout_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_screen.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/sampleFeatures/order_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'global/global.dart';
import 'sampleFeatures/Sample.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const customTextColor = Color.fromARGB(255, 52, 49, 49); // RGB(52, 49, 49)

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          accentColor: Colors.redAccent,
          errorColor: Colors.red,
          brightness: Brightness.light,
        ).copyWith(
          onPrimary: Colors.white, // Text/icon color on primary elements
          onSurface: customTextColor, // Default text color on surfaces
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: customTextColor),
          bodyMedium: TextStyle(color: customTextColor),
          titleLarge: TextStyle(color: customTextColor), // AppBar title color
        ),
        iconTheme: const IconThemeData(color: customTextColor), // Custom icon color
        useMaterial3: true,
      ),
      home: MainScreen(),
    );
  }
}

