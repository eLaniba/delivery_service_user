import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_cart_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_checkout_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_search_products.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ModifyOrderMain extends StatefulWidget {
  int minutes;
  String storeID;
  String orderID;

  ModifyOrderMain({required this.minutes, required this.storeID, required this.orderID, super.key});

  @override
  State<ModifyOrderMain> createState() => _ModifyOrderMainState();
}

class _ModifyOrderMainState extends State<ModifyOrderMain> {
  late int _remainingSeconds;
  late Timer _timer;
  Stores? store;
  AddToCartStoreInfo? addToCartStore;
  late List<Widget> pages;

  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    fetchStoreData();
  }

  void _startTimer() {
    _remainingSeconds = widget.minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final minStr = minutes.toString().padLeft(1, '0');
    final secStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  void fetchStoreData() async {
    DocumentSnapshot doc = await firebaseFirestore.collection("stores").doc(widget.storeID).get();
    if (doc.exists) {
      setState(() {
        store = Stores.fromJson(doc.data() as Map<String, dynamic>);
        addToCartStore = AddToCartStoreInfo(
          storeID: store!.storeID,
          storeName: store!.storeName,
          storeAddress: store!.storeAddress,
          storePhone: store!.storePhone,
          storeProfileURL: store!.storeProfileURL,
          storeLocation: store!.storeLocation,
        );

        pages = [
          ModifyOrderSearchProducts(
            searchQuery: 'items',
            store: store!,
            onChangePage: changePage,
          ),
          ModifyOrderCartScreen(
            addToCartStoreInfo: addToCartStore!,
            onChangePage: changePage,
          ),
          ModifyOrderCheckOutScreen(
            addToCartStoreInfo: addToCartStore!,
            orderID: widget.orderID,
            onChangePage: changePage,
          ),
        ];
      });
    }
  }

  void changePage(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(store == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Time: '),
            Text(_formatTime(_remainingSeconds)), // Live timer here
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                changePage(1);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    (PhosphorIcons.shoppingCart()),
                  ),
                  Positioned(
                    right: -4,
                    top: -12,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(sharedPreferences!.getString('uid'))
                          .collection('cart_modify')
                          .doc(widget.storeID)
                          .collection('items')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const SizedBox();
                        }
                        int itemCount = snapshot.data!.docs.length;
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

      ),
      body: IndexedStack(
        index: _currentPageIndex,
        children: pages,
      ),
    );
  }
}
