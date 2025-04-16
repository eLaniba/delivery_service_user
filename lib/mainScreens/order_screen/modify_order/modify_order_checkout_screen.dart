import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/models/address.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/services/calculate_riders_fee.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/services/get_delivery_fees.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/show_floating_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

// ... Keep your imports as-is
class ModifyOrderCheckOutScreen extends StatefulWidget {
  final String orderID;
  final void Function(int) onChangePage;
  final AddToCartStoreInfo? addToCartStoreInfo;

  const ModifyOrderCheckOutScreen({
    super.key,
    required this.orderID,
    required this.onChangePage,
    this.addToCartStoreInfo,
  });

  @override
  State<ModifyOrderCheckOutScreen> createState() => _ModifyOrderCheckOutScreenState();
}

class _ModifyOrderCheckOutScreenState extends State<ModifyOrderCheckOutScreen> {
  NewOrder? order;
  double newSubTotal = 0;
  double newOrderTotal = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    final doc = await firebaseFirestore.collection('active_orders').doc(widget.orderID).get();
    if (doc.exists) {
      setState(() {
        order = NewOrder.fromJson(doc.data()!);
      });
    }
  }

  Future<void> _clearCartModify() async {
    final itemsRef = firebaseFirestore
        .collection('users')
        .doc(sharedPreferences!.getString('uid'))
        .collection('cart_modify')
        .doc(widget.addToCartStoreInfo!.storeID)
        .collection('items');

    final snapshot = await itemsRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  void _confirmOrder() async {

  }

  @override
  Widget build(BuildContext context) {
    final uid = sharedPreferences!.getString('uid');
    final itemsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart_modify')
        .doc(widget.addToCartStoreInfo!.storeID)
        .collection('items')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: itemsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final itemDocs = snapshot.data!.docs;
        final newItems = itemDocs.map((doc) => AddToCartItem.fromJson(doc.data() as Map<String, dynamic>)).toList();

        // Empty state
        if (newItems.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => widget.onChangePage.call(0),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
              ],
              foregroundColor: Colors.grey,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.empty(PhosphorIconsStyle.regular), size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No item exist, please add new item(s) first', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        // Recalculate totals
        newSubTotal = newItems.fold(0.0, (sum, item) => sum + (item.itemTotal ?? 0)) + (order?.subTotal ?? 0);
        newOrderTotal = newSubTotal + (order?.riderFee ?? 0) + (order?.serviceFee ?? 0);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Checkout'),
            actions: [
              IconButton(
                onPressed: () => widget.onChangePage.call(0),
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 8),
            ],
            foregroundColor: Colors.grey,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildInfoContainer(
                  icon: Icons.location_on,
                  title: order?.userName ?? '',
                  subtitle: '${reformatPhoneNumber(order?.userPhone ?? '')}\n${order?.userAddress ?? ''}',
                ),
              ),
              SliverToBoxAdapter(
                child: _buildInfoContainer(
                  icon: Icons.storefront,
                  title: order?.storeName ?? '',
                  subtitle: '${reformatPhoneNumber(order?.storePhone ?? '')}\n${order?.storeAddress ?? ''}',
                ),
              ),
              SliverToBoxAdapter(
                child: _buildItemsSection('Old Item(s)', order?.items ?? []),
              ),
              SliverToBoxAdapter(
                child: _buildItemsSection('Newly Added Item(s)', newItems),
              ),
              SliverToBoxAdapter(
                child: _buildOrderTotal(
                  context: context,
                  subtotal: newSubTotal,
                  riderFee: order?.riderFee ?? 0,
                  convenienceFee: order?.serviceFee ?? 0,
                  orderTotal: newOrderTotal,
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextButton(
                onPressed: () async {
                  bool? isConfirm = await ConfirmationDialog.show(context, 'Are you sure you want to confirm the order?');

                  if(isConfirm == true) {
                    if (order == null || newItems.isEmpty) return;
                    showDialog(context: context, builder: (_) => const LoadingDialog(message: "Updating order..."));

                    try {
                      final updatedItems = [...order!.items ?? [], ...newItems];
                      final updatedSubtotal = newSubTotal;
                      final updatedOrderTotal = newOrderTotal;

                      await firebaseFirestore.collection('active_orders').doc(widget.orderID).update({
                        'items': updatedItems.map((item) => item.toJson()).toList(),
                        'subTotal': updatedSubtotal,
                        'orderTotal': updatedOrderTotal,
                        'userModify': false,
                      });

                      await _clearCartModify();

                      //Closed the loading dialog
                      Navigator.of(context).pop();
                      //Closed the Modify Order Screen
                      Navigator.of(context).pop();
                      showFloatingToast(context: context, message: 'Order updated!', backgroundColor: Colors.green);
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
                    }
                  }
                },
                child: const Text('Confirm Order', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ),
        );
      },
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

  Widget _buildItemsSection(String title, List<AddToCartItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: item.itemImageURL != null
                    ? CachedNetworkImage(imageUrl: item.itemImageURL!, width: 60, height: 70, fit: BoxFit.cover)
                    : const Icon(Icons.image_outlined, size: 60),
              ),
              title: Text(item.itemName ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₱ ${item.itemPrice?.toStringAsFixed(2) ?? '0.00'}'),
                  Text('₱ ${item.itemTotal?.toStringAsFixed(2) ?? '0.00'}', style: TextStyle(color: Theme.of(context).primaryColor)),
                ],
              ),
              trailing: Text('x${item.itemQnty ?? 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrderTotal({
    required BuildContext context,
    required double subtotal,
    required double riderFee,
    required double convenienceFee,
    required double orderTotal,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Subtotal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              Text('Rider\'s fee', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text('Convenience fee', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text('New Order Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₱ ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              Text('₱ ${riderFee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              Text('₱ ${convenienceFee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              Text('₱ ${orderTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            ],
          )
        ],
      ),
    );
  }
}

