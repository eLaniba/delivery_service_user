import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/checkout_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_item_quantity_changer.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/item_quantity_changer.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class ModifyOrderCartScreen extends StatefulWidget {
  AddToCartStoreInfo addToCartStoreInfo;
  final void Function(int) onChangePage;

  ModifyOrderCartScreen({
    super.key,
    required this.addToCartStoreInfo,
    required this.onChangePage,
  });

  @override
  State<ModifyOrderCartScreen> createState() => _ModifyOrderCartScreenState();
}

class _ModifyOrderCartScreenState extends State<ModifyOrderCartScreen> {
  List<AddToCartItem> listAddToCartItem = [];
  Set<String> processedItemIDs = Set();

  Future<void> deleteItem(AddToCartItem item) async {
    showDialog(
      context: context,
      builder: (c) => const LoadingDialog(message: "Deleting item"),
    );

    try {
      // 1. Delete the image (if it exists in user's storage)
      try {
        if (item.itemImagePath != null &&
            item.itemImagePath!.contains('users/')) {
          await firebaseStorage.ref(item.itemImagePath).delete();
        }
      } catch (e) {
        debugPrint("Image deletion skipped (might be using store's original image)");
      }

      // 2. Restore stock to store
      DocumentReference itemFromStore = firebaseFirestore
          .collection('stores')
          .doc(widget.addToCartStoreInfo.storeID)
          .collection('items')
          .doc(item.itemID);

      DocumentSnapshot itemSnapshot = await itemFromStore.get();
      if (itemSnapshot.exists) {
        await itemFromStore.update({
          'itemStock': FieldValue.increment(item.itemQnty!),
        });
      }

      // 3. Delete the cart item document
      await firebaseFirestore
          .collection("users")
          .doc(sharedPreferences!.getString('uid'))
          .collection("cart_modify")
          .doc(widget.addToCartStoreInfo.storeID)
          .collection("items")
          .doc(item.itemID)
          .delete();

      if (mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = sharedPreferences!.getString('uid');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart_modify')
          .doc(widget.addToCartStoreInfo.storeID)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final itemDocs = snapshot.data?.docs ?? [];

        // IF EMPTY
        if (itemDocs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Cart'),
              foregroundColor: Colors.grey,
              actions: [
                IconButton(
                  onPressed: () => widget.onChangePage.call(0),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:  [
                  Icon(PhosphorIcons.empty(PhosphorIconsStyle.regular), size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Your cart is empty', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        // IF NOT EMPTY
        listAddToCartItem.clear();
        processedItemIDs.clear();

        for (var doc in itemDocs) {
          final item = AddToCartItem.fromJson(doc.data()! as Map<String, dynamic>);
          if (!processedItemIDs.contains(item.itemID)) {
            listAddToCartItem.add(item);
            processedItemIDs.add(item.itemID!);
          }
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Cart'),
            foregroundColor: Colors.grey,
            actions: [
              IconButton(
                onPressed: () => widget.onChangePage.call(0),
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 8),
            ],
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 4),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final item = listAddToCartItem[index];
                      return Slidable(
                        key: ValueKey(item.itemID),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                final confirm = await ConfirmationDialog.show(
                                  context,
                                  'Are you sure you want to delete this item?',
                                );
                                if (confirm == true) {
                                  deleteItem(item);
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Item Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item.itemImageURL != null
                                      ? CachedNetworkImage(
                                    imageUrl: item.itemImageURL!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: const SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Center(child: Icon(Icons.image)),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
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
                                    child: const Icon(Icons.image_outlined, color: Color.fromARGB(255, 215, 219, 221)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Item Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.itemName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('₱ ${item.itemPrice?.toStringAsFixed(2) ?? '0.00'}'),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text(
                                            '₱${item.itemTotal?.toStringAsFixed(2) ?? '0.00'}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: ModifyOrderItemQuantityChanger(
                                    storeID: widget.addToCartStoreInfo.storeID!,
                                    addToCartItem: item,
                                    onQuantityChanged: (q) => print('Updated: $q'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: listAddToCartItem.length,
                  ),
                ),
              ),
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
                onPressed: () {
                  widget.onChangePage.call(2);
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
      },
    );
  }

}
