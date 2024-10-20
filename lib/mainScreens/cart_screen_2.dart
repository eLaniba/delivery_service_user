import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
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
                return SliverToBoxAdapter(
                  child: Card(
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
                                SizedBox(width: 16,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Item Name Item Name Delicious Yes Yes Mah Baby Oh yeaahh Oh yeahhh name Item Name name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      Text('Php 300.00'),
                                      Text(
                                        'Php 5000',
                                        style: TextStyle(
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
                                  'x1',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 16,)
                              ],
                            ),
                            SizedBox(height: 16,),
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
                  ),
                );
              } else {
                return const SliverToBoxAdapter(child: Expanded(child: Center(child: Text('No item added in this store'))));
              }
            },
          ),
        ],
      ),
    );
  }
}
