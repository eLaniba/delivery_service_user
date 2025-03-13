import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AllCategoriesScreen extends StatelessWidget {
  final Stores store;

  const AllCategoriesScreen({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("stores")
              .doc(store.storeID)
              .collection('categories')
              .snapshots(),
          builder: (context, categorySnapshot) {
            if (!categorySnapshot.hasData) {
              return const SliverToBoxAdapter(
                child: SizedBox(),
              );
            }

            if (categorySnapshot.data!.docs.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No categories available',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  Category sCategory = Category.fromJson(
                    categorySnapshot.data!.docs[index].data()! as Map<String, dynamic>,
                  );

                  return CategoryCard(store: store, category: sCategory);
                },
                childCount: categorySnapshot.data!.docs.length,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
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
