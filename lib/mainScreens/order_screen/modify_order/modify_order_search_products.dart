import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_item_card.dart';
import 'package:flutter/material.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/models/category_item.dart';

class ModifyOrderSearchProducts extends StatefulWidget {
  final String searchQuery;
  //For Products, Categories, and Items Search
  final Stores store;
  //For Store Item Screen; the Items in the Category Card
  final Category? category;
  final void Function(int) onChangePage;

  const ModifyOrderSearchProducts({
    required this.searchQuery,
    required this.store,
    this.category,
    required this.onChangePage,
    Key? key,
  }) : super(key: key);

  @override
  State<ModifyOrderSearchProducts> createState() => _ModifyOrderSearchProductsState();
}

class _ModifyOrderSearchProductsState extends State<ModifyOrderSearchProducts> {
  // A controller that, when the user types, we update the filter.
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            // InkWell(
            //   splashColor: Colors.transparent,
            //   onTap: () {
            //     widget.onChangePage.call(0);
            //   },
            //   child: Container(
            //     margin: const EdgeInsets.only(left: 16),
            //     width: 30,
            //     height: 30,
            //     child: const Icon(Icons.arrow_back),
            //   ),
            // ),
            Flexible(
              child: Container(
                height: 44,
                margin: const EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey, // Change this to any color you like
                    width: 1.5,         // You can adjust the width
                  ),
                ),
                // TextField for Search
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextField(
                          autofocus: false,
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search item...',
                            hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                            border: InputBorder.none, // No underline / border
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
        foregroundColor: Colors.grey,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _buildSearchBody(),
    );
  }

  Widget _buildSearchBody() {
    switch (widget.searchQuery) {
      case 'items':
        return _buildProductsGrid();
      default:
        return const Center(child: Text('Unknown search type.'));
    }
  }
  //-------------------------------------------------------------------------------
  // CASE 1: PRODUCTS (grid)
  //-------------------------------------------------------------------------------
  Widget _buildProductsGrid() {
    final storeID = widget.store!.storeID;
    if (storeID == null) {
      return const Center(
        child: Text('No storeID provided for products search.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stores')
          .doc(storeID)
          .collection('items')
          .orderBy('itemName', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        final searchTerm = _searchController.text.trim().toLowerCase();
        final itemDocs = snapshot.data!.docs;

        // Filter in-memory by itemName
        final filteredDocs = itemDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final itemName =
          (data['itemName'] ?? '').toString().toLowerCase();
          return itemName.contains(searchTerm);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No matching products.'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              GridView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  mainAxisExtent: 230,
                ),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final data = filteredDocs[index].data() as Map<String, dynamic>;
                  final item = Item.fromJson(data);
                  return ModifyOrderItemCard(
                    store: widget.store,
                    item: item,
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'End of results.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );


      },
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