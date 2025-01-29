import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/services/count_stock_listener.dart';
import 'package:flutter/material.dart';

class CartScreenWidget extends StatelessWidget {
  final String userID;
  final String storeID;

  CartScreenWidget({required this.userID, required this.storeID});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<AddToCartItem>>(
          future: CountStockListener().getUserCart(userID, storeID),
          builder: (context, cartSnapshot) {
            if (!cartSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            //Using FutureBuilder to get the List<AddToCartItems> from the user's cart
            final itemsFromCart = cartSnapshot.data!;
            //This variable is used to filtered out items from store and user's cart
            final itemIDsFromCart = itemsFromCart.map((item) => item.itemID!).toList();

            return StreamBuilder<QuerySnapshot>(
              stream: firebaseFirestore.collection('stores').doc(storeID).collection('items').snapshots(),
              builder: (context, itemsSnapshot) {
                if (!itemsSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator(),);
                }

                //Filtered Items from Store based on the ItemIDs from the Cart
                final filteredDocs = itemsSnapshot.data!.docs.where((doc) {
                  final itemID = doc['itemID'] as String?;
                  return itemID != null && itemIDsFromCart.contains(itemID);
                }).toList();

                //Convert filtered documents to Item models
                final itemsFromStore = filteredDocs.map((doc) {
                  return Item.fromJson(doc.data() as Map<String, dynamic>);
                }).toList();

                //Creating a map from itemsFromStore, this will be compared to the user's cart items for dynamic display of stocks
                final itemsFromStoreMap = {
                  for (var item in itemsFromStore) item.itemID: item
                };

                return SizedBox(
                  height: 300, // Adjust height as needed
                  child: ListView.builder(
                    itemCount: itemsFromCart.length,
                    itemBuilder: (context, index) {
                      final cartItem = itemsFromCart[index];
                      final storeItem = itemsFromStoreMap[cartItem.itemID];

                      return ListTile(
                        leading: Image.network(cartItem.itemImageURL ?? ''),
                        title: Text(cartItem.itemName ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: ₱${cartItem.itemPrice ?? 0}'),
                            Text('Stock: ${storeItem?.itemStock ?? 0}'),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );

  }
}
