import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_category_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/widgets/item_card.dart';
import 'package:delivery_service_user/widgets/store_card.dart';
import 'package:delivery_service_user/widgets/category_card.dart';

class SearchScreen extends StatefulWidget {
  final String searchQuery;
  final VoidCallback? onTap;
  //For Products, Categories, and Items Search
  final Stores? store;
  //For Store Item Screen; the Items in the Category Card
  final Category? category;

  const SearchScreen({
    this.onTap,
    required this.searchQuery,
    this.store,
    this.category,
    Key? key,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // A controller that, when the user types, we update the filter.
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          // TextField for Search
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextField(
                    autofocus: true,
                    controller: _searchController,
                    onChanged: (value) {
                      // Force rebuild so we can re-filter the data
                      setState(() {});
                    },
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.searchQuery == 'items' ? 'Search ${widget.category!.categoryName!.toLowerCase()}...' : 'Search ${widget.searchQuery}...',
                      hintStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                      border: InputBorder.none, // No underline / border
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _buildSearchBody(),
      backgroundColor: widget.searchQuery == 'store' ? Colors.grey[200] : Colors.white,
    );
  }

  Widget _buildSearchBody() {
    switch (widget.searchQuery) {
      case 'store':
        return _buildStoresView();
      case 'products':
        return _buildProductsGrid();
      case 'categories':
        return _buildCategoriesView();
      case 'items':
        return _buildItemsView();
      default:
        return const Center(child: Text('Unknown search type.'));
    }
  }

  //-------------------------------------------------------------------------------
  // CASE 1: STORES
  //-------------------------------------------------------------------------------
  Widget _buildStoresView() {
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseFirestore
          .collection('stores')
          .where('status', isEqualTo: 'registered')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No stores found.'));
        }

        final searchTerm = _searchController.text.trim().toLowerCase();
        final storeDocs = snapshot.data!.docs;

        // Filter in-memory by storeName.
        final filteredDocs = storeDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final storeName = (data['storeName'] ?? '').toString().toLowerCase();
          return storeName.contains(searchTerm);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No matching stores.'));
        }

        return ListView.builder(
          // Add +1 to include our "End of results." footer.
          itemCount: filteredDocs.length + 1,
          itemBuilder: (context, index) {
            if (index == filteredDocs.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'End of results.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              );
            }
            final storeData = filteredDocs[index].data() as Map<String, dynamic>;
            final storeModel = Stores.fromJson(storeData);
            storeModel.storeID = storeModel.storeID ?? filteredDocs[index].id;

            return StoreCard(
              store: storeModel,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => StoreCategoryScreen(stores: storeModel),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  //-------------------------------------------------------------------------------
  // CASE 2: PRODUCTS (grid)
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
                  return ItemCard(
                    store: widget.store!,
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

  //-------------------------------------------------------------------------------
  // CASE 3: CATEGORIES
  //-------------------------------------------------------------------------------
  Widget _buildCategoriesView() {
    final sid = widget.store!.storeID;
    if (sid == null) {
      return const Center(
        child: Text('No storeID provided for categories search.'),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stores')
          .doc(sid)
          .snapshots(),
      builder: (context, storeSnapshot) {
        if (storeSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!storeSnapshot.hasData || !storeSnapshot.data!.exists) {
          return const Center(child: Text('Store not found.'));
        }

        final storeData = storeSnapshot.data!.data() as Map<String, dynamic>;
        final storeModel = Stores.fromJson(storeData);
        storeModel.storeID = storeModel.storeID ?? storeSnapshot.data!.id;

        // Now fetch categories
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('stores')
              .doc(sid)
              .collection('categories')
              .orderBy('categoryName')
              .snapshots(),
          builder: (context, categoriesSnapshot) {
            if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!categoriesSnapshot.hasData ||
                categoriesSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No categories found.'));
            }

            final searchTerm = _searchController.text.trim().toLowerCase();
            final categoryDocs = categoriesSnapshot.data!.docs;

            // Filter in-memory by categoryName
            final filteredCategories = categoryDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = (data['categoryName'] ?? '').toString().toLowerCase();
              return name.contains(searchTerm);
            }).toList();

            if (filteredCategories.isEmpty) {
              return const Center(child: Text('No matching categories.'));
            }

            return ListView.builder(
              // +1 to account for the extra "End of results." widget.
              itemCount: filteredCategories.length + 1,
              itemBuilder: (context, index) {
                // If we're at the extra slot, show footer text.
                if (index == filteredCategories.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'End of results.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                }
                final catData =
                filteredCategories[index].data() as Map<String, dynamic>;
                final categoryModel = Category.fromJson(catData);
                categoryModel.categoryID =
                    categoryModel.categoryID ?? filteredCategories[index].id;

                return CategoryCard(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (c) => StoreItemScreen(
                          store: widget.store,
                          categoryModel: categoryModel,
                        ),
                      ),
                    );
                  },
                  store: storeModel,
                  category: categoryModel,
                );
              },
            );
          },
        );
      },
    );
  }

  //-------------------------------------------------------------------------------
  // CASE 4: ITEMS
  //-------------------------------------------------------------------------------
  Widget _buildItemsView() {
    // We assume store & category are needed, like in store_item_screen
    final store = widget.store;
    final category = widget.category;
    if (store == null || category == null) {
      return const Center(child: Text('No store/category provided for items search.'));
    }

    return CustomScrollView(
      slivers: [
        // SliverPersistentHeader pinned, using the _SliverAppBarDelegate:
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            minHeight: 30,
            maxHeight: 30,
            child: Container(
              color: Theme.of(context).colorScheme.inversePrimary,
              child: Center(
                child: Text(
                  category.categoryName ?? 'Unnamed Category',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),

        // Then the stream of items filtered by categoryID
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('stores')
              .doc(store.storeID)
              .collection('items')
              .where('categoryID', isEqualTo: category.categoryID)
              .snapshots(),
          builder: (context, itemSnapshot) {
            if (itemSnapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (!itemSnapshot.hasData || itemSnapshot.data!.docs.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('No items available'),
                ),
              );
            }

            // If you also want to filter in-memory by what user typed in _searchController:
            final searchTerm = _searchController.text.trim().toLowerCase();
            final allDocs = itemSnapshot.data!.docs;
            final filteredDocs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final itemName = (data['itemName'] ?? '').toString().toLowerCase();
              return itemName.contains(searchTerm);
            }).toList();

            if (filteredDocs.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('No matching items.'),
                ),
              );
            }

            // Create a SliverGrid
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
                      (context, index) {
                    final itemData = filteredDocs[index].data() as Map<String, dynamic>;
                    final item = Item.fromJson(itemData);

                    // Return your grid item widget
                    return ItemCard(
                      store: store,
                      item: item,
                    );
                  },
                  childCount: filteredDocs.length,
                ),
              ),
            );

          },
        ),

        // Optional "End of results"
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