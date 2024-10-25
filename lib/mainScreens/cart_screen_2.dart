import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/checkout_screen.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

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
          "${widget.addToCartStoreInfo!.sellerName}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('${sharedPreferences!.getString('uid')}')
                .collection('cart')
                .doc(widget.addToCartStoreInfo!.sellerUID)
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
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    AddToCartItem sAddToCartItem = AddToCartItem.fromJson(
                        itemSnapshot.data!.docs[index].data()! as Map<String, dynamic>);

                    // Check if the item has already been processed
                    if (!processedItemIDs.contains(sAddToCartItem.itemID)) {
                      // Add item to the list and track its ID
                      listAddToCartItem.add(sAddToCartItem);
                      processedItemIDs.add(sAddToCartItem.itemID!);
                      print('List added: ${sAddToCartItem.itemID}');
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      elevation: 1,
                      child: InkWell(
                        onTap: () {
                          // Pop-up window for item editing
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      // borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${sAddToCartItem.itemName}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '₱ ${sAddToCartItem.itemPrice!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₱ ${sAddToCartItem.itemTotal!.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'x${sAddToCartItem.itemQnty}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 12),
                              // DottedLine(
                              //   dashColor: Theme.of(context).colorScheme.primary,
                              //   lineThickness: 1.5,
                              //   dashLength: 6,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: itemSnapshot.data!.docs.length),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No items added in this store')),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          color: Colors.black,
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
