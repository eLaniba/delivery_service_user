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
  bool isLoading = false; // 🔹 Add loading state

  @override
  void initState() {
    super.initState();
    quantity = widget.addToCartItem.itemQnty as int;
  }

  void updateQuantity(bool isIncrement) async {
    final userID = sharedPreferences!.getString('uid');

    final storeRef = firebaseFirestore.collection("stores").doc(widget.storeID);
    final storeItemRef = storeRef.collection("items").doc(widget.addToCartItem.itemID);
    final cartItemRef = firebaseFirestore.collection("users")
        .doc(userID)
        .collection("cart")
        .doc(widget.storeID)
        .collection("items")
        .doc(widget.addToCartItem.itemID);

    setState(() => isLoading = true); // 🔹 Show loading

    try {
      await firebaseFirestore.runTransaction((transaction) async {
        // 🔹 READ: Get latest store stock
        DocumentSnapshot storeItemSnapshot = await transaction.get(storeItemRef);
        if (!storeItemSnapshot.exists) throw Exception("Item no longer available.");

        int currentStock = storeItemSnapshot["itemStock"] ?? 0;
        if (isIncrement && currentStock <= 0) throw Exception("Not enough stock available.");

        // 🔹 READ: Get latest cart item quantity
        DocumentSnapshot cartItemSnapshot = await transaction.get(cartItemRef);
        if (!cartItemSnapshot.exists) throw Exception("Cart item no longer exists.");

        int currentQuantity = cartItemSnapshot["itemQnty"] ?? 0;
        int newQuantity = isIncrement ? currentQuantity + 1 : currentQuantity - 1;
        if (newQuantity < 1) throw Exception("Minimum quantity reached.");

        final double newTotal = widget.addToCartItem.itemPrice! * newQuantity;

        // 🔹 WRITE: Adjust stock
        transaction.update(storeItemRef, {
          "itemStock": FieldValue.increment(isIncrement ? -1 : 1),
        });

        // 🔹 WRITE: Update cart
        transaction.update(cartItemRef, {
          "itemQnty": newQuantity,
          "itemTotal": newTotal,
        });

        // 🔹 Update UI state with new quantity
        quantity = newQuantity;
      });

      if (mounted) {
        setState(() => isLoading = false); // 🔹 Hide loading
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false); // 🔹 Hide loading on error
      }

      print("Error updating quantity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update item: ${e.toString()}"),
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
          onTap: () => updateQuantity(false),
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
        // Text with Loading Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 22,
            height: 22,
            child: isLoading
                ? const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Add
        GestureDetector(
          onTap: () => updateQuantity(true),
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
