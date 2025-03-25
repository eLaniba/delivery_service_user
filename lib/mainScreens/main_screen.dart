import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/cart_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/order_history_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/order_screen.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/messages_screen.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/messages_screen_provider.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/profile_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_screen_remake.dart';
import 'package:delivery_service_user/mainScreens/store_screen/search_screen.dart';
import 'package:delivery_service_user/services/providers/badge_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int widgetIndex = 0;

  final List<Widget> _screens = [
    const StoreScreenRemake(),
    const OrderScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartCount>().count;
    final orderCount = context.watch<OrderCount>().count;
    final messageCount = context.watch<MessageCount>().count;
    final notificationCount = context.watch<NotificationCount>().count;

    return Scaffold(
      appBar: AppBar(
        title: widgetIndex == 2 ? const Text('Your profile') :
          widgetIndex == 0 ? GestureDetector(
          onTap: () {
            // Navigate to another page (SearchScreen) when the search bar is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen(searchQuery: 'store',)), // Your search screen
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
        actions: [
          //Cart
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()), // Your search screen
                  );
                },
                icon: Icon(PhosphorIcons.shoppingCart()),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartCount < 99 ? '$cartCount' : '99',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          //Notification
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()), // Your search screen
                  );
                },
                icon: Icon(PhosphorIcons.bell()),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 6,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount < 99 ? '$notificationCount' : '99',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          //Messages
          if(widgetIndex == 2)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MessagesScreenProvider()), // Your search screen
                    );
                  },
                  icon: Icon(PhosphorIcons.chatText()),
                ),
                if (messageCount > 0)
                  Positioned(
                    right: 6,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        messageCount < 99 ? '$messageCount' : '99',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[200],
      body: _screens[widgetIndex],
      floatingActionButton: widgetIndex == 1
          ? FloatingActionButton.extended(
              icon: PhosphorIcon(PhosphorIcons.boxArrowDown()),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
              },
              label: const Text('Order History'),
              backgroundColor: darkGrey,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            widgetIndex = index;
          });
        },
        currentIndex: widgetIndex,
        items: [
          BottomNavigationBarItem(
            icon: widgetIndex == 0
                ? Icon(PhosphorIcons.storefront(PhosphorIconsStyle.fill))
                : Icon(PhosphorIcons.storefront(PhosphorIconsStyle.regular)),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                widgetIndex == 1
                    ? Icon(PhosphorIcons.package(PhosphorIconsStyle.fill))
                    : Icon(PhosphorIcons.package(PhosphorIconsStyle.regular)),

                if (orderCount > 0)
                  Positioned(
                    left: 16,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(cartCount < 99 ? '$orderCount' : '99',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: widgetIndex == 2
                ? Icon(PhosphorIcons.user(PhosphorIconsStyle.fill))
                : Icon(PhosphorIcons.user(PhosphorIconsStyle.regular)),
            label: 'Profile',
          ),

        ],
      ),
    );
  }
}
