import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/cart_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/order_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_screen_remake.dart';
import 'package:delivery_service_user/services/count_cart_listener.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int widgetIndex = 0;

  final List<Widget> _screens = [
    const ProfileScreen(),
    const StoreScreenRemake(),
    const OrderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widgetIndex == 0 ? const Text('Your profile') :
          widgetIndex == 1 ? GestureDetector(
          onTap: () {
            // Navigate to another page (SearchScreen) when the search bar is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Scaffold(body: Placeholder(child: Text('hello'),),)), // Your search screen
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Search store...',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          ),
        ) :
          const Text('Orders'),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: widgetIndex != 0
            ? [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('${sharedPreferences!.get('uid')}')
                .collection('cart')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartScreen()), // Your search screen
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),
                      Positioned(
                        right: 10,
                        top: 5,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (c) => const CartScreen()));
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ]
            : null,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[200],
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
