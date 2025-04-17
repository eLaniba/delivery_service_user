import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/widgets/order_card.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
              .where('userStatus', whereNotIn: ['Completed', 'Cancelled'])
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