import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/live_location_tracking_page.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class OrderScreen2 extends StatefulWidget {
  OrderScreen2({
    super.key,
    this.orderDetail,
  });

  NewOrder? orderDetail;

  @override
  State<OrderScreen2> createState() => _OrderScreen2State();
}

class _OrderScreen2State extends State<OrderScreen2> {

  String orderDateRead() {
    DateTime orderTimeRead = widget.orderDetail!.orderTime!.toDate();

    String fromattedOrderTime = DateFormat('MMMM d, y h:mm a').format(orderTimeRead);
    return fromattedOrderTime;
  }

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

  // void completeOrder() {
  //   showDialog(context: context, builder: builder)
  //
  //   DocumentReference orderDocument = FirebaseFirestore.instance.collection('active_orders').doc('${widget.orderDetail!.orderID}');
  //   try{
  //     orderDocument.update({
  //       'riderConfirmDelivery': true,
  //     });
  //   } catch(e) {
  //     rethrow;
  //   }
  // }
  Future<void> confirmDelivery() async {
    showDialog(context: context, builder: (BuildContext context) {
      return const LoadingDialog(
        message: 'Confirming order',
      );
    });

    DocumentReference orderDocument = FirebaseFirestore.instance.collection('active_orders').doc('${widget.orderDetail!.orderID}');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(PhosphorIcons.package(PhosphorIconsStyle.regular)),
            padding: const EdgeInsets.all(0),
          ),

          if(widget.orderDetail!.orderStatus == 'Delivering')
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveLocationTrackingPage(
                      order: widget.orderDetail!, // Example destination
                    ),
                  ),
                );
              },
              icon: Icon(PhosphorIcons.mapTrifold(PhosphorIconsStyle.regular)),
              padding: const EdgeInsets.all(0),
            ),
            const SizedBox(width: 18,)
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('active_orders').doc('${widget.orderDetail!.orderID}').snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(
                        child: circularProgress(),
                      ),
                    );
                  }

                  if(!snapshot.hasData || !snapshot.data!.exists) {
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
                            'Error encounter, please try again',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  NewOrder order = NewOrder.fromJson(snapshot.data!.data() as Map<String, dynamic>);

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          //Order Information
                          Container(
                            // height: 140,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //Order Information Text
                                  const Text(
                                    'Order Information',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //Order Status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        child: Icon(
                                          Icons.circle,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Flexible(
                                        child: Text(
                                          '${widget.orderDetail!.orderStatus}',
                                          style:const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4,),
                                  //Order ID
                                  RichText(
                                    text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Order ID: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${widget.orderDetail!.orderID}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                  const SizedBox(height: 4,),
                                  //Order Time
                                  RichText(
                                    text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Order time: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: orderDateRead(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                  //Payment Method
                                  const Text(
                                    'Payment method',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //Cash on Delivery
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Icon(Icons.payment_rounded),
                                      Text(
                                        ' Cash on Delivery',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8,),
                                  const DottedLine(
                                    dashColor: Colors.grey,
                                    lineThickness: 2,
                                    dashLength: 10,
                                    dashGapLength: 4,
                                    dashRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Store Information
                          Container(
                            // height: 180,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //Order from Text
                                  const Text(
                                    'Order from',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //Store Name
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        child: Icon(
                                          Icons.storefront,
                                          // color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Flexible(
                                        child: Text(
                                          '${widget.orderDetail!.storeName}',
                                          style:const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        '${widget.orderDetail!.storePhone}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                  //Store Address
                                  Text(
                                    '${widget.orderDetail!.storeAddress}',
                                    style:const TextStyle(
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 14,),
                                  const DottedLine(
                                    dashColor: Colors.grey,
                                    lineThickness: 2,
                                    dashLength: 10,
                                    dashGapLength: 4,
                                    dashRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Rider Information
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Rider text
                                  const Text(
                                    'Rider',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  //Rider Icon, Name, and Phone
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        child: Icon(
                                          Icons.sports_motorsports_outlined,
                                          // color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Flexible(
                                        child: Text(
                                          widget.orderDetail!.riderID != null
                                              ? '${widget.orderDetail!.riderName}'
                                              : 'Processing...',
                                          style:const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),

                                      if (widget.orderDetail!.riderID != null)
                                        Text(
                                          '${widget.orderDetail!.riderPhone}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        )
                                      else
                                        const Text(''),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Item(s) text
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: const Row(
                              children: [
                                Text(
                                  'Item(s)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Fixed height ListView.builder
                          Container(
                            height: 250,
                            color: Colors.white,
                            child: ListView.builder(
                              itemCount: widget.orderDetail!.items!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: widget.orderDetail!.items![index].itemImageURL != null
                                          ? CachedNetworkImage(
                                        imageUrl: '${widget.orderDetail!.items![index].itemImageURL}',
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Center(
                                            child: Icon(
                                              PhosphorIcons.image(
                                                  PhosphorIconsStyle.fill),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                PhosphorIcons.imageBroken(
                                                    PhosphorIconsStyle.fill),
                                                color: Colors.grey,
                                                size: 48,
                                              ),
                                            ),
                                      )
                                          : Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          PhosphorIcons.imageBroken(
                                              PhosphorIconsStyle.fill),
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.orderDetail!.items![index].itemName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '₱ ${widget.orderDetail!.items![index].itemPrice!.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '₱ ${widget.orderDetail!.items![index].itemTotal!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const DottedLine(),
                                    ],
                                  ),
                                  trailing: Text(
                                    'x${widget.orderDetail!.items![index].itemQnty}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Total Order: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: "₱${widget.orderDetail!.orderTotal!.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                      ),
                    ),
                    const SizedBox(width: 16,),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          color: Colors.black,
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
        ),
      ),
    );
  }
}
