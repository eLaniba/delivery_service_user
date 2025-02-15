import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/live_location_tracking_page.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/status_widget.dart';
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
  bool showItems = false;

  void completeOrderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          title: const Text('Confirm Delivery?'),
          content: const Text(
              'By pressing this button, you confirm that you have paid the full amount for your order and that you have received the items from the rider. \n\nPlease ensure all details are correct before confirming.'
            // textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //Cancel
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 25,),
                //Confirm
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    confirmDelivery();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 56,
                      child: Center(child: Text('Confirm')),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text(
                "Requesting confirmation from the customer, please wait...",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> confirmDelivery() async {
    showDialog(context: context, builder: (BuildContext context) {
      return const LoadingDialog(
        message: 'Confirming order',
      );
    });

    DocumentReference orderDocument = firebaseFirestore.collection('active_orders').doc('${widget.order!.orderID}');
    try{
      await orderDocument.update({
        'userConfirmDelivery': true,
      });
    } catch(e) {
      rethrow;
    }

    Navigator.pop(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    size: 50,
                  ),
                  SizedBox(height: 20,),
                  Text(
                    "Order complete! Thank you for your purchase!",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.order != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            StreamBuilder<DocumentSnapshot>(
              stream: firebaseFirestore
                  .collection('active_orders')
                  .doc('${widget.order!.orderID}')
                  .snapshots(),
              builder: (context, orderSnapshot) {
                if(orderSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                } else if(orderSnapshot.hasError) {
                  return const SizedBox();
                } else if(orderSnapshot.hasData && orderSnapshot.data!.exists) {
                  NewOrder order = NewOrder.fromJson(
                    orderSnapshot.data!.data() as Map<String, dynamic>,
                  );

                  if(order.orderStatus == 'Delivering') {
                    return IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => LiveLocationTrackingPage(order: widget.order!),
                          ),
                        );
                      },
                      icon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill)),
                    );
                  } else {
                    return const SizedBox();
                  }
                } else {
                  return const SizedBox();
                }
              },
            ),
            const SizedBox(width: 16,),
          ],
        ),
        backgroundColor: gray5,
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<DocumentSnapshot>(
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

                    // Check if there's an Assigned Rider
                    bool hasRiderInfo = order.riderName != null && order.riderPhone != null;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        orderInfoContainer(
                            context: context,
                            orderStatus: order.orderStatus!,
                            orderID: order.orderID!,
                            orderTime: order.orderTime!.toDate()
                        ),
                        if (hasRiderInfo) ...[
                          const SizedBox(height: 4,),
                          riderInfoContainer(
                            context: context,
                            icon: PhosphorIcons.moped(PhosphorIconsStyle.bold),
                            name: order.riderName!,
                            phone: order.riderPhone!,
                          ),
                        ]
                      ],
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
              const SizedBox(height: 4,),
              //User Information
              storeUserInfoContainer(
                context: context,
                icon: PhosphorIcons.mapPin(PhosphorIconsStyle.bold),
                name: widget.order!.userName!,
                phone: widget.order!.userPhone!,
                address: widget.order!.userAddress!,
              ),
              const SizedBox(height: 4,),
              //Store Information
              storeUserInfoContainer(
                context: context,
                icon: PhosphorIcons.storefront(PhosphorIconsStyle.bold),
                name: widget.order!.storeName!,
                phone: widget.order!.storePhone!,
                address: widget.order!.storeAddress!,
              ),
              const SizedBox(height: 4,),
              //Payment Method
              paymentMethodInfoContainer(context),
              const SizedBox(height: 4,),
              //Item(s) and View Text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.order!.items!.length} Item(s)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    widget.order!.items!.length > 3 ?
                      TextButton(
                      onPressed: () {
                        if(showItems == false) {
                          setState(() {
                            showItems = true;
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(showItems == false
                          ? 'View all'
                          : ' ',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ) :
                      TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(''),
                    )
                  ],
                ),
              ),
              //Item List
              // const SizedBox(height: 4,),
              itemList(
                items: widget.order!.items!,
                listLimit: showItems
                    ? (widget.order?.items?.length ?? 0) // Show all items if showItems is true
                    : ((widget.order?.items?.length ?? 0) > 3 ? 3 : (widget.order?.items?.length ?? 0)), // Show up to 3 items
              ),
              const SizedBox(height: 4,),
              orderTotal(
                context: context,
                orderTotal: widget.order!.orderTotal!,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: StreamBuilder<DocumentSnapshot>(
              stream: firebaseFirestore
                  .collection('active_orders')
                  .doc('${widget.order!.orderID}')
                  .snapshots(),
              builder: (context, orderSnapshot) {
                if(orderSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(),);
                } else if (orderSnapshot.hasData && orderSnapshot.data!.exists) {
                  NewOrder order = NewOrder.fromJson(
                    orderSnapshot.data!.data() as Map<String, dynamic>,
                  );
                  if (order.orderStatus != 'Delivering'){
                    return Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: grey20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child:  Text(
                          'Complete Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextButton(
                        onPressed: () {
                          completeOrderDialog();
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
                    );
                  }
                }
                return const SizedBox();
              }
          ),
        ),
      );
    } else {
      return Placeholder();
    }
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
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

Widget orderTotal({required BuildContext context, required double orderTotal}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Subtotal, Rider's Fee, Order Total text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Subtotal Text
            Text(
              'Subtotal',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            //Rider's fee Text
            Text(
              'Rider\'s fee',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            //Order Total Text
            const Text(
              'Order Total',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        //Prices
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //Subtotal Text
            Text(
              '₱ ${orderTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            //Rider's fee Text
            Text(
              '₱ 0.00',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            //Order Total Text
            Text(
              '₱ ${orderTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )
      ],
    ),
  );
}



