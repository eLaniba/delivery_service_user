import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:flutter/material.dart';

class ItemQuantityChanger extends StatefulWidget {
  final String storeID;
  final AddToCartItem addToCartItem;
  final ValueChanged<int> onQuantityChanged;

  const ItemQuantityChanger({
    required this.storeID,
    required this.onQuantityChanged,
    required this.addToCartItem,
    super.key,
  });

  @override
  _ItemQuantityChangerState createState() => _ItemQuantityChangerState();
}

class _ItemQuantityChangerState extends State<ItemQuantityChanger> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.addToCartItem.itemQnty as int;
  }

  // void increment() async {
  //   if (quantity < 99) {
  //     // setState(() {
  //     // });
  //     // widget.onQuantityChanged(quantity);
  //     quantity++;
  //     final double itemTotal = widget.addToCartItem.itemPrice! * quantity;
  //
  //     print('Running doc');
  //     DocumentReference docRef = firebaseFirestore
  //         .collection("users")
  //         .doc(sharedPreferences!.getString('uid'))
  //         .collection("cart")
  //         .doc(widget.storeID)
  //         .collection("items")
  //         .doc(widget.addToCartItem.itemID);
  //
  //     await docRef.update({
  //       "itemQnty": quantity,
  //       "itemTotal": itemTotal,
  //     });
  //   }
  // }
  void increment() async {
    final userID = sharedPreferences!.getString('uid');

    final storeRef = firebaseFirestore.collection("stores").doc(widget.storeID);
    final storeItemRef = storeRef.collection("items").doc(widget.addToCartItem.itemID);
    final cartItemRef = firebaseFirestore.collection("users")
        .doc(userID)
        .collection("cart")
        .doc(widget.storeID)
        .collection("items")
        .doc(widget.addToCartItem.itemID);

    try {
      await firebaseFirestore.runTransaction((transaction) async {
        // 🔹 READ: Get latest store stock
        DocumentSnapshot storeItemSnapshot = await transaction.get(storeItemRef);
        if (!storeItemSnapshot.exists) throw Exception("Item no longer available.");

        int currentStock = storeItemSnapshot["itemStock"] ?? 0;
        if (currentStock <= 0) throw Exception("Not enough stock available.");

        // 🔹 READ: Get latest quantity from Firestore (Fixes stale data issue!)
        DocumentSnapshot cartItemSnapshot = await transaction.get(cartItemRef);
        if (!cartItemSnapshot.exists) throw Exception("Cart item no longer exists.");

        int currentQuantity = cartItemSnapshot["itemQnty"] ?? 0;  // ✅ Get real-time latest quantity
        int newQuantity = currentQuantity + 1;  // ✅ Use the latest quantity, not stale data!
        final double newTotal = widget.addToCartItem.itemPrice! * newQuantity;

        if (newQuantity > currentStock) throw Exception("Cannot add more than available stock.");

        // 🔹 WRITE: Deduct 1 from the store's stock
        transaction.update(storeItemRef, {"itemStock": FieldValue.increment(-1)});

        // 🔹 WRITE: Update cart with latest quantity
        transaction.update(cartItemRef, {
          "itemQnty": newQuantity,
          "itemTotal": newTotal,
        });
      });

      // ✅ Force rebuild so UI updates instantly
      if (mounted) {
        setState(() {});
      }

    } catch (e) {
      print("Error updating quantity: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add item: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void decrement() async {
    final userID = sharedPreferences!.getString('uid');

    final storeRef = firebaseFirestore.collection("stores").doc(widget.storeID);
    final storeItemRef = storeRef.collection("items").doc(widget.addToCartItem.itemID);
    final cartItemRef = firebaseFirestore.collection("users")
        .doc(userID)
        .collection("cart")
        .doc(widget.storeID)
        .collection("items")
        .doc(widget.addToCartItem.itemID);

    try {
      await firebaseFirestore.runTransaction((transaction) async {
        // 🔹 READ: Get latest cart item quantity
        DocumentSnapshot cartItemSnapshot = await transaction.get(cartItemRef);
        if (!cartItemSnapshot.exists) throw Exception("Cart item no longer exists.");

        int currentQuantity = cartItemSnapshot["itemQnty"] ?? 0;
        if (currentQuantity <= 1) throw Exception("Minimum quantity reached."); // 🚨 Prevents going below 1

        // 🔹 READ: Get latest store stock
        DocumentSnapshot storeItemSnapshot = await transaction.get(storeItemRef);
        if (!storeItemSnapshot.exists) throw Exception("Item no longer available.");

        int currentStock = storeItemSnapshot["itemStock"] ?? 0;

        // 🔹 Calculate new values
        int newQuantity = currentQuantity - 1;
        final double newTotal = widget.addToCartItem.itemPrice! * newQuantity;

        // 🔹 WRITE: Increase the store's stock (return 1 item back)
        transaction.update(storeItemRef, {"itemStock": FieldValue.increment(1)});

        // 🔹 WRITE: Update cart with latest quantity
        transaction.update(cartItemRef, {
          "itemQnty": newQuantity,
          "itemTotal": newTotal,
        });
      });

      // ✅ Force rebuild so UI updates instantly
      if (mounted) {
        setState(() {});
      }

    } catch (e) {
      print("Error decrementing quantity: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to remove item: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Subtract
        GestureDetector(
          onTap: decrement,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.remove, size: 16),
          ),
        ),
        // Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 22,
            child: Text(
              '${widget.addToCartItem.itemQnty}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Add
        GestureDetector(
          onTap: increment,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.add, size: 16),
          ),
        ),
      ],
    );
  }
}
