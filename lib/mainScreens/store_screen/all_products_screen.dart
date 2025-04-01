import 'dart:typed_data';
import 'package:delivery_service_user/global/global.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/item_card.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';


class AllProductsScreen extends StatefulWidget {
  final Stores store;


  const AllProductsScreen({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("stores")
              .doc(widget.store.storeID)
              .collection('items')
              .snapshots(),
          builder: (context, itemSnapshot) {
            if (!itemSnapshot.hasData) {
              return SliverToBoxAdapter(
                child: Center(child: circularProgress()),
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

                    // Use the ItemCard widget to display the item.
                    return ItemCard(
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
    );
  }
}
