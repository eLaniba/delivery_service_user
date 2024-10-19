import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen.dart';
import 'package:delivery_service_user/services/count_cart_listener.dart';
import 'package:flutter/material.dart';

import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int widgetIndex = 0;

  final List<Widget> _screens = [
    ProfileScreen(),
    StoreScreen(),
    OrderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Sample"),
        actions: (widgetIndex == 1) ? [
        IconButton(
          onPressed: () async {
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreItemScreen(sellerModel: widget.model,categoryModel: sCategory,)));
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartScreen()));

          },
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
        ] : null,
      ),
      body: _screens[widgetIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            widgetIndex = index;
          });
        },
        currentIndex: widgetIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Orders',
          ),

        ],
      ),
    );
  }
}
