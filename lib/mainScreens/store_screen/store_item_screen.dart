import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/cart_screen.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:delivery_service_user/widgets/item_dialog.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
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

    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       shape: const RoundedRectangleBorder(
    //         borderRadius: BorderRadius.zero,
    //       ),
    //       content: StatefulBuilder(
    //         builder: (context, setState) {
    //           return Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               SizedBox(
    //                 height: 100,
    //                 width: 100,
    //                 child: Container(
    //                   decoration: BoxDecoration(
    //                     border: Border.all(
    //                       color: Colors.grey,
    //                       width: 2,
    //                     ),
    //                   ),
    //                   child: const Center(
    //                     child: Icon(
    //                       Icons.image,
    //                       color: Colors.grey,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               const Padding(
    //                 padding: EdgeInsets.only(top: 8),
    //                 child: Divider(
    //                   color: Colors.grey,
    //                 ),
    //               ),
    //               Padding(
    //                 padding: const EdgeInsets.all(4),
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.center,
    //                   children: [
    //                     Text(
    //                       '${itemModel.itemName}',
    //                       maxLines: 3,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                     const SizedBox(height: 5,),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Flexible(
    //                           child: RichText(
    //                             text: TextSpan(
    //                               children: [
    //                                 TextSpan(
    //                                   text: '₱ ',
    //                                   style: TextStyle(
    //                                     fontSize: 20,
    //                                     fontWeight: FontWeight.bold,
    //                                     color: Theme.of(context).colorScheme.primary,
    //                                   ),
    //                                 ),
    //                                 TextSpan(
    //                                   text: '${itemModel.itemPrice}',
    //                                   style: TextStyle(
    //                                     fontSize: 16,
    //                                     fontWeight: FontWeight.bold,
    //                                     color: Theme.of(context).colorScheme.primary,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                             overflow: TextOverflow.ellipsis,
    //                             maxLines: 3,
    //                           ),
    //                         ),
    //                         Row(
    //                           children: [
    //                             IconButton(
    //                               onPressed: () {
    //                                 if (itemCount > 1) {
    //                                   setState(() {
    //                                     itemCount--;
    //                                   });
    //                                 }
    //                               },
    //                               icon: const Icon(Icons.remove),
    //                             ),
    //                             SizedBox(
    //                               width: 30,
    //                               child: TextField(
    //                                 controller: TextEditingController(text: itemCount.toString()),
    //                                 keyboardType: TextInputType.number,
    //                                 textAlign: TextAlign.center,
    //                                 onChanged: (value) {
    //                                   if (value.isEmpty) {
    //                                     itemCount = 0;
    //                                     return ;
    //                                   }
    //                                   if (int.tryParse(value) == null || int.tryParse(value) == 0) {
    //                                     itemCount = 1;
    //                                     setState(() {
    //                                       showDialog(
    //                                         context: context,
    //                                         builder: (c) {
    //                                           return const ErrorDialog(message: 'Quantity must be a whole number(ex: 1, 2, ...)');
    //                                         },
    //                                       );
    //                                     });
    //                                   } else {
    //                                     itemCount = int.parse(value);
    //                                   }
    //                                 },
    //                               ),
    //                             ),
    //                             IconButton(
    //                               onPressed: () {
    //                                 if (itemCount == 1) {
    //                                   setState((){
    //                                     itemCount = 1;
    //                                     return;
    //                                   });
    //                                 }
    //                                 setState(() {
    //                                   itemCount++;
    //                                 });
    //                               },
    //                               icon: const Icon(Icons.add),
    //                             ),
    //                           ],
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           );
    //         },
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //           child: const Text('Cancel'),
    //         ),
    //         TextButton(
    //           onPressed: () {
    //             if (itemCount == 0) {
    //               setState(() {
    //                 showDialog(
    //                   context: context,
    //                   builder: (c) {
    //                     return const ErrorDialog(message: 'Please enter a quantity(ex: 1, 2, ...)');
    //                   },
    //                 );
    //               });
    //             }
    //
    //             double itemTotal = itemCount * itemModel.itemPrice!;
    //
    //             _addItemToCartFirestore(
    //               widget.store!,
    //               itemModel,
    //               AddToCartItem(
    //                 itemID: itemModel.itemID,
    //                 itemName: itemModel.itemName,
    //                 itemPrice: itemModel.itemPrice,
    //                 itemQnty: itemCount,
    //                 itemTotal: itemTotal,
    //               ),
    //             );
    //           },
    //           child: const Text('Add to Cart'),
    //         ),
    //       ],
    //     );
    //   },
    // );

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

  // void _addItemToCartFirestore(Stores store, Item itemModel, AddToCartItem addCartItemModel) async {
  //   showDialog(
  //     context: context,
  //     builder: (c) {
  //       return const LoadingDialog(message: "Adding item to cart");
  //     },
  //   );
  //
  //   //Check if itemStock in the store is greater than
  //   DocumentReference itemStoreReference = firebaseFirestore.collection('stores').doc(store.storeID).collection('items').doc(itemModel.itemID);
  //   //Check if the item document exist in the Store
  //   DocumentSnapshot itemStoreSnapshot = await itemStoreReference.get();
  //
  //   //Reference for the cart Collection in Firestore
  //   CollectionReference cartCollection = FirebaseFirestore.instance.collection('users').doc(sharedPreferences!.getString('uid')).collection('cart');
  //
  //   //Adding the store inside the cart Collection as Document
  //   DocumentReference storeCartReference = cartCollection.doc(store.storeID);
  //
  //   //Add a fields to the new store document: sellerUID, sellerName, phone, address
  //   await storeCartReference.set(store.addStoreToCart());
  //
  //   //Add the item Collection inside the store Document || this is the items Collection reference
  //   CollectionReference itemCartReference = storeCartReference.collection('items');
  //
  //   //Check if the item document exist
  //   DocumentSnapshot itemCartSnapshot = await itemCartReference.doc('${itemModel.itemID}').get();
  //
  //   if(itemCartSnapshot.exists) {
  //     try {
  //       //We need to check the store item location to check if there's an available stock
  //       //TODOLIST
  //
  //       int newItemQnty = addCartItemModel.itemQnty! + itemCartSnapshot.get('itemQnty') as int;
  //       double newItemTotal = addCartItemModel.itemTotal! + itemCartSnapshot.get('itemTotal');
  //
  //       await itemCartReference.doc('${itemModel.itemID}').update({
  //         'itemQnty' : newItemQnty,
  //         'itemTotal' : newItemTotal,
  //       });
  //
  //       Navigator.of(context).pop();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //          SnackBar(
  //           content: const Text('Item added to cart successfully!'),
  //           backgroundColor: Colors.black.withOpacity(0.8), // Optional: Set background color
  //           duration: const Duration(seconds: 3), // Optional: How long the snackbar is shown
  //         ),
  //       );
  //
  //     } catch (e) {
  //       Navigator.of(context).pop();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to add item to cart: $e'),
  //           backgroundColor: Colors.red, // Optional: Set background color for error
  //           duration: const Duration(seconds: 3), // Optional: How long the snackbar is shown
  //         ),
  //       );
  //     }
  //   } else {
  //     try {
  //       // showDialog(
  //       //   context: context,
  //       //   builder: (c) {
  //       //     return const LoadingDialog(message: "Adding item to cart");
  //       //   },
  //       // );
  //
  //       //Uploading the fields in the Cart Collection
  //       await itemCartReference.doc('${itemModel.itemID}').set(addCartItemModel.toJson());
  //
  //       //Reference to the new image path
  //       Reference oldImageLocation = firebaseStorage.ref(itemModel.itemImagePath);
  //       //String variable of the newImageLocation for the reference in Storage as well as imagePath in the document
  //       final String newImagePath = 'users/${sharedPreferences!.getString('uid')}/cart/${store.storeID}/items/${itemModel.itemID}.jpg';
  //       Reference newImageLocation = firebaseStorage.ref(newImagePath);
  //
  //       //Download the Item Image from the Store
  //       final Uint8List? fileData = await oldImageLocation.getData();
  //
  //       if (fileData != null) {
  //         //Upload to the new Image Location (User's Cart)
  //         UploadTask uploadTask = newImageLocation.putData(fileData);
  //         TaskSnapshot snapshot = await uploadTask;
  //
  //         //Get the new image URL
  //         String newImageURL = await snapshot.ref.getDownloadURL();
  //
  //         //Update the document to the new itemImagePath and itemImageURL
  //         await itemCartReference.doc('${itemModel.itemID}').update({
  //           'itemImagePath': newImagePath,
  //           'itemImageURL': newImageURL,
  //         });
  //
  //       }
  //
  //       Navigator.of(context).pop();
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Item added to cart successfully!'),
  //             backgroundColor: Colors.black.withOpacity(0.8),
  //           duration: const Duration(seconds: 3),
  //         ),
  //       );
  //     } catch (e) {
  //       String errorMessage;
  //
  //       if (e is Exception) {
  //         errorMessage = e.toString();
  //       } else {
  //         errorMessage = 'Failed to add item to cart: $e';
  //       }
  //
  //       Navigator.of(context).pop();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(errorMessage),
  //           backgroundColor: Colors.red, // Optional: Set background color for error
  //           duration: const Duration(seconds: 3), // Optional: How long the snackbar is shown
  //         ),
  //       );
  //     }
  //   }
  // }

  void updateItem() {
    print("YESSSS");
  }

  void _addItemToCartFirestore(Stores store, Item itemModel, AddToCartItem addCartItemModel) async {
    showDialog(
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
        SnackBar(
          content: const Text('Item added to cart successfully!'),
          backgroundColor: Colors.black.withOpacity(0.8),
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
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate to another page (SearchScreen) when the search bar is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Scaffold(body: Placeholder(child: Text('hello'),),)), // Your search screen
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
                const Text(
                  'Search items...',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
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
                        icon: const Icon(Icons.shopping_cart_outlined),
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
                        icon: const Icon(Icons.shopping_cart_outlined),
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
