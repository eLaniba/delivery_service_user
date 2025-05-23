import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_item_screen.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                        'No categories available',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  if (index == categorySnapshot.data!.docs.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'End of results.',
                          style: TextStyle(
                            color: gray,
                          ),
                        ),
                      ),
                    );
                  }

                  Category sCategory = Category.fromJson(
                    categorySnapshot.data!.docs[index].data()! as Map<String, dynamic>,
                  );

                  return CategoryCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => StoreItemScreen(store: store, categoryModel: sCategory,),
                        ),
                      );
                    },
                    store: store,
                    category: sCategory,
                  );
                },
                childCount: categorySnapshot.data!.docs.length + 1, // +1 for the "End of results" text
              ),
            );
          },
        ),
      ],
    );
  }
}