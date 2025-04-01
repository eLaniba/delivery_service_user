import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/authentication/auth_screen_remake.dart';
import 'package:delivery_service_user/widgets/report_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'global/global.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'services/providers/badge_provider.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  //Using Flutter Native Splash
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore Persistence using the latest approach
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // ✅ Enables offline caching
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // ✅ Optional: No limit on cache size
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    const customTextColor = Color.fromARGB(255, 52, 49, 49); // RGB(52, 49, 49)

    return MultiProvider(
      providers: [
        StreamProvider<CartCount>(
          create: (_) => BadgeProvider.cartItemCountStream(),
          initialData: CartCount(0),
        ),
        StreamProvider<OrderCount>(
          create: (_) => BadgeProvider.activeOrderCountStream(),
          initialData: OrderCount(0),
        ),
        StreamProvider<MessageCount>(
          create: (_) => BadgeProvider.unreadMessagesCountStream(),
          initialData: MessageCount(0),
        ),
        StreamProvider<NotificationCount>(
          create: (_) => BadgeProvider.unreadNotificationCountStream(),
          initialData: NotificationCount(0),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Guser',
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
        home: const AuthScreenRemake(),
      ),
    );
  }
}

