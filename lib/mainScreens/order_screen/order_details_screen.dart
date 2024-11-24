import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/order_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class OrderDetailsScreen extends StatefulWidget {
  NewOrder? order;

  OrderDetailsScreen({
    super.key,
    this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String orderDateRead(DateTime orderDateTime) {
    String formattedOrderTime = DateFormat('MMMM d, y h:mm a').format(orderDateTime);
    return formattedOrderTime;
  }

  bool showItems = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        foregroundColor: Colors.white,
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      backgroundColor: gray5,
      body: StreamBuilder<DocumentSnapshot>(
        stream: firebaseFirestore
            .collection('active_orders')
            .doc('${widget.order!.orderID}')
            .snapshots(),
        builder: (context, orderSnapshot) {
          if(orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          } else if(orderSnapshot.hasError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.empty(PhosphorIconsStyle.regular),
                  size: 48,
                  color: Colors.grey,
                ),
                Text(
                  'Error: ${orderSnapshot.error}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          } else if(orderSnapshot.hasData && orderSnapshot.data!.exists) {
            NewOrder order = NewOrder.fromJson(
              orderSnapshot.data!.data() as Map<String, dynamic>,
            );

            return SingleChildScrollView(
              child: Column(
                children: [
                  //Order Information
                  orderInfoContainer(
                    context: context,
                    orderStatus: order.orderStatus!,
                    orderID: order.orderID!,
                    orderTime: order.orderTime!.toDate(),
                  ),
                  const SizedBox(height: 4,),
                  //User Information
                  storeUserInfoContainer(
                    context: context,
                    icon: PhosphorIcons.mapPin(PhosphorIconsStyle.bold),
                    name: order.userName!,
                    phone: order.userPhone!,
                    address: order.userAddress!,
                  ),
                  const SizedBox(height: 4,),
                  //Store Information
                  storeUserInfoContainer(
                    context: context,
                    icon: PhosphorIcons.storefront(PhosphorIconsStyle.bold),
                    name: order.storeName!,
                    phone: order.storePhone!,
                    address: order.storeAddress!,
                  ),
                  //Rider Information
                  if(order.riderName != null) ...[
                    const SizedBox(height: 4,),
                    riderInfoContainer(
                      icon: PhosphorIcons.moped(PhosphorIconsStyle.bold),
                      name: order.riderName!,
                      phone: order.riderPhone!,
                    ),
                  ],
                  const SizedBox(height: 4,),
                  //Payment Method
                  paymentMethodInfoContainer(context),
                  const SizedBox(height: 4,),
                  //Item List
                  // const SizedBox(height: 4,),
                  itemList(
                    items: order.items!,
                    listLimit: showItems ? order.items!.length : 0,
                  ),
                  ElevatedButton(onPressed: () {
                    setState(() {
                      if(showItems) {
                        setState(() {
                          showItems = false;
                        });
                      } else {
                        setState(() {
                          showItems = true;
                        });
                      }
                    });
                  }, child: Text('Show Items')),
                ],
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.empty(PhosphorIconsStyle.regular),
                  size: 48,
                  color: Colors.grey,
                ),
                const Text(
                  'No order exist',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextButton(
            onPressed: () {
            },
            child: const Text(
              'Complete Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget orderInfoContainer({BuildContext? context, required String orderStatus,required String orderID, required DateTime orderTime}) {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Order Icon
        Icon(
          PhosphorIcons.package(PhosphorIconsStyle.bold),
          size: 24,
          color: Theme.of(context!).primaryColor,
        ),
        const SizedBox(width: 16,),
        //orderStatus, orderID, orderTime
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            //Order Status Widget
            orderStatusWidget(orderStatus),
            const SizedBox(height: 4,),
            //Order ID
            Text(
              orderID.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
            //Order Time
            Text(
              orderDateRead(orderTime),
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget storeUserInfoContainer({BuildContext? context, required IconData icon, required String name, required String phone, required String address}) {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Icon
        Icon(
          icon,
          size: 24,
          color: Theme.of(context!).primaryColor,
        ),
        const SizedBox(width: 16,),
        //User/Store Name, User/Store Phone, User/Store Address
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //Name
              Text(
                name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              //Phone
              Text(
                phone,
                style: TextStyle(
                  fontSize: 16,
                  color: gray,
                ),
              ),
              //Address
              Text(
                address,
                style: TextStyle(
                  fontSize: 16,
                  color: gray,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget riderInfoContainer({BuildContext? context, required IconData icon, required String name, required String phone}) {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Icon
        Icon(
          icon,
          size: 24,
          color: Theme.of(context!).primaryColor,
        ),
        const SizedBox(width: 16,),
        //User/Store Name, User/Store Phone, User/Store Address
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //Name
              Text(
                name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              //Phone
              Text(
                phone,
                style: TextStyle(
                  fontSize: 16,
                  color: gray,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget paymentMethodInfoContainer(BuildContext? context) {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Payment Method Text
        const Text(
          'Payment Method',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
          ),
        ),
        //Credit Cart Icon and Cash on Delivery
        Row(
          children: [
            //Credit Cart Icon
            Icon(
              PhosphorIcons.creditCard(PhosphorIconsStyle.bold),
              color: Theme.of(context!).primaryColor,
            ),
            const SizedBox(width: 8,),
            //Cash on Delivery
            Text(
              'Cash on Delivery',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget itemList({required List<AddToCartItem> items, required int listLimit}) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Item(s) Text
        Text(
          '${items.length} Item(s)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listLimit,
          itemBuilder: (context, index) {
            return ListTile(
              minVerticalPadding: 2,
              minTileHeight: 50,
              contentPadding: const EdgeInsets.all(0),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: items[index].itemImageURL != null
                  ? SizedBox(
                    width: 60,
                    height: 70,
                    child: CachedNetworkImage(
                      imageUrl: '${items[index].itemImageURL}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 60,
                          height: 70,
                          color: Colors.white,
                          child: const Center(
                            child: Icon(Icons.image),
                          ),
                        ),
                      ),
                    ),
                  )
                  : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 215, 219, 221),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color.fromARGB(255, 215, 219, 221),
                    ),
                ),
              ),
              title: Text(
                '${items[index].itemName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₱ ${items[index].itemPrice!.toStringAsFixed(2)}'),
                  Text(
                    '₱ ${items[index].itemTotal!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                'x${items[index].itemQnty}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}



