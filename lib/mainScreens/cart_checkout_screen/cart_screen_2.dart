import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/checkout_screen.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

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
          "${widget.addToCartStoreInfo!.storeName}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: white80,
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('${sharedPreferences!.getString('uid')}')
                .collection('cart')
                .doc(widget.addToCartStoreInfo!.storeID)
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
                        borderRadius: BorderRadius.circular(8), // Softer, rounded corners
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      elevation: 0,
                      child: InkWell(
                        onTap: () {
                          // Pop-up window for item editing
                        },
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: sAddToCartItem.itemImageURL != null
                                ? CachedNetworkImage(
                              imageUrl: '${sAddToCartItem.itemImageURL}',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              placeholder: (context, url) =>
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      // color: Colors.white,
                                      child: Center(
                                        child: Icon(
                                          PhosphorIcons.image(
                                              PhosphorIconsStyle.fill),
                                        ),
                                      ),
                                    ),
                                  ),
                              // Placeholder while image is loading
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )
                                : Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 215, 219, 221),
                                  width: 2,
                                ),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.image_outlined,
                                color: Color.fromARGB(255, 215, 219, 221),
                              ),
                            ),
                          ),
                          title: Text('${sAddToCartItem.itemName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₱ ${sAddToCartItem.itemPrice!.toStringAsFixed(2)}'),
                              Row(
                                children: [
                                  const Text(
                                    'Total: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₱${sAddToCartItem.itemTotal!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text(
                            'x${sAddToCartItem.itemQnty}',
                            style: TextStyle(
                              fontSize: 16,
                              color: grey50
                            ),
                          ),
                        ),
                        // child: Padding(
                        //   padding: const EdgeInsets.all(12.0),
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       // Product Image
                        //       Container(
                        //         height: 80,
                        //         width: 80,
                        //         decoration: BoxDecoration(
                        //           color: Colors.grey[200],
                        //           borderRadius: BorderRadius.circular(4),
                        //           border: Border.all(color: Colors.grey[300]!, width: 0.5),
                        //         ),
                        //         child: const Center(
                        //           child: Icon(
                        //             Icons.image,
                        //             color: Colors.grey,
                        //             size: 40,
                        //           ),
                        //         ),
                        //       ),
                        //       const SizedBox(width: 12),
                        //       // Product Details
                        //       Expanded(
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text(
                        //               '${sAddToCartItem.itemName}',
                        //               style: const TextStyle(
                        //                 fontSize: 16,
                        //                 fontWeight: FontWeight.bold,
                        //               ),
                        //               maxLines: 1,
                        //               overflow: TextOverflow.ellipsis,
                        //             ),
                        //             const SizedBox(height: 4),
                        //             Text(
                        //               '₱ ${sAddToCartItem.itemPrice!.toStringAsFixed(2)}',
                        //               style: TextStyle(
                        //                 fontSize: 14,
                        //               ),
                        //             ),
                        //             const SizedBox(height: 4),
                        //             Row(
                        //               children: [
                        //                 //Total Text
                        //                 Text(
                        //                   'Total: ',
                        //                   style: TextStyle(
                        //                     fontSize: 16,
                        //                     fontWeight: FontWeight.bold,
                        //                     color: grey50,
                        //                   ),
                        //                 ),
                        //                 //Peso Amount
                        //                 Flexible(
                        //                   child: Text(
                        //                     '₱${sAddToCartItem.itemTotal!.toStringAsFixed(2)}',
                        //                     style: TextStyle(
                        //                       fontSize: 16,
                        //                       fontWeight: FontWeight.bold,
                        //                       color: Theme.of(context).colorScheme.primary,
                        //                     ),
                        //                     maxLines: 1,
                        //                     overflow: TextOverflow.ellipsis,
                        //                   ),
                        //                 ),
                        //                 const Spacer(),
                        //                 Text(
                        //                   'x${sAddToCartItem.itemQnty}',
                        //                   style: const TextStyle(
                        //                     fontSize: 14,
                        //                     color: Colors.grey,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
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
