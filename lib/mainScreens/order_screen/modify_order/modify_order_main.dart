import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_all_products.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_search_products.dart';
import 'package:delivery_service_user/mainScreens/store_screen/search_screen.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ModifyOrderMain extends StatefulWidget {
  int minutes;
  String storeID;

  ModifyOrderMain({required this.minutes, required this.storeID, super.key});

  @override
  State<ModifyOrderMain> createState() => _ModifyOrderMainState();
}

class _ModifyOrderMainState extends State<ModifyOrderMain> {
  late int _remainingSeconds;
  late Timer _timer;
  Stores? store;

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
      });
    }
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
          IconButton(
            onPressed: () {},
            icon: Icon(PhosphorIcons.shoppingCart()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ModifyOrderAllProducts(store: store!),
    );
  }
}
