import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/checkout_screen.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/widgets/cart_screen_widget.dart';
import 'package:delivery_service_user/widgets/cart_screen_widget_reverse.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/item_quantity_changer.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen2 extends StatefulWidget {
  CartScreen2({
    super.key,
    this.addToCartStoreInfo,
  });

  AddToCartStoreInfo? addToCartStoreInfo;

  @override
  State<CartScreen2> createState() => _CartScreen2State();
}

class _CartScreen2State extends State<CartScreen2> {
  List<AddToCartItem> listAddToCartItem = [];
  Set<String> processedItemIDs = Set();
  double totalOrderPrice = 0;

  double calculateOrderTotal(List<AddToCartItem>? items) {
    double total = 0;

    for (var item in items!) {
      total += item.itemTotal!;
    }
    return total;
  }

  Future<void> deleteItem(AddToCartItem item) async {
    showDialog(
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Deleting item");
      },
    );

    try {
      print('LOCATION - users/${sharedPreferences!.getString('uid')}/cart/${widget.addToCartStoreInfo!.storeID}/items/${item.itemID}');
      //Deleting the item image from the Firebase Cloud Storage
      // final imageRef = firebaseStorage.ref(item.itemImagePath);
      // await imageRef.delete();

      //Retrieve back the itemQnty from Cart to Store
      DocumentReference itemFromStore = firebaseFirestore.collection('stores').doc(widget.addToCartStoreInfo!.storeID).collection('items').doc(item.itemID);

      //Check if item exist in the Store items collection
      DocumentSnapshot itemSnapshot = await itemFromStore.get();
      if(itemSnapshot.exists) {
          await itemFromStore.update({
            //Can you help me get the itemQnty inside the itemSnapshot document?
            'itemStock': FieldValue.increment(item.itemQnty!),
          });
      } else {
        print("Item not found in store, skipping stock restoration.");
      }

      //Deleting item document after deleting the image
      await firebaseFirestore
          .collection("users")
          .doc(sharedPreferences!.getString('uid'))
          .collection("cart")
          .doc(widget.addToCartStoreInfo!.storeID)
          .collection("items")
          .doc(item.itemID)
          .delete();
      if(mounted) {
        Navigator.of(context).pop();
      }

      // Show a success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item deleted.'),
          backgroundColor: Colors.black.withOpacity(0.8),
          duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
        ),
      );

    } catch (e) {
      print("Error deleting item: $e");

      // Show an error Snackbar if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete item: $e'),
          backgroundColor: Colors.red, // Optional: Set background color for error
          duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
        ),
      );
    }

  }

  void updateQuantity() {

  }

  @override
  void initState() {
    super.initState();
    totalOrderPrice = calculateOrderTotal(listAddToCartItem);
    print(totalOrderPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.addToCartStoreInfo!.storeName}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: white80,
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('${sharedPreferences!.getString('uid')}')
                .collection('cart')
                .doc(widget.addToCartStoreInfo!.storeID)
                .collection('items')
                .snapshots(),
            builder: (context, itemSnapshot) {
              if (!itemSnapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Center(child: circularProgress()),
                );
              } else if (itemSnapshot.hasError) {
                return Center(child: Text('Error: ${itemSnapshot.error}'));
              } else if (itemSnapshot.hasData && itemSnapshot.data!.docs.isNotEmpty) {
                //Clear list for rebuild
                listAddToCartItem.clear();
                processedItemIDs.clear();

                return SliverPadding(
                  padding: const EdgeInsets.only(top: 4),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      AddToCartItem sAddToCartItem = AddToCartItem.fromJson(itemSnapshot.data!.docs[index].data()! as Map<String, dynamic>,);

                      // Check if the item has already been processed
                      if (!processedItemIDs.contains(sAddToCartItem.itemID)) {
                        // Add item to the list and track its ID
                        listAddToCartItem.add(sAddToCartItem);
                        processedItemIDs.add(sAddToCartItem.itemID!);
                        print('List added: ${sAddToCartItem.itemID}');
                      }

                      return Slidable(
                        key: ValueKey(sAddToCartItem.itemID),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                bool? confirm = await ConfirmationDialog.show(
                                  context,
                                  'Are you sure you want to delete this item?',
                                );
                                if(confirm!) {
                                  deleteItem(sAddToCartItem);
                                }
                              },
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                              icon: PhosphorIcons.trash(PhosphorIconsStyle.regular),
                              label: 'Delete',
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Softer, rounded corners
                          ),
                          margin: const EdgeInsets.only(top: 4, right: 8, left: 8, bottom: 4),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                // Leading image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: sAddToCartItem.itemImageURL != null
                                      ? CachedNetworkImage(
                                    imageUrl: '${sAddToCartItem.itemImageURL}',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    fadeInDuration: Duration.zero,
                                    fadeOutDuration: Duration.zero,
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Center(
                                          child: Icon(
                                            PhosphorIcons.image(PhosphorIconsStyle.fill),
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  )
                                      : Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(255, 215, 219, 221),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: Color.fromARGB(255, 215, 219, 221),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Title, subtitle, and price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${sAddToCartItem.itemName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text('₱ ${sAddToCartItem.itemPrice!.toStringAsFixed(2)}'),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text(
                                            'Total: ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '₱${sAddToCartItem.itemTotal!.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Trailing quantity changer
                                SizedBox(
                                  width: 120, // Adjust based on your design needs
                                  child: ItemQuantityChanger(
                                    storeID: widget.addToCartStoreInfo!.storeID.toString(),
                                    addToCartItem: sAddToCartItem,
                                    onQuantityChanged: (newQnty) {
                                      print('Updated quantity: $newQnty');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: itemSnapshot.data!.docs.length),
                  ),
                );
              } else if (itemSnapshot.hasData && itemSnapshot.data!.docs.isEmpty) {
                //Delete the store cart document and navigate back
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  try{
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc('${sharedPreferences!.getString('uid')}')
                        .collection('cart')
                        .doc(widget.addToCartStoreInfo!.storeID)
                        .delete();

                    //Pop out of the current screen
                    Navigator.pop(context);
                  } catch(e) {
                    // Handle errors gracefully
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error clearing cart: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              }
              return const SliverToBoxAdapter();
            },
          ),
          // SliverToBoxAdapter(
          //   child: CartScreenWidget(userID: sharedPreferences!.getString('uid')!, storeID: widget.addToCartStoreInfo!.storeID!,),
          // ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => CheckOutScreen(
                    addToCartStoreInfo: widget.addToCartStoreInfo,
                    items: listAddToCartItem,
                  ),
                ),
              );
            },
            child: const Text(
              'Checkout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
