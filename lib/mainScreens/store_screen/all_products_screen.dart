import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/item_card.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:shimmer/shimmer.dart';

class AllProductsScreen extends StatefulWidget {
  final Stores store;

  const AllProductsScreen({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  //Item methods
  void _addItemToCartDialog(Item itemModel) {
    TextEditingController qnty = TextEditingController();
    int itemCount = 1;
    qnty.text = itemCount.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Item Image
                    Container(
                      width: 240,
                      height: 250,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: itemModel.itemImageURL != null
                            ? CachedNetworkImage(
                          imageUrl: '${itemModel.itemImageURL}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: const SizedBox(
                              child: Center(
                                child: Icon(Icons.image),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 48,
                            ),
                          ),
                        )
                            : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    // Item Name and Price
                    Text(
                      '${itemModel.itemName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(color: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₱ ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: itemModel.itemPrice!.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quantity Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Subtract button
                        IconButton(
                          onPressed: () {
                            if (itemCount > 1) {
                              setState(() {
                                itemCount--;
                                qnty.text = itemCount.toString();
                              });
                            }
                          },
                          icon: Icon(Icons.remove, color: Theme.of(context).colorScheme.primary),
                        ),
                        // Item field
                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: qnty,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              String filteredValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                              setState(() {
                                // Update itemCount directly based on filteredValue
                                itemCount = filteredValue.isEmpty ? 0 : int.parse(filteredValue);
                                qnty.text = filteredValue; // Ensure the TextField updates with valid digits
                                qnty.selection = TextSelection.fromPosition(
                                  TextPosition(offset: qnty.text.length),
                                );
                              });
                            },
                            onEditingComplete: () {
                              setState(() {
                                // Enforce a valid item count and update the TextField accordingly
                                if (itemCount < 1) {
                                  itemCount = 1;
                                } else if (itemCount > 99) {
                                  itemCount = 99;
                                }
                                qnty.text = itemCount.toString();
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        // Add button
                        IconButton(
                          onPressed: () {
                            if (itemCount < 99) {
                              setState(() {
                                itemCount++;
                                qnty.text = itemCount.toString();
                              });
                            }
                          },
                          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            //Add To Cart button
            ElevatedButton(
              onPressed: () {
                if (itemCount < 1) {
                  setState(() {
                    itemCount = 1;
                    qnty.text = '$itemCount';
                  });

                  // Show a short dialog with 2 seconds delay
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
                    builder: (context) {
                      // Return a simple dialog with a message
                      return const AlertDialog(
                        content: Text('Minimum of 1 item quantity', textAlign: TextAlign.center,),
                      );
                    },
                  );

                  // Close the dialog after 2 seconds
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.of(context).pop(); // Close the dialog
                  });
                } else if (itemCount > 99) {
                  setState(() {
                    itemCount = 99;
                    qnty.text = '$itemCount';
                  });
                  // Show a short dialog with 2 seconds delay
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
                    builder: (context) {
                      // Return a simple dialog with a message
                      return const AlertDialog(
                        content: Text('Maximum of 99 item quantity', textAlign: TextAlign.center,),
                      );
                    },
                  );

                  // Close the dialog after 2 seconds
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.of(context).pop(); // Close the dialog
                  });
                } else {
                  double itemTotal = itemCount * itemModel.itemPrice!;
                  Navigator.of(context).pop();
                  _addItemToCartFirestore(
                    widget.store!,
                    itemModel,
                    AddToCartItem(
                      itemID: itemModel.itemID,
                      itemName: itemModel.itemName,
                      itemImageURL: itemModel.itemImageURL,
                      itemPrice: itemModel.itemPrice,
                      itemQnty: itemCount,
                      itemTotal: itemTotal,
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Add to Cart'),
            )
          ],
        );
      },
    );

  }

