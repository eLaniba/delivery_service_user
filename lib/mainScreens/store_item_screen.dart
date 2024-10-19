import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/sellers.dart';
import 'package:delivery_service_user/services/count_cart_listener.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:delivery_service_user/widgets/item_dialog.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:flutter/material.dart';

class StoreItemScreen extends StatefulWidget {
  StoreItemScreen({super.key, this.sellerModel, this.categoryModel});

  Sellers? sellerModel;
  Category? categoryModel;

  @override
  State<StoreItemScreen> createState() => _StoreItemScreenState();
}

class _StoreItemScreenState extends State<StoreItemScreen> {

  void _addItemToCartDialog(Item itemModel) {
    int itemCount = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${itemModel.itemName}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
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
                                      text: '${itemModel.itemPrice}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (itemCount > 1) {
                                      setState(() {
                                        itemCount--;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.remove),
                                ),
                                SizedBox(
                                  width: 30,
                                  child: TextField(
                                    controller: TextEditingController(text: itemCount.toString()),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        itemCount = 0;
                                        return ;
                                      }
                                      if (int.tryParse(value) == null || int.tryParse(value) == 0) {
                                        itemCount = 1;
                                        setState(() {
                                          showDialog(
                                            context: context,
                                            builder: (c) {
                                              return const ErrorDialog(message: 'Quantity must be a whole number(ex: 1, 2, ...)');
                                            },
                                          );
                                        });
                                      } else {
                                        itemCount = int.parse(value);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (itemCount == 1) {
                                      setState((){
                                        itemCount = 1;
                                        return;
                                      });
                                    }
                                    setState(() {
                                      itemCount++;
                                    });
                                  },
                                  icon: Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (itemCount == 0) {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (c) {
                        return const ErrorDialog(message: 'Please enter a quantity(ex: 1, 2, ...)');
                      },
                    );
                  });
                }

                double itemTotal = itemCount * itemModel.itemPrice!;

                _addItemToCartFirestore(
                  widget.sellerModel!,
                  itemModel,
                  AddToCartItem(
                    itemID: itemModel.itemID,
                    itemName: itemModel.itemName,
                    itemPrice: itemModel.itemPrice,
                    itemQnty: itemCount,
                    itemTotal: itemTotal,
                  ),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  void _addItemToCartFirestore(Sellers sellerModel, Item itemModel, AddToCartItem addCartItemModel) async {

    //Reference for the cart Collection in Firestore
    CollectionReference cartCollection = FirebaseFirestore.instance.collection('users').doc(sharedPreferences!.getString('uid')).collection('cart');

    //Adding the store inside the cart Collection as Document
    DocumentReference storeReference = cartCollection.doc(sellerModel.sellerUID);

    //Add a fields to the new store document: sellerUID, sellerName, phone, address
    await storeReference.set(sellerModel.addSellerToCart());

    //Add the item Collection inside the store Document || this is the items Collection reference
    CollectionReference itemReference = storeReference.collection('items');

    //Check if the item document exist
    DocumentSnapshot itemSnapshot = await itemReference.doc('${itemModel.itemID}').get();

    if(itemSnapshot.exists) {
      try {
        Navigator.of(context).pop();
        int newItemQnty = addCartItemModel.itemQnty! + itemSnapshot.get('itemQnty') as int;
        double newItemTotal = addCartItemModel.itemTotal! + itemSnapshot.get('itemTotal');

        showDialog(
          context: context,
          builder: (c) {
            return const LoadingDialog(message: "Adding item to cart");
          },

        );

        await itemReference.doc('${itemModel.itemID}').update({
          'itemQnty' : newItemQnty,
          'itemTotal' : newItemTotal,
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added to cart successfully!'),
            backgroundColor: Colors.blue, // Optional: Set background color
            duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to cart: $e'),
            backgroundColor: Colors.red, // Optional: Set background color for error
            duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      }
    } else {
      try {
        Navigator.of(context).pop();

        showDialog(
          context: context,
          builder: (c) {
            return const LoadingDialog(message: "Adding item to cart");
          },
        );

        await itemReference.doc('${itemModel.itemID}').set(addCartItemModel.toJson());

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added to cartsuccessfully!'),
            backgroundColor: Colors.blue, // Optional: Set background color
            duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item to cart: $e'),
            backgroundColor: Colors.red, // Optional: Set background color for error
            duration: const Duration(seconds: 5), // Optional: How long the snackbar is shown
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.sellerModel!.sellerName}"),
        actions: [
          StreamBuilder<int>(
            stream: countAllItems('${sharedPreferences!.get('uid')}'),
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(right: 40,),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              //other code
              int itemCount = snapshot.data ?? 0;

              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Stack(
                  children: [
                    IconButton(
                      onPressed: () {

                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                    ),
                    if(itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },

          ),
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
                .collection("sellers")
                .doc(widget.sellerModel!.sellerUID)
                .collection("categories")
                .doc(widget.categoryModel!.categoryID)
                .collection('items')
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
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      //code here
                      Item sItem = Item.fromJson(
                        itemSnapshot.data!.docs[index].data()! as Map<String, dynamic>
                      );

                      //Return a widget similar to how shoppe display their items
                      return Card(
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _addItemToCartDialog(sItem);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${sItem.itemName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5,),
                                    Text(
                                      '₱ ${sItem.itemPrice!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
