import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';

class CheckOutScreen extends StatefulWidget {
  CheckOutScreen({
    super.key,
    this.addToCartStoreInfo,
    this.items,
  });

  AddToCartStoreInfo? addToCartStoreInfo;
  List<AddToCartItem>? items;

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  double totalOrderPrice = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalOrderPrice = calculateOrderTotal(widget.items);
  }

  double calculateOrderTotal(List<AddToCartItem>? items) {
    double total = 0;
    // Set<String> processedItemIDs = {};

    // for(var item in items!) {
    //   if (item.itemID != null && !processedItemIDs.contains(item.itemID)) {
    //     total += item.itemTotal ?? 0;
    //     processedItemIDs.add(item.itemID!);  // Mark this itemID as processed
    //   }
    for (var item in items!) {
      total += item.itemTotal!;
    }
    return total;
  }

  void _addOrderToFirestore(NewOrder order) async {
    showDialog(
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Processing order");
      },
    );

    CollectionReference activeOrder = FirebaseFirestore.instance.collection('active_orders');

    try{
      var _newOrderRef = await activeOrder.add(order.toJson());

      await _newOrderRef.update({
        'orderID' : _newOrderRef.id,
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text('Item added successfully!'),
          backgroundColor: Colors.blue, // Optional: Set background color
          duration: Duration(seconds: 5), // Optional: How long the snackbar is shown
        ),
      );
    } catch (e){
      rethrow;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Checkout'),
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
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '${sharedPreferences!.get('name')} ',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${sharedPreferences!.get('phone')}',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Flexible(
                                      child: Text(
                                        '${sharedPreferences!.get('address')}',
                                        style: const TextStyle(
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
                            dashColor: Colors.blue,
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
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '${widget.addToCartStoreInfo!.sellerName} ',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${widget.addToCartStoreInfo!.phone}',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Flexible(
                                      child: Text(
                                        '${widget.addToCartStoreInfo!.address}',
                                        style: const TextStyle(
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
                    child: const Column(
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
                          child: Container(
                            // height: 40,
                              width: 100,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 80,
                                      // color: Colors.white,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey,),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8,),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '₱ ${sAddToCartItem.itemPrice!.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                          TextSpan(
                                            text: ' x${sAddToCartItem.itemQnty}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ]
                                      ),
                                    ),
                                    const SizedBox(height: 2,),
                                    Expanded(
                                      child: Text(
                                        '₱ ${sAddToCartItem.itemTotal!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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

          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    Positioned(
                      right: 16,
                      bottom: 0,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Your Order: ',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '₱ ${totalOrderPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          color: Colors.black,
          child: TextButton(
            onPressed: () {
              DateTime now = DateTime.now();
              Timestamp orderTime = Timestamp.fromDate(now);

              //Creating new order
              NewOrder order = NewOrder(
              //Order Info
              orderStatus: 'Pending',
              orderTime: orderTime,
              orderTotal: totalOrderPrice,

              //Store Info
              storeID: widget.addToCartStoreInfo!.sellerUID,
              storeName: widget.addToCartStoreInfo!.sellerName,
              storePhone: widget.addToCartStoreInfo!.phone,
              storeAddress: widget.addToCartStoreInfo!.address,

              items: widget.items,

              //User Info
              userID: sharedPreferences!.get('uid').toString(),
              userName: sharedPreferences!.get('name').toString(),
              userPhone: sharedPreferences!.get('phone').toString(),
              userAddress: sharedPreferences!.get('address').toString(),
              userConfirmDelivery: false,

              //Rider Info
              //After Store Preperation
              );

              _addOrderToFirestore(order);
            },
            child: const Text(
              'Confirm Order',
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