  void _addItemToCartFirestore(Stores store, Item itemModel, AddToCartItem addCartItemModel) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Adding item to cart");
      },
    );

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // References
        DocumentReference itemStoreReference = FirebaseFirestore.instance
            .collection('stores')
            .doc(store.storeID)
            .collection('items')
            .doc(itemModel.itemID);

        DocumentReference storeCartReference = FirebaseFirestore.instance
            .collection('users')
            .doc(sharedPreferences!.getString('uid'))
            .collection('cart')
            .doc(store.storeID);

        DocumentReference itemCartReference = storeCartReference
            .collection('items')
            .doc(itemModel.itemID);

        // ** Step 1: Read all required documents first (before any writes) **
        DocumentSnapshot itemStoreSnapshot = await transaction.get(itemStoreReference);
        DocumentSnapshot itemCartSnapshot = await transaction.get(itemCartReference);

        // Check if the item exists in the store
        if (!itemStoreSnapshot.exists) {
          throw Exception('Item does not exist in the store.');
        }

        int itemStock = itemStoreSnapshot.get('itemStock') as int;

        // Check if stock is enough
        if (itemStock < addCartItemModel.itemQnty!) {
          throw Exception('Not enough stock available in the store.');
        }

        // ** Step 2: Now, perform all writes after reading everything **

        // Deduct stock from the store item
        transaction.update(itemStoreReference, {
          'itemStock': itemStock - addCartItemModel.itemQnty!,
        });

        // Ensure store info is added to cart
        transaction.set(storeCartReference, store.addStoreToCart(), SetOptions(merge: true));

        if (itemCartSnapshot.exists) {
          // Update item quantity and total price in cart
          int newItemQnty = addCartItemModel.itemQnty! + itemCartSnapshot.get('itemQnty') as int;
          double newItemTotal = addCartItemModel.itemTotal! + itemCartSnapshot.get('itemTotal');

          transaction.update(itemCartReference, {
            'itemQnty': newItemQnty,
            'itemTotal': newItemTotal,
          });
        } else {
          // Add new item to cart
          transaction.set(itemCartReference, addCartItemModel.toJson());
        }
      });

      // Move image after the transaction completes successfully
      Reference oldImageLocation = firebaseStorage.ref(itemModel.itemImagePath);
      final String newImagePath = 'users/${sharedPreferences!.getString('uid')}/cart/${store.storeID}/items/${itemModel.itemID}.jpg';
      Reference newImageLocation = firebaseStorage.ref(newImagePath);

      final Uint8List? fileData = await oldImageLocation.getData();
      if (fileData != null) {
        UploadTask uploadTask = newImageLocation.putData(fileData);
        TaskSnapshot snapshot = await uploadTask;

        String newImageURL = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(sharedPreferences!.getString('uid'))
            .collection('cart')
            .doc(store.storeID)
            .collection('items')
            .doc(itemModel.itemID)
            .update({
          'itemImagePath': newImagePath,
          'itemImageURL': newImageURL,
        });
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text('Item added to cart successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      String errorMessage;

      // Check if the error is a manually thrown exception
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', ''); // Remove "Exception: " prefix
      } else {
        errorMessage = "An unexpected error occurred: $e";
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("stores")
              .doc(widget.store.storeID)
              .collection('items')
              .snapshots(),
          builder: (context, itemSnapshot) {
            if (!itemSnapshot.hasData) {
              return SliverToBoxAdapter(
                child: Center(child: circularProgress()),
              );
            }

            if (itemSnapshot.data!.docs.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.playlist_remove_outlined,
                      color: Colors.grey,
                      size: 48,
                    ),
                    Text(
                      'No items available',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  mainAxisExtent: 230,
                ),
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    final data = itemSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final item = Item.fromJson(data);

                    // Use the ItemCard widget to display the item.
                    return ItemCard(
                      item: item,
                      onTap: () => _addItemToCartDialog(item),
                    );
                  },
                  childCount: itemSnapshot.data!.docs.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
