import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/sellers.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:delivery_service_user/widgets/seller_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

// class _StoreScreenState extends State<StoreScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Name"),
//       ),
//       body: CustomScrollView(
//         slivers: [
//           StreamBuilder<QuerySnapshot>(
//             stream:
//                 FirebaseFirestore.instance.collection("sellers").snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return SliverToBoxAdapter(
//                   child: Center(child: circularProgress()),
//                 );
//               }
//               return SliverMasonryGrid.count(
//                 crossAxisCount: 2, // Adjust as needed
//                 // mainAxisSpacing: 4,
//                 // crossAxisSpacing: 4,
//                 childCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   Sellers sModel = Sellers.fromJson(
//                     snapshot.data!.docs[index].data()! as Map<String, dynamic>,
//                   );
//                   // Design for display sellers-cafes-restaurants
//                   return InfoDesignWidget(
//                     model: sModel,
//                     context: context,
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem> [
//           BottomNavigationBarItem(icon: Icon(Icons.home),),
//         ],
//       ),
//     );
//   }
// }

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
                crossAxisCount: 1, // Adjust as needed
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Sellers sModel = Sellers.fromJson(
                    snapshot.data!.docs[index].data()! as Map<String, dynamic>,
                  );
                  // Design for display sellers-cafes-restaurants
                  return SellerInfo(
                    model: sModel,
                    context: context,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}