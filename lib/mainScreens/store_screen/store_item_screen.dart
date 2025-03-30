import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/cart_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/search_screen.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:delivery_service_user/widgets/item_dialog.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:delivery_service_user/widgets/show_floating_toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class StoreItemScreen extends StatefulWidget {
  StoreItemScreen({super.key, this.store, this.categoryModel});

  Stores? store;
  Category? categoryModel;

  @override
  State<StoreItemScreen> createState() => _StoreItemScreenState();
}

class _StoreItemScreenState extends State<StoreItemScreen> {

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

  Future<void> _addItemToCartFirestore(Stores store, Item itemModel, AddToCartItem addCartItemModel) async {
    showFloatingToast(context: context, message: 'Adding item...', bottom: 16, duration: const Duration(seconds: 25));

    try {
      await _retryTransaction(3, () async {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
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

          DocumentSnapshot itemStoreSnapshot = await transaction.get(itemStoreReference);
          DocumentSnapshot itemCartSnapshot = await transaction.get(itemCartReference);

          if (!itemStoreSnapshot.exists) {
            throw Exception('Item does not exist in the store.');
          }

          int itemStock = itemStoreSnapshot.get('itemStock') as int;

          if (itemStock < addCartItemModel.itemQnty!) {
            throw Exception('Not enough stock available in the store.');
          }

          transaction.update(itemStoreReference, {
            'itemStock': itemStock - addCartItemModel.itemQnty!,
          });

          transaction.set(storeCartReference, store.addStoreToCart(), SetOptions(merge: true));

          if (itemCartSnapshot.exists) {
            int newItemQnty = addCartItemModel.itemQnty! + (itemCartSnapshot.get('itemQnty') as int);
            double newItemTotal = addCartItemModel.itemTotal! + (itemCartSnapshot.get('itemTotal'));

            transaction.update(itemCartReference, {
              'itemQnty': newItemQnty,
              'itemTotal': newItemTotal,
            });
          } else {
            transaction.set(itemCartReference, addCartItemModel.toJson());
          }
        });
      });

      Reference oldImageLocation = firebaseStorage.ref(itemModel.itemImagePath);
      final String newImagePath = 'users/${sharedPreferences!.getString('uid')}/cart/${store.storeID}/items/${itemModel.itemID}.jpg';
      Reference newImageLocation = firebaseStorage.ref(newImagePath);

      final Uint8List? fileData = await oldImageLocation.getData();
      if (fileData != null) {
        String? newImageURL = await _uploadImageWithRetry(fileData, newImageLocation, 3);
        if (newImageURL != null) {
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
      }

      showFloatingToast(
        context: context,
        message: 'Item added to cart successfully!',
        backgroundColor: Colors.green,
        icon: PhosphorIcons.checkCircle(),
        bottom: 16,
      );
    } catch (e) {
      String errorMessage = (e is Exception) ? e.toString().replaceFirst('Exception: ', '') : 'An unexpected error occurred: $e';
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
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
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate to another page (SearchScreen) when the search bar is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  searchQuery: 'items',
                  store: widget.store,
                  category: widget.categoryModel,
                ),
              ), // Your search screen
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search ${widget.categoryModel!.categoryName!.toLowerCase()}...',
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('${sharedPreferences!.get('uid')}')
                .collection('cart')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartScreen()), // Your search screen
                          );
                        },
                        icon: Icon(PhosphorIcons.shoppingCart()),
                      ),
                      Positioned(
                        right: 10,
                        top: 5,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (c) => const CartScreen()));
                        },
                        icon: Icon(PhosphorIcons.shoppingCart()),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // StreamBuilder<int>(
          //   stream: countAllItems('${sharedPreferences!.get('uid')}'),
          //   builder: (context, snapshot) {
          //     if(!snapshot.hasData) {
          //       return const Padding(
          //         padding: EdgeInsets.only(right: 40,),
          //         child: SizedBox(
          //           width: 16,
          //           height: 16,
          //           child: CircularProgressIndicator(),
          //         ),
          //       );
          //     }
          //
          //     //other code
          //     int itemCount = snapshot.data ?? 0;
          //
          //     return Padding(
          //       padding: const EdgeInsets.only(right: 24),
          //       child: Stack(
          //         children: [
          //           IconButton(
          //             onPressed: () {
          //               Navigator.push(context, MaterialPageRoute(builder: (c) => const CartScreen()));
          //             },
          //             icon: const Icon(Icons.shopping_cart_outlined),
          //           ),
          //           if(itemCount > 0)
          //             Positioned(
          //               right: 0,
          //               top: 0,
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   color: Colors.red,
          //                   borderRadius: BorderRadius.circular(2),
          //                 ),
          //                 constraints: const BoxConstraints(
          //                   minWidth: 16,
          //                   minHeight: 16,
          //                 ),
          //                 child: Text(
          //                   '$itemCount',
          //                   style: const TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 16,
          //                   ),
          //                   textAlign: TextAlign.center,
          //                 ),
          //               ),
          //             ),
          //               ],
          //       ),
          //     );
          //   },
          //
          // ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 30,
              maxHeight: 30,
              child: Container(
                color: Theme.of(context).colorScheme.inversePrimary,
                child: Center(
                  child: Text(
                    '${widget.categoryModel!.categoryName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("stores")
                .doc(widget.store!.storeID)
                .collection('items')
                .where('categoryID', isEqualTo: widget.categoryModel!.categoryID)
                .snapshots(),
            builder: (context, itemSnapshot) {
              if (!itemSnapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Center(child: circularProgress(),),
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
                    mainAxisExtent: 230
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      //code here
                      Item item = Item.fromJson(
                        itemSnapshot.data!.docs[index].data()! as Map<String, dynamic>
                      );

                      //Return a widget similar to how shoppe display their items
                      return Card(
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _addItemToCartDialog(item);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Item image
                              Expanded(
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        height: 180,
                                        width: double.infinity,
                                        // margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                          child: item.itemImageURL != null
                                              ? CachedNetworkImage(
                                            imageUrl: '${item.itemImageURL}',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Center(
                                                child: Icon(
                                                  PhosphorIcons.image(
                                                      PhosphorIconsStyle.fill),
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    PhosphorIcons.imageBroken(
                                                        PhosphorIconsStyle.fill),
                                                    color: Colors.grey,
                                                    size: 48,
                                                  ),
                                                ),
                                          )
                                              : Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              PhosphorIcons.imageBroken(
                                                  PhosphorIconsStyle.fill),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Labels
                                    // Positioned(
                                    //   top: 8,
                                    //   right: 8,
                                    //   child: Container(
                                    //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.redAccent,
                                    //       borderRadius: BorderRadius.circular(4),
                                    //     ),
                                    //     child: const Text(
                                    //       'SALE',
                                    //       style: TextStyle(
                                    //         color: Colors.white,
                                    //         fontSize: 10,
                                    //         fontWeight: FontWeight.bold,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              //Item name
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  '${item.itemName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              //Item price and cart icon
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₱ ${item.itemPrice!.toStringAsFixed(2)}',
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
                              //Item stock
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  '${item.itemStock} stock available',
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

                    },
                    childCount: itemSnapshot.data!.docs.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'End of results.',
                  style: TextStyle(
                    color: gray,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
