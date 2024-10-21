// import 'package:dotted_line/dotted_line.dart';
// import 'package:flutter/material.dart';
//
// class CheckOutScreen extends StatefulWidget {
//   const CheckOutScreen({super.key});
//
//   @override
//   State<CheckOutScreen> createState() => _CheckOutScreenState();
// }
//
// class _CheckOutScreenState extends State<CheckOutScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Checkout'),
//       ),
//       backgroundColor: Colors.grey[200],
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Column(
//             children: [
//               //User Info
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 color: Colors.white,
//                 width: MediaQuery.of(context).size.width,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12,),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         // mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const SizedBox(
//                             // width: 16,
//                             // height: 20,
//                             child: Icon(Icons.location_on, size: 16,),
//                           ),
//                           const SizedBox(
//                             width: 16,
//                           ),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Flexible(
//                                       child: RichText(
//                                         text: const TextSpan(
//                                           children: [
//                                             TextSpan(
//                                               text: 'Ezra Nehemiah C. Laniba | ',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             TextSpan(
//                                               text: '09204331423',
//                                               style: TextStyle(
//                                                 color: Colors.black54,
//                                               ),
//
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const Flexible(
//                                   child: Text(
//                                     'District 4, Pagina, Jagna, Bohol',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 16,),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const DottedLine(
//                         dashColor: Colors.orange, // Orange color for the dots
//                         lineThickness: 2, // Thickness of the dotted line
//                         dashLength: 10, // Length of each dash (dot)
//                         dashGapLength: 12, // Space between dashes
//                         dashRadius: 2, // Makes each dot circular
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               //Store Info
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 color: Colors.white,
//                 width: MediaQuery.of(context).size.width,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12,),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         // mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const SizedBox(
//                             // width: 16,
//                             // height: 20,
//                             child: Icon(Icons.storefront, size: 16,),
//                           ),
//                           const SizedBox(
//                             width: 16,
//                           ),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Flexible(
//                                       child: RichText(
//                                         text: const TextSpan(
//                                           children: [
//                                             TextSpan(
//                                               text: 'Meat Stall Store 24 | ',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             TextSpan(
//                                               text: '09204331423',
//                                               style: TextStyle(
//                                                 color: Colors.black54,
//                                               ),
//
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const Flexible(
//                                   child: Text(
//                                     'Santa Cruz, Calape, Bohol, Philippines',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 8,),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               //Payment Method
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16,),
//                 width: MediaQuery.of(context).size.width,
//                 color: Colors.white,
//                 child: const Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Payment Method',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           SizedBox(width: 16,),
//                           Icon(Icons.payment_rounded),
//                           Text(' Cash on Delivery')
//                         ],
//                       ),
//                       SizedBox(height: 12,),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';

class CheckOutScreen extends StatefulWidget {
  CheckOutScreen({super.key, this.addToCartStoreInfo});

  AddToCartStoreInfo? addToCartStoreInfo;

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Checkout'),
      ),
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // User Info
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                child: Icon(
                                  Icons.location_on,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Ezra Nehemiah C. Laniba | ',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '09204331423',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Flexible(
                                      child: Text(
                                        'District 4, Pagina, Jagna, Bohol',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const DottedLine(
                            dashColor: Colors.orange,
                            lineThickness: 2,
                            dashLength: 10,
                            dashGapLength: 12,
                            dashRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Store Info
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                child: Icon(
                                  Icons.storefront,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Meat Stall Store 24 | ',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '09204331423',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Flexible(
                                      child: Text(
                                        'Santa Cruz, Calape, Bohol, Philippines',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Payment Method
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Icon(Icons.payment_rounded),
                            Text(' Cash on Delivery'),
                          ],
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // StreamBuilder to listen for Firestore updates
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc('${sharedPreferences!.getString('uid')}')
                  .collection('cart')
                  .doc(widget.addToCartStoreInfo!.sellerUID)
                  .collection('items')
                  .snapshots(),
              builder: (context, itemSnapshot) {
                if (!itemSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                  print('Snapshot has data');
                } else if (itemSnapshot.hasError) {
                  return Center(child: Text('Error: ${itemSnapshot.error}'));
                } else if (itemSnapshot.data!.docs.isNotEmpty) {
                  print('Document is not empty');

                  return Container(
                    height: 150, // Set a fixed height for the horizontal list
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: itemSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        AddToCartItem sAddToCartItem = AddToCartItem.fromJson(
                          itemSnapshot.data!.docs[index].data()! as Map<String, dynamic>,
                        );

                        return Card(
                          child: Text("hello"),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: Text('No items added in this store'));
                }
              },
            ),
          ),

        ],
      ),
    );
  }
}
