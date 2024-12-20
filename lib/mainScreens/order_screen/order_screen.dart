import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/order_screen/order_details_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/order_screen_2.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/widgets/order_card.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('active_orders')
              .where('userID', isEqualTo: sharedPreferences!.get('uid'))
              .where('orderStatus', whereNotIn: ['Completing', 'Completed'])
              .orderBy('orderTime', descending: true)
              .snapshots(),
          builder: (context, orderSnapshot) {
            if(orderSnapshot.connectionState == ConnectionState.waiting) {
              return SliverToBoxAdapter(child: Center(child: circularProgress(),));
            } else if(orderSnapshot.hasError) {
              return SliverToBoxAdapter(child: Center(child: Text('Error: ${orderSnapshot.error}'),));
            } else if (orderSnapshot.hasData && orderSnapshot.data!.docs.isNotEmpty) {
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  NewOrder order = NewOrder.fromJson(orderSnapshot.data!.docs[index].data()! as Map<String, dynamic>,);

                  return OrderCard(order: order);
                  // return Card(
                  //   margin: const EdgeInsets.all(8),
                  //   elevation: 2,
                  //   child: InkWell(
                  //     onTap: (){
                  //       // Navigator.push(context, MaterialPageRoute(builder: (c) => OrderScreen2(orderDetail: order,)));
                  //       Navigator.push(context, MaterialPageRoute(builder: (c) => OrderDetailsScreen(order: order,)));
                  //     },
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(8),
                  //       child: Column(
                  //         children: [
                  //           //Icon + Order Status
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.start,
                  //             // crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               const SizedBox(
                  //                 child: Icon(
                  //                   Icons.circle,
                  //                   color: Colors.orange,
                  //                   size: 16,
                  //                 ),
                  //               ),
                  //               const SizedBox(width: 8,),
                  //               Flexible(
                  //                 child: Text('${order.orderStatus}'),
                  //               ),
                  //             ],
                  //           ),
                  //           //Icon + Store Name
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.start,
                  //             children: [
                  //               const SizedBox(
                  //                 child: Icon(
                  //                   Icons.storefront,
                  //                   size: 16,
                  //                 ),
                  //               ),
                  //               const SizedBox(width: 8,),
                  //               Expanded(
                  //                 child: RichText(
                  //                   text: TextSpan(
                  //                     children: [
                  //                       TextSpan(
                  //                         text: '${order.storeName}',
                  //                         style: const TextStyle(
                  //                           color: Colors.black,
                  //                           fontSize: 16,
                  //                           fontWeight: FontWeight.bold,
                  //                         ),
                  //                       ),
                  //                       TextSpan(
                  //                         text: ' ${order.storePhone}',
                  //                         style: const TextStyle(
                  //                           color: Colors.grey,
                  //                           fontSize: 14,
                  //                         ),
                  //                       ),
                  //                     ]
                  //                   ),
                  //                 ),
                  //               ),
                  //               const Icon(Icons.arrow_forward_ios),
                  //             ],
                  //           ),
                  //           //Item(s) Text
                  //           const Row(
                  //             mainAxisAlignment: MainAxisAlignment.start,
                  //             children: [
                  //               SizedBox(width: 12,),
                  //               Text(
                  //                 'Item(s)',
                  //                 style: TextStyle(
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           //Vertical Scroll list of Items
                  //           SizedBox(
                  //             height: 150,
                  //             child: ListView.builder(
                  //               scrollDirection: Axis.horizontal,
                  //               itemCount: order.items!.length,
                  //               itemBuilder: (context, index) {
                  //                 return Container(
                  //                   margin: const EdgeInsets.symmetric(horizontal: 4),
                  //                   width: 100,
                  //                   color: Colors.white,
                  //                   child: Column(
                  //                     children: [
                  //                       Container(
                  //                         margin: const EdgeInsets.all(8),
                  //                         // padding: const EdgeInsets.all(4),
                  //                         height: 80,
                  //                         width: 80,
                  //                         color: Colors.grey[200],
                  //                         child: ClipRRect(
                  //                           borderRadius: const BorderRadius.only(
                  //                             topLeft: Radius.circular(4),
                  //                             topRight: Radius.circular(4),
                  //                           ),
                  //                           child: order.items![index].itemImageURL != null
                  //                               ? CachedNetworkImage(
                  //                             imageUrl: '${order.items![index].itemImageURL}',
                  //                             fit: BoxFit.fill,
                  //                             placeholder: (context, url) => Shimmer.fromColors(
                  //                               baseColor: Colors.grey[300]!,
                  //                               highlightColor: Colors.grey[100]!,
                  //                               child: Center(
                  //                                 child: Icon(
                  //                                   PhosphorIcons.image(
                  //                                       PhosphorIconsStyle.fill),
                  //                                   color: Colors.grey,
                  //                                 ),
                  //                               ),
                  //                             ),
                  //                             errorWidget: (context, url, error) =>
                  //                                 Container(
                  //                                   color: Colors.grey[200],
                  //                                   child: Icon(
                  //                                     PhosphorIcons.imageBroken(
                  //                                         PhosphorIconsStyle.fill),
                  //                                     color: Colors.grey,
                  //                                     size: 48,
                  //                                   ),
                  //                                 ),
                  //                           )
                  //                               : Container(
                  //                             color: Colors.grey[200],
                  //                             child: Icon(
                  //                               PhosphorIcons.imageBroken(
                  //                                   PhosphorIconsStyle.fill),
                  //                               color: Colors.grey,
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       Flexible(
                  //                         child: RichText(
                  //                           text: TextSpan(
                  //                             children: [
                  //                               TextSpan(
                  //                                 text: '₱ ${order.items![index].itemPrice!.toStringAsFixed(2)}',
                  //                                 style: const TextStyle(
                  //                                   color: Colors.black,
                  //                                   fontWeight: FontWeight.bold,
                  //                                 ),
                  //                               ),
                  //                               TextSpan(
                  //                                 text: ' x ${order.items![index].itemQnty}',
                  //                                 style: const TextStyle(
                  //                                   color: Colors.grey,
                  //                                 ),
                  //                               ),
                  //                             ]
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       Flexible(
                  //                         child: Text(
                  //                           '₱ ${order.items![index].itemTotal!.toStringAsFixed(2)}',
                  //                           style: const TextStyle(
                  //                             color: Colors.orange,
                  //                             fontSize: 16,
                  //                             fontWeight: FontWeight.bold,
                  //                           ),
                  //                           overflow: TextOverflow.ellipsis,
                  //                           maxLines: 1,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 );
                  //               },
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // );
                },
                    childCount: orderSnapshot.data!.docs.length),
              );
            } else {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.empty(PhosphorIconsStyle.regular),
                      size: 48,
                      color: Colors.grey,
                    ),
                    const Text(
                      'No active order exist',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }
}