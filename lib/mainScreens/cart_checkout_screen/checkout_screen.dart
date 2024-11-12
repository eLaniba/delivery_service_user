import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../global/global.dart';

class CheckOutScreen extends StatefulWidget {
  final AddToCartStoreInfo? addToCartStoreInfo;
  final List<AddToCartItem>? items;

  const CheckOutScreen({super.key, this.addToCartStoreInfo, this.items});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  double totalOrderPrice = 0;

  @override
  void initState() {
    super.initState();
    totalOrderPrice = calculateOrderTotal(widget.items);
  }

  double calculateOrderTotal(List<AddToCartItem>? items) {
    double total = 0;
    for (var item in items!) {
      total += item.itemTotal!;
    }
    return total;
  }

  void _addOrderToFirestore(NewOrder order) async {
    showDialog(
      context: context,
      builder: (c) => const LoadingDialog(message: "Processing order"),
    );

    try {
      var _newOrderRef = await FirebaseFirestore.instance.collection('active_orders').add(order.toJson());
      await _newOrderRef.update({'orderID': _newOrderRef.id});

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // User and Store Info
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoContainer(
                  icon: Icons.location_on,
                  title: '${sharedPreferences!.get('name')}',
                  subtitle: '${sharedPreferences!.get('phone')}\n${sharedPreferences!.get('address')}',
                ),
                _buildInfoContainer(
                  icon: Icons.storefront,
                  title: widget.addToCartStoreInfo!.storeName!,
                  subtitle: '${widget.addToCartStoreInfo!.storePhone}\n${widget.addToCartStoreInfo!.storeAddress}',
                ),
                _buildPaymentMethodSection(),
              ]),
            ),
          ),
          // Items List
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(sharedPreferences!.getString('uid'))
                  .collection('cart')
                  .doc(widget.addToCartStoreInfo!.storeID)
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.data!.docs.isNotEmpty) {
                  return _buildItemsList(snapshot.data!.docs);
                } else {
                  return const Center(child: Text('No items added in this store'));
                }
              },
            ),
          ),
          // Order Summary
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Your Order: ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: '₱ ${totalOrderPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          color: Theme.of(context).primaryColor,
          child: TextButton(
            onPressed: () {
              DateTime now = DateTime.now();
              Timestamp orderTime = Timestamp.fromDate(now);

              NewOrder order = NewOrder(
                //Order information
                orderStatus: 'Pending',
                orderTime: orderTime,
                orderTotal: totalOrderPrice,
                //Store information
                storeID: widget.addToCartStoreInfo!.storeID,
                storeName: widget.addToCartStoreInfo!.storeName,
                storePhone: widget.addToCartStoreInfo!.storePhone,
                storeAddress: widget.addToCartStoreInfo!.storeAddress,
                storeConfirmDelivery: false,
                storeLocation: widget.addToCartStoreInfo!.storeLocation,
                //List of items
                items: widget.items,
                //User information
                userID: sharedPreferences!.get('uid').toString(),
                userName: sharedPreferences!.get('name').toString(),
                userPhone: sharedPreferences!.get('phone').toString(),
                userAddress: sharedPreferences!.get('address').toString(),
                userConfirmDelivery: false,
                userLocation: parseGeoPointFromJson(sharedPreferences!.get('location').toString()),
              );

              _addOrderToFirestore(order);
            },
            child: const Text(
              'Confirm Order',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.payment_rounded, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Cash on Delivery'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<DocumentSnapshot> docs) {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.red,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, index) {
          AddToCartItem item = AddToCartItem.fromJson(docs[index].data() as Map<String, dynamic>);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.itemImageURL != null
                          ? CachedNetworkImage(
                        imageUrl: '${item.itemImageURL}',
                        width: 150,
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
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '₱ ${item.itemPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' x${item.itemQnty}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱ ${item.itemTotal!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
