import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/cart_checkout_screen/cart_screen.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/messages_screen_2.dart';
import 'package:delivery_service_user/mainScreens/store_screen/all_categories_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/all_products_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/search_screen.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/services/providers/badge_provider.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/rating_widget.dart';
import 'package:delivery_service_user/widgets/report_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class StoreCategoryScreen extends StatefulWidget {
  StoreCategoryScreen({super.key, this.stores});

  Stores? stores;

  @override
  State<StoreCategoryScreen> createState() => _StoreCategoryScreenState();
}

class _StoreCategoryScreenState extends State<StoreCategoryScreen>
    with SingleTickerProviderStateMixin {
  String activePage = 'products';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs.
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          activePage = _tabController.index == 0 ? 'products' : 'categories';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartCount>().count ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen(store: widget.stores, searchQuery: activePage,)), // Your search screen
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
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
                  Text(
                    'Search $activePage...',
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          //Cart Screen
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()), // Your search screen
                  );
                },
                icon: Icon(PhosphorIcons.shoppingCart()),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartCount < 99 ? '$cartCount' : '99',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          //Report
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportPage(id: widget.stores!.storeID!, type: 'store',)),
              );
            },
            icon: Icon(PhosphorIcons.warningCircle()),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            // Store Header Content (using your provided widget)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // Background image fills the entire box.
                    Positioned.fill(
                      child: widget.stores!.storeCoverURL != null
                          ? CachedNetworkImage(
                        imageUrl: '${widget.stores!.storeCoverURL}',
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
                        color: Colors.white,
                        child: Icon(
                          PhosphorIcons.imageBroken(PhosphorIconsStyle.regular),
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    ),
                    // Positioned ListTile at the bottom corner.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          // borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: widget.stores!.storeProfileURL != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CachedNetworkImage(
                              imageUrl: '${widget.stores!.storeProfileURL}',
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
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(40)
                              // borderRadius: BorderRadius.circular(8),
                            ),
                            width: 50,
                            height: 50,
                            child: Icon(
                              PhosphorIcons.storefront(PhosphorIconsStyle.regular),
                              color: Colors.white,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.stores!.storeName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis
                                ),
                              ),
                              //Phone number and Star
                              Text(
                                reformatPhoneNumber(widget.stores!.storePhone!),
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              Text(
                                '${widget.stores!.storeAddress}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: InkWell(
                            // CircleBorder ensures the ripple is clipped to a circle.
                            // customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => MessagesScreen2(
                                    partnerName: widget.stores!.storeName!,
                                    partnerID: widget.stores!.storeID!,
                                    imageURL: widget.stores!.storeProfileURL!,
                                    partnerRole: 'store',
                                  ),
                                ),
                              );
                            },
                            child: PhosphorIcon(PhosphorIcons.chatText(PhosphorIconsStyle.regular), color: Colors.red,),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Persistent TabBar header
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 40,
                maxHeight: 40,
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                    indicatorColor: white80,
                    tabs: const [
                      Tab(text: "All Products"),
                      Tab(text: "Categories"),
                    ],
                  ),
                ),
              ),
            ),

          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // For testing, we use ListTest widget (replace with your actual content)
            AllProductsScreen(store: widget.stores!),
            AllCategoriesScreen(store: widget.stores!),
          ],
        ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
