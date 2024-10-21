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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.addToCartStoreInfo!.sellerName}",
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
              if(!itemSnapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Center(child: circularProgress()),
                );
              } else if (itemSnapshot.hasError) {
                return Center(child: Text('Error: ${itemSnapshot.error}'),);
              } else if (itemSnapshot.hasData && itemSnapshot.data!.docs.isNotEmpty) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    AddToCartItem sAddToCartItem = AddToCartItem.fromJson(
                        itemSnapshot.data!.docs[index].data()! as Map<String, dynamic>
                    );
                    return Card(
                      // margin: const EdgeInsets.all(8),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          //Navigate to Checkout Page
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 16,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                         '${sAddToCartItem.itemName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        Text('₱ ${sAddToCartItem.itemPrice!.toStringAsFixed(2)}',),
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
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'x${sAddToCartItem.itemQnty}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 16,)
                                ],
                              ),
                              const SizedBox(height: 16,),
                              DottedLine(
                                dashColor: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
                                lineThickness: 3,
                                dashLength: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    },
                  childCount: itemSnapshot.data!.docs.length,
                  ),
                );
              } else {
                return const SliverToBoxAdapter(child: Expanded(child: Center(child: Text('No item added in this store'))));
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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => CheckOutScreen(addToCartStoreInfo: widget.addToCartStoreInfo,)));
            },
            child: const Text(
              'Checkout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
