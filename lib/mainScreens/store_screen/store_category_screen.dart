import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_item_screen.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/services/count_cart_listener.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../global/global.dart';

class StoreCategoryScreen extends StatefulWidget {
  StoreCategoryScreen({super.key, this.stores});

  Stores? stores;

  @override
  State<StoreCategoryScreen> createState() => _StoreCategoryScreenState();
}

class _StoreCategoryScreenState extends State<StoreCategoryScreen> {

  Future<bool> checkCategory() async {
    //Create a Category Collection reference
    CollectionReference categoriesCollection = FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.stores!.storeID)
        .collection('categories');

    //Get all documents from Category Collection
    QuerySnapshot querySnapshot = await categoriesCollection.get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Navigate to another page (SearchScreen) when the search bar is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Scaffold(body: Placeholder(child: Text('hello'),),)), // Your search screen
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Search categories...',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc('${sharedPreferences!.get('uid')}')
                .collection('cart')
                .snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(right: 40,),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty){
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {

                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),

                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(right: 24,),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {

                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),

                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            // color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // StreamBuilder<int>(
          //   stream: countAllItems('${sharedPreferences!.get('uid')}'),
          //   builder: (context, snapshot) {
          //     if(!snapshot.hasData) {
          //       return const Padding(
          //         padding: EdgeInsets.only(right: 40,),
          //         child: SizedBox(
          //           width: 16,
          //           height: 16,
          //           child: CircularProgressIndicator(),
          //         ),
          //       );
          //     }
          //
          //     //other code
          //     int itemCount = snapshot.data ?? 0;
          //
          //     return Padding(
          //       padding: const EdgeInsets.only(right: 24),
          //       child: Stack(
          //         children: [
          //           IconButton(
          //             onPressed: () {
          //               Navigator.push(context, MaterialPageRoute(builder: (c) => const CartScreen()));
          //             },
          //             icon: const Icon(Icons.shopping_cart_outlined),
          //           ),
          //           if(itemCount > 0)
          //             Positioned(
          //               right: 0,
          //               top: 0,
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   color: Colors.red,
          //                   borderRadius: BorderRadius.circular(2),
          //                 ),
          //                 constraints: const BoxConstraints(
          //                   minWidth: 16,
          //                   minHeight: 16,
          //                 ),
          //                 child: Text(
          //                   '$itemCount',
          //                   style: const TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 16,
          //                   ),
          //                   textAlign: TextAlign.center,
          //                 ),
          //               ),
          //             ),
          //               ],
          //       ),
          //     );
          //   },
          //
          // ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              // color: Colors.grey,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2),
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Text(
                    '${widget.stores!.storeName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.stores!.storeAddress}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 40,
              maxHeight: 40,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: const Center(
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("stores")
                .doc(widget.stores!.storeID)
                .collection('categories')
                .snapshots(),
            builder: (context, categorySnapshot) {
              if (!categorySnapshot.hasData) {
                return SliverToBoxAdapter(
                  child: Center(child: circularProgress(),),
                );
              }

              if (categorySnapshot.data!.docs.isEmpty) {
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
                        'No categories available',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Category sCategory = Category.fromJson(
                        categorySnapshot.data!.docs[index].data()! as Map<String, dynamic>
                      );

                      return InkWell(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreItemScreen(sellerModel: widget.model,categoryModel: sCategory,)));
                          Navigator.push(context, MaterialPageRoute(builder: (c) => StoreItemScreen(store: widget.stores,categoryModel: sCategory,))).then((_) {
                            setState(() {

                            });
                          });

                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8,),
                          width: MediaQuery.of(context).size.width,
                          // child: Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       children: [
                          //         Expanded(
                          //           child: Text(
                          //             sCategory.categoryName!,
                          //             style: TextStyle(
                          //               fontSize: 16,
                          //             ),
                          //             overflow: TextOverflow.ellipsis,
                          //             maxLines: 1,
                          //             softWrap: false,
                          //           ),
                          //         ),
                          //         Icon(
                          //           Icons.arrow_forward_ios,
                          //           size: 16,
                          //         ),
                          //       ],
                          //     ),
                          //     const Divider(
                          //       color: Colors.grey,
                          //       thickness: 1,
                          //     ),
                          //   ],
                          // ),
                          child: ListTile(
                            title: Text('${sCategory.categoryName}'),
                            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular)),
                          ),
                        ),
                      );
                    },
                  childCount: categorySnapshot.data!.docs.length,
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
