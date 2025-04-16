import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_item_card.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart'; // <-- Import store model
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ModifyOrderAllProducts extends StatefulWidget {
  Stores store;
  final void Function(int) onChangePage;

  ModifyOrderAllProducts({required this.store, required this.onChangePage, super.key});

  @override
  State<ModifyOrderAllProducts> createState() => _ModifyOrderAllProductsState();
}

class _ModifyOrderAllProductsState extends State<ModifyOrderAllProducts> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            widget.onChangePage.call(1);
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey, // Change this to any color you like
                width: 1.5,         // You can adjust the width
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Search items...',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        foregroundColor: Colors.grey,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream: firebaseFirestore
                .collection("stores")
                .doc(widget.store.storeID)
                .collection('items')
                .snapshots(),
            builder: (context, itemSnapshot) {
              if (!itemSnapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (itemSnapshot.data!.docs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.playlist_remove_outlined,
                        color: Colors.grey,
                        size: 48,
                      ),
                      Text(
                        'No items available',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    mainAxisExtent: 230,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      final data = itemSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final item = Item.fromJson(data);

                      return ModifyOrderItemCard(
                        store: widget.store,
                        item: item,
                      );
                    },
                    childCount: itemSnapshot.data!.docs.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'End of results.',
                  style: TextStyle(
                    color: gray,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
