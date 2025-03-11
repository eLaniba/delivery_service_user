import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/cart_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_item_screen.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class StoreCategoryScreen extends StatefulWidget {
  StoreCategoryScreen({super.key, this.stores});

  Stores? stores;

  @override
  State<StoreCategoryScreen> createState() => _StoreCategoryScreenState();
}

class _StoreCategoryScreenState extends State<StoreCategoryScreen> {
  String activePage = 'products';

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
                Text(
                  'Search $activePage...',
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
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
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartScreen()), // Your search screen
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),
                      Positioned(
                        right: 10,
                        top: 5,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (c) => const CartScreen()));
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          decoration: const BoxDecoration(
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

        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  // Background image fills the entire box.
                  Positioned.fill(
                    child: widget.stores!.storeImageURL != null
                        ? CachedNetworkImage(
                      imageUrl: '${widget.stores!.storeImageURL}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Center(
                          child: Icon(
                            PhosphorIcons.image(PhosphorIconsStyle.fill),
                            size: 48,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: white80,
                        child: Icon(
                          PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    )
                        : Container(
                      color: white80,
                      child: Icon(
                        PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  // Positioned ListTile at the bottom corner.
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7), // transparent white background
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: widget.stores!.storeImageURL != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: '${widget.stores!.storeImageURL}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey,
                              child: Icon(
                                PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                            : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey,
                          child: Icon(
                            PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                            color: Colors.white,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.stores!.storeName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              reformatPhoneNumber(widget.stores!.storePhone!),
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                            Text(
                              '${widget.stores!.storeAddress}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Categories
          // SliverPersistentHeader(
          //   pinned: true,
          //   delegate: _SliverAppBarDelegate(
          //     minHeight: 40,
          //     maxHeight: 40,
          //     child: Container(
          //       color: Theme.of(context).primaryColor,
          //       child: const Center(
          //         child: Text(
          //           'Categories',
          //           style: TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          //Store category list

          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 40,
              maxHeight: 40,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // TODO: Action for "All Products"
                          setState(() {
                            activePage = 'products';
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min, // Use minimal space
                            children: [
                              Text(
                                'All Products',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // TODO: Action for "Categories"
                          setState(() {
                            activePage = 'categories';
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min, // Use minimal space
                            children: [
                              Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


          activePage == 'products'
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("stores")
                      .doc(widget.stores!.storeID)
                      .collection('items')
                      .snapshots(),
                  builder: (context, itemSnapshot) {
                    if (!itemSnapshot.hasData) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: circularProgress(),
                        ),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                mainAxisExtent: 230),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            //code here
                            Item item = Item.fromJson(
                                itemSnapshot.data!.docs[index].data()!
                                    as Map<String, dynamic>);

                            //Return a widget similar to how shoppe display their items
                            return Card(
                              margin: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                              child: InkWell(
                                onTap: () {
                                  // _addItemToCartDialog(item);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Item image
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Container(
                                              height: 180,
                                              width: double.infinity,
                                              // margin: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(4),
                                                  topRight: Radius.circular(4),
                                                ),
                                                child: item.itemImageURL != null
                                                    ? CachedNetworkImage(
                                                        imageUrl:
                                                            '${item.itemImageURL}',
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            Shimmer.fromColors(
                                                          baseColor:
                                                              Colors.grey[300]!,
                                                          highlightColor:
                                                              Colors.grey[100]!,
                                                          child: Center(
                                                            child: Icon(
                                                              PhosphorIcons.image(
                                                                  PhosphorIconsStyle
                                                                      .fill),
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                            PhosphorIcons
                                                                .imageBroken(
                                                                    PhosphorIconsStyle
                                                                        .fill),
                                                            color: Colors.grey,
                                                            size: 48,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        color: Colors.grey[200],
                                                        child: Icon(
                                                          PhosphorIcons.imageBroken(
                                                              PhosphorIconsStyle
                                                                  .fill),
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          // Labels
                                          // Positioned(
                                          //   top: 8,
                                          //   right: 8,
                                          //   child: Container(
                                          //     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          //     decoration: BoxDecoration(
                                          //       color: Colors.redAccent,
                                          //       borderRadius: BorderRadius.circular(4),
                                          //     ),
                                          //     child: const Text(
                                          //       'SALE',
                                          //       style: TextStyle(
                                          //         color: Colors.white,
                                          //         fontSize: 10,
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    //Item name
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                        '${item.itemName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    //Item price and cart icon
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '₱ ${item.itemPrice!.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.shopping_cart_outlined,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Item stock
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                        '${item.itemStock} stock available',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: itemSnapshot.data!.docs.length,
                        ),
                      ),
                    );
                  },
                )
              : StreamBuilder<QuerySnapshot>(
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
