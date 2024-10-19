import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(
                  '${sharedPreferences!.get('uid')}')
                  .collection('cart')
                  .snapshots(),
              builder: (context, storeSnapshot) {
                if (!storeSnapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(child: circularProgress(),),
                  );
                }
                print(storeSnapshot.data!.docs[0].id);
                if (storeSnapshot.data!.docs.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_shopping_cart_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                        Text(
                          'Cart is empty',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        AddToCartStoreInfo sAddToCartStoreInfo = AddToCartStoreInfo
                            .fromJson(
                            storeSnapshot.data!.docs[index].data()! as Map<
                                String,
                                dynamic>
                        );

                        return Card(
                          // margin: const EdgeInsets.all(8),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              //code here
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DottedLine(
                                    dashColor: Theme
                                        .of(context)
                                        .colorScheme
                                        .primary,
                                    lineThickness: 3,
                                    dashLength: 16,
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.storefront_outlined),
                                      Expanded(
                                        child: Text(
                                          '${sAddToCartStoreInfo.sellerName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 60,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${sAddToCartStoreInfo.address}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'view item(s)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: storeSnapshot.data!.docs.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
