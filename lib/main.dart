import 'package:delivery_service_user/authentication/auth_screen.dart';
import 'package:delivery_service_user/mainScreens/checkout_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue, // Main color
            accentColor: Colors.blueAccent, // Accent color
            errorColor: Colors.red, // Error color
            brightness: Brightness.light
        ),
        useMaterial3: true,
      ),
      home: AuthScreen(),
    );
  }
}

