import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/show_floating_toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:delivery_service_user/models/category_item.dart';

class ItemCard extends StatefulWidget {
  final Item item;
  final Stores store;

  const ItemCard({
    Key? key,
    required this.store,
    required this.item,
  }) : super(key: key);

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {

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
                    widget.store,
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

  // Future<void> _addItemToCartFirestore(Stores store, Item itemModel, AddToCartItem addCartItemModel) async {
  //   showFloatingToast(context: context, message: 'Adding item...', bottom: 16, duration: const Duration(seconds: 25));
  //
  //   try {
  //     await _retryTransaction(3, () async {
  //       await FirebaseFirestore.instance.runTransaction((transaction) async {
  //         DocumentReference itemStoreReference = FirebaseFirestore.instance
  //             .collection('stores')
  //             .doc(store.storeID)
  //             .collection('items')
  //             .doc(itemModel.itemID);
  //
  //         DocumentReference storeCartReference = FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(sharedPreferences!.getString('uid'))
  //             .collection('cart')
  //             .doc(store.storeID);
  //
  //         DocumentReference itemCartReference = storeCartReference
  //             .collection('items')
  //             .doc(itemModel.itemID);
  //
  //         DocumentSnapshot itemStoreSnapshot = await transaction.get(itemStoreReference);
  //         DocumentSnapshot itemCartSnapshot = await transaction.get(itemCartReference);
  //
  //         if (!itemStoreSnapshot.exists) {
  //           throw Exception('Item does not exist in the store.');
  //         }
  //
  //         int itemStock = itemStoreSnapshot.get('itemStock') as int;
  //
  //         if (itemStock < addCartItemModel.itemQnty!) {
  //           throw Exception('Not enough stock available in the store.');
  //         }
  //
  //         transaction.update(itemStoreReference, {
  //           'itemStock': itemStock - addCartItemModel.itemQnty!,
  //         });
  //
  //         transaction.set(storeCartReference, store.addStoreToCart(), SetOptions(merge: true));
  //
  //         if (itemCartSnapshot.exists) {
  //           int newItemQnty = addCartItemModel.itemQnty! + (itemCartSnapshot.get('itemQnty') as int);
  //           double newItemTotal = addCartItemModel.itemTotal! + (itemCartSnapshot.get('itemTotal'));
  //
  //           transaction.update(itemCartReference, {
  //             'itemQnty': newItemQnty,
  //             'itemTotal': newItemTotal,
  //           });
  //         } else {
  //           transaction.set(itemCartReference, addCartItemModel.toJson());
  //         }
  //       });
  //     });
  //
  //     Reference oldImageLocation = firebaseStorage.ref(itemModel.itemImagePath);
  //     final String newImagePath = 'users/${sharedPreferences!.getString('uid')}/cart/${store.storeID}/items/${itemModel.itemID}.jpg';
  //     Reference newImageLocation = firebaseStorage.ref(newImagePath);
  //
  //     final Uint8List? fileData = await oldImageLocation.getData();
  //     if (fileData != null) {
  //       String? newImageURL = await _uploadImageWithRetry(fileData, newImageLocation, 3);
  //       if (newImageURL != null) {
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(sharedPreferences!.getString('uid'))
  //             .collection('cart')
  //             .doc(store.storeID)
  //             .collection('items')
  //             .doc(itemModel.itemID)
  //             .update({
  //           'itemImagePath': newImagePath,
  //           'itemImageURL': newImageURL,
  //         });
  //       }
  //     }
  //
  //     showFloatingToast(
  //       context: context,
  //       message: 'Item added to cart successfully!',
  //       backgroundColor: Colors.green,
  //       icon: PhosphorIcons.checkCircle(),
  //       bottom: 16,
  //     );
  //   } catch (e) {
  //     String errorMessage = (e is Exception) ? e.toString().replaceFirst('Exception: ', '') : 'An unexpected error occurred: $e';
  //     Navigator.of(context).pop();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
  //     );
  //   }
  // }

  //TODO: modified _addItemToCartFirestore with Cloud Functions to Upload Image

  Future<void> _addItemToCartFirestore(Stores store, Item itemModel, AddToCartItem addCartItemModel) async {
    showFloatingToast(
      context: context,
      message: 'Adding item to cart...',
      bottom: 16,
      duration: const Duration(minutes: 1),
    );

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. References
        final itemStoreRef = FirebaseFirestore.instance
            .collection('stores')
            .doc(store.storeID)
            .collection('items')
            .doc(itemModel.itemID);

        final storeCartRef = FirebaseFirestore.instance
            .collection('users')
            .doc(sharedPreferences!.getString('uid'))
            .collection('cart')
            .doc(store.storeID);

        final itemCartRef = storeCartRef.collection('items').doc(itemModel.itemID);

        // 2. Get documents in parallel
        final snapshots = await Future.wait([
          transaction.get(itemStoreRef),
          transaction.get(itemCartRef),
        ]);

        // 3. Validate stock
        final itemStoreSnapshot = snapshots[0];
        if (!itemStoreSnapshot.exists) throw Exception('Item does not exist in store');
        final itemStock = itemStoreSnapshot.get('itemStock') as int;
        if (itemStock < addCartItemModel.itemQnty!) throw Exception('Not enough stock available');

        // 4. Update store stock
        transaction.update(itemStoreRef, {
          'itemStock': itemStock - addCartItemModel.itemQnty!,
        });

        // 5. Create/update store cart document with ALL required fields
        transaction.set(storeCartRef, {
          'storeID': store.storeID,
          'storeName': store.storeName,
          'storeAddress': store.storeAddress,
          'storeLocation': store.storeLocation,
          'storePhone': store.storePhone,
          'storeProfileURL': store.storeProfileURL,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 6. Handle cart item
        final itemCartSnapshot = snapshots[1];
        if (itemCartSnapshot.exists) {
          final newQnty = addCartItemModel.itemQnty! + (itemCartSnapshot.get('itemQnty') as int);
          final newTotal = addCartItemModel.itemTotal! + (itemCartSnapshot.get('itemTotal') as double);

          transaction.update(itemCartRef, {
            'itemQnty': newQnty,
            'itemTotal': newTotal,
          });
        } else {
          transaction.set(itemCartRef, {
            ...addCartItemModel.toJson(),
            'originalImagePath': itemModel.itemImagePath,
            'needsImageCopy': true,
            'itemImageURL': itemModel.itemImageURL,
          });
        }
      });

      showFloatingToast(
        context: context,
        message: 'Item added to cart!',
        backgroundColor: Colors.green,
        icon: PhosphorIcons.checkCircle(),
        bottom: 16,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _retryTransaction(int retries, Function transactionFn) async {
    int attempts = 0;
    while (attempts < retries) {
      try {
        await transactionFn();
        return;
      } catch (e) {
        attempts++;
        if (attempts == retries) {
          throw e;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<String?> _uploadImageWithRetry(Uint8List fileData, Reference newImageLocation, int retries) async {
    int attempts = 0;
    while (attempts < retries) {
      try {
        UploadTask uploadTask = newImageLocation.putData(fileData);
        TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      } catch (e) {
        attempts++;
        if (attempts == retries) {
          return null;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _addItemToCartDialog(widget.item);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        child: widget.item.itemImageURL != null
                            ? CachedNetworkImage(
                          imageUrl: widget.item.itemImageURL!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Center(
                              child: Icon(
                                PhosphorIcons.image(PhosphorIconsStyle.fill),
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                              color: Colors.grey,
                              size: 48,
                            ),
                          ),
                        )
                            : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Item name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                widget.item.itemName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Item price and cart icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₱ ${widget.item.itemPrice?.toStringAsFixed(2) ?? ''}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
            // Item stock information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                '${widget.item.itemStock} stock available',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
