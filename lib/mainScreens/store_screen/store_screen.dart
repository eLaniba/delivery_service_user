import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomScrollView(
        slivers: [
          StreamBuilder<QuerySnapshot>(
            stream:
            FirebaseFirestore.instance.collection("sellers").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Center(child: circularProgress()),
                );
              }
              return SliverMasonryGrid.count(
                crossAxisCount: 2, // Adjust as needed
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Stores sModel = Stores.fromJson(
                    snapshot.data!.docs[index].data()! as Map<String, dynamic>,
                  );
                  // Design for display sellers-cafes-restaurants
                  return Container();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}