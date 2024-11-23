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

  void increment() async {
    if (quantity < 99) {
      // setState(() {
      // });
      // widget.onQuantityChanged(quantity);
      quantity++;
      final double itemTotal = widget.addToCartItem.itemPrice! * quantity;

      print('Running doc');
      DocumentReference docRef = firebaseFirestore
          .collection("users")
          .doc(sharedPreferences!.getString('uid'))
          .collection("cart")
          .doc(widget.storeID)
          .collection("items")
          .doc(widget.addToCartItem.itemID);

      await docRef.update({
        "itemQnty": quantity,
        "itemTotal": itemTotal,
      });
    }
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
      widget.onQuantityChanged(quantity);
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
