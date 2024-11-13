
import 'dart:typed_data';

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
import 'package:http/http.dart' as http;

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

      // Retrieve the Firestore document once before the loop
      DocumentSnapshot docSnapshot = await firebaseFirestore.doc(_newOrderRef.path).get();
      List<dynamic> itemsFromFirestore = docSnapshot['items'];

      //Uploading Item image to Cloud Storage
      for(var item in widget.items!) {
        try{
          //Step 1: Fetch the image data from the URL
          final response = await http.get(Uri.parse(item.itemImageURL!));

          if (response.statusCode == 200) {
            //Step 2: Get the image data as bytes
            Uint8List imageData = response.bodyBytes;

            //Step 3: Upload the image data to the new path in Cloud Storage
            final destinationRef = firebaseStorage.ref().child('active_orders/${_newOrderRef.id}/items/${item.itemID}.jpg');
            await destinationRef.putData(imageData);

            //Step 4: Get the new image URL
            String newImageURL = await destinationRef.getDownloadURL();

            //Step 5: Update the specific item's image URL in the `itemsFromFirestore` list
              //Find the item in the array by itemID and update its image URL
            for(var i = 0; i < itemsFromFirestore.length; i++) {
              if(itemsFromFirestore[i]['itemID'] == item.itemID) {
                itemsFromFirestore[i]['itemImageURL'] = newImageURL;
                break;
              }
            }
            print('Image uploaded and Firestore document updated with new image URL for itemID: ${item.itemID}');
          }
        } catch(e) {
          print("Internet error occurs: $e");
        }
      }

      //Save the updated items array back to Firestore
      await firebaseFirestore.doc(_newOrderRef.path).update({
        'items': itemsFromFirestore,
      });

      print('Firestore document updated with new image URLs for all items');

      deleteItemsFromCart(order.storeID.toString());

      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order placed successfully!'),
            backgroundColor: Colors.black.withOpacity(0.8),
            duration: const Duration(seconds: 5),
          ),
        );
      });

    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItemsFromCart(String storeID) async {
    try{
      //Reference to the store
      final storeDocument = firebaseFirestore
          .collection('users')
          .doc(sharedPreferences!.getString('uid'))
          .collection('cart')
          .doc(storeID);
      //Reference to the store/items collection
      final itemsCollection = firebaseFirestore
          .collection('users')
          .doc(sharedPreferences!.getString('uid'))
          .collection('cart')
          .doc(storeID)
          .collection('items');

      //Get all items in the items sub-collection
      final itemsSnapshot = await itemsCollection.get();

      //Delete each item Documents inside the items collection
      for (var itemDocument in itemsSnapshot.docs) {
        await itemDocument.reference.delete();
      }

      //Delete the store document inside the cart collection
      storeDocument.delete();
    } catch(e) {

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
          // SliverToBoxAdapter(
          //   child: StreamBuilder<QuerySnapshot>(
          //     stream: FirebaseFirestore.instance
          //         .collection('users')
          //         .doc(sharedPreferences!.getString('uid'))
          //         .collection('cart')
          //         .doc(widget.addToCartStoreInfo!.storeID)
          //         .collection('items')
          //         .snapshots(),
          //     builder: (context, snapshot) {
          //       if (!snapshot.hasData) {
          //         return const Center(child: CircularProgressIndicator());
          //       } else if (snapshot.data!.docs.isNotEmpty) {
          //         return _buildItemsList(snapshot.data!.docs, widget.items!);
          //       } else {
          //         return const Center(child: Text('No items added in this store'));
          //       }
          //     },
          //   ),
          // ),
          SliverToBoxAdapter(
            child: _buildItemsList(widget.items!),
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

  Widget _buildItemsList(List<AddToCartItem> items) {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.red,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          // AddToCartItem item = AddToCartItem.fromJson(items[index].data() as Map<String, dynamic>);
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
                      child: items[index].itemImageURL != null
                          ? CachedNetworkImage(
                        imageUrl: '${items[index].itemImageURL}',
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
                        child: const Icon(
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
                          text: '₱ ${items[index].itemPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' x${items[index].itemQnty}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱ ${items[index].itemTotal!.toStringAsFixed(2)}',
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
