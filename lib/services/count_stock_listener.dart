import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/category_item.dart';

class CountStockListener {
  Future<List<AddToCartItem>> getUserCart(String userID, String storeID) async {
    final cartItemsRef = firebaseFirestore
        .collection('users')
        .doc(userID)
        .collection('cart')
        .doc(storeID)
        .collection('items');

    final List<AddToCartItem> items = [];

    final snapshot = await cartItemsRef.get();
    for(var doc in snapshot.docs) {
      final AddToCartItem item = AddToCartItem.fromJson(doc.data());
      items.add(item);
    }

    return items;
  }

  Future<Map<String, int>> getCurrentStock(List<String> itemIDs, String storeID) async {
    final itemsRef = firebaseFirestore.collection('stores')
        .doc(storeID)
        .collection('items');

    final stockMap = <String, int> {};

    final snapshot = await itemsRef.where(FieldPath.documentId, whereIn: itemIDs).get();
    for (var doc in snapshot.docs) {
      final item = Item.fromJson(doc.data());
      stockMap[item.itemID!] = item.itemStock ?? 0;
    }

    return stockMap;
  }

}