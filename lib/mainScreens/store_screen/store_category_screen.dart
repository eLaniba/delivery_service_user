import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/cart_screen.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/messages_screen_2.dart';
import 'package:delivery_service_user/mainScreens/store_screen/all_categories_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/all_products_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/search_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_item_screen.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:delivery_service_user/widgets/report_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class StoreCategoryScreen extends StatefulWidget {
  StoreCategoryScreen({super.key, this.stores});

  Stores? stores;

  @override
  State<StoreCategoryScreen> createState() => _StoreCategoryScreenState();
}

class _StoreCategoryScreenState extends State<StoreCategoryScreen>
    with SingleTickerProviderStateMixin {
  String activePage = 'products';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs.
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          activePage = _tabController.index == 0 ? 'products' : 'categories';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //Item Dialog
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
                    widget.stores!,
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
  //Save to Firestore
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
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen(store: widget.stores, searchQuery: activePage,)), // Your search screen
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Search $activePage...',
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
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
                return const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
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
                );
              } else {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const CartScreen()),
                        );
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
                );
              }
            },
          ),
          //Report
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportPage(id: widget.stores!.storeID!, type: 'store',)),
              );
            },
            icon: Icon(PhosphorIcons.warningCircle()),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            // Store Header Content (using your provided widget)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // Background image fills the entire box.
                    Positioned.fill(
                      child: widget.stores!.storeCoverURL != null
                          ? CachedNetworkImage(
                        imageUrl: '${widget.stores!.storeCoverURL}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Center(
                            child: Icon(
                              PhosphorIcons.image(PhosphorIconsStyle.fill),
                              size: 48,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: white80,
                          child: Icon(
                            PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      )
                          : Container(
                        color: Colors.white,
                        child: Icon(
                          PhosphorIcons.imageBroken(PhosphorIconsStyle.regular),
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    ),
                    // Positioned ListTile at the bottom corner.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          // borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: widget.stores!.storeProfileURL != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CachedNetworkImage(
                              imageUrl: '${widget.stores!.storeProfileURL}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey,
                                child: Icon(
                                  PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(40)
                              // borderRadius: BorderRadius.circular(8),
                            ),
                            width: 50,
                            height: 50,
                            child: Icon(
                              PhosphorIcons.storefront(PhosphorIconsStyle.regular),
                              color: Colors.white,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.stores!.storeName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis
                                ),
                              ),
                              Text(
                                reformatPhoneNumber(widget.stores!.storePhone!),
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              Text(
                                '${widget.stores!.storeAddress}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: InkWell(
                            // CircleBorder ensures the ripple is clipped to a circle.
                            // customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => MessagesScreen2(
                                    partnerName: widget.stores!.storeName!,
                                    partnerID: widget.stores!.storeID!,
                                    imageURL: widget.stores!.storeProfileURL!,
                                    partnerRole: 'store',
                                  ),
                                ),
                              );
                            },
                            child: PhosphorIcon(PhosphorIcons.chatText(PhosphorIconsStyle.regular), color: Colors.red,),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Persistent TabBar header
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 40,
                maxHeight: 40,
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                    indicatorColor: white80,
                    tabs: const [
                      Tab(text: "All Products"),
                      Tab(text: "Categories"),
                    ],
                  ),
                ),
              ),
            ),

          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // For testing, we use ListTest widget (replace with your actual content)
            AllProductsScreen(store: widget.stores!),
            AllCategoriesScreen(store: widget.stores!),
          ],
        ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
