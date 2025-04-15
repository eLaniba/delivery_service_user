import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/mainScreens/order_screen/live_location_tracking_page.dart';
import 'package:delivery_service_user/mainScreens/order_screen/modify_order/modify_order_main.dart';
import 'package:delivery_service_user/mainScreens/order_screen/rate_screen.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/messages_screen_2.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/report_page.dart';
import 'package:delivery_service_user/widgets/show_floating_toast.dart';
import 'package:delivery_service_user/widgets/status_widget.dart';
import 'package:delivery_service_user/widgets/time_limit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

class OrderDetailsProviderScreen extends StatefulWidget {

  const OrderDetailsProviderScreen({Key? key})
      : super(key: key);

  @override
  State<OrderDetailsProviderScreen> createState() =>
      _OrderDetailsProviderScreenState();
}

class _OrderDetailsProviderScreenState extends State<OrderDetailsProviderScreen> {
  List<String> orderCompleteStatus = ['Delivered', 'Completing', 'Completed'];
  bool showItems = false;


  void completeOrderDialog(NewOrder order) {
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
            'By pressing this button, you confirm that you have paid the full amount for your order and that you have received the items from the rider. \n\nPlease ensure all details are correct before confirming.',
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 25),
                // Confirm
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    confirmDelivery(order);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  child: const SizedBox(
                    width: 56,
                    child: Center(child: Text('Confirm')),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmDelivery(NewOrder order) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LoadingDialog(
          message: 'Confirming order',
        );
      },
    );

    DocumentReference orderDocument = firebaseFirestore
        .collection('active_orders')
        .doc('${order.orderID}');
    try {
      await orderDocument.update({
        'userConfirmDelivery': true,
      });
    } catch (e) {
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
                  SizedBox(height: 20),
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
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => const MainScreen()));
    });
  }

  void sendMessage(String name, String id, String imageURL, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesScreen2(
          partnerName: name,
          partnerID: id,
          imageURL: imageURL,
          partnerRole: role,
        ),
      ),
    );
  }

  void cancelOrder(String orderID) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LoadingDialog(
          message: 'Cancelling order',
        );
      },
    );

    DocumentReference orderDocument = firebaseFirestore
        .collection('active_orders')
        .doc(orderID);

    try {
      await orderDocument.update({
        'orderStatus': 'Cancelled',
      });
    } catch (e) {
      showFloatingToast(context: context, message: 'Error occurred, please try again.');
    }

    //Close loading dialog
    Navigator.pop(context);

    //Show Toast for Cancellation Success
    showFloatingToast(context: context, message: 'Order successfully cancelled', backgroundColor: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the order from the Provider.
    final order = Provider.of<NewOrder?>(context);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (order.orderStatus == 'Delivering')
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => LiveLocationTrackingPage(order: order),
                  ),
                );
              },
              icon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill)),
            ),
          // if (order.orderStatus == 'Pending' || order.orderStatus == 'Preparing')
          //   TextButton(
          //     onPressed: () async {
          //       bool? isConfirm = await ConfirmationDialog.show(context, 'Do you want to cancel the order?');
          //
          //       if(isConfirm == true) {
          //         cancelOrder(order.orderID!);
          //       }
          //     },
          //     style: TextButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(30),
          //       ),
          //     ),
          //     child: const Text(
          //       'Cancel',
          //       style: TextStyle(color: Colors.white, fontSize: 16),
          //     ),
          //   ),
          //TODO: Add or statement
          if (orderCompleteStatus.contains(order.orderStatus) && order.rate == null)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RateScreen(order: order,),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Rate',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: gray5,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Information & Rider Info
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                orderInfoContainer(
                  context: context,
                  orderStatus: order.orderStatus!,
                  orderID: order.orderID!,
                  orderTime: order.orderTime!.toDate(),
                ),
                if (order.riderName != null && order.riderPhone != null) ...[
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      riderInfoContainer(
                        onTap: () {
                          sendMessage(
                            order.riderName!,
                            order.riderID!,
                            order.riderProfileURL!,
                            'rider',
                          );
                        },
                        context: context,
                        icon: PhosphorIcons.moped(PhosphorIconsStyle.bold),
                        name: order.riderName!,
                        phone: reformatPhoneNumber(order.riderPhone!),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportPage(
                                  id: order.riderID!,
                                  type: 'rider',
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: const Text(
                            'Report',
                            style: TextStyle(
                              color: grey20,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            // User Information
            storeUserInfoContainer(
              context: context,
              icon: PhosphorIcons.user(PhosphorIconsStyle.bold),
              name: '${order.userName!} (You)',
              phone: reformatPhoneNumber(order.userPhone!),
              address: order.userAddress!,
            ),
            const SizedBox(height: 4),
            // Store Information
            Stack(
              children: [
                storeUserInfoContainer(
                  context: context,
                  onTap: () {
                    sendMessage(
                      order.storeName!,
                      order.storeID!,
                      order.storeProfileURL!,
                      'store',
                    );
                  },
                  icon: PhosphorIcons.storefront(PhosphorIconsStyle.bold),
                  name: order.storeName!,
                  phone: reformatPhoneNumber(order.storePhone!),
                  address: order.storeAddress!,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportPage(id: order.storeID!, type: 'store',),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: const Text(
                      'Report',
                      style: TextStyle(color: grey20, fontSize: 14, ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Payment Method
            paymentMethodInfoContainer(context, order.paymentMethod!),
            const SizedBox(height: 4),
            // Items Header and "View all" toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items!.length} Item(s)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  order.items!.length > 3
                      ? TextButton(
                    onPressed: () {
                      if (!showItems) {
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
                    child: Text(
                      showItems ? '' : 'View all',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                      : TextButton(
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
            // Item List
            Column(
              children: [
                itemList(
                  items: order.items!,
                  listLimit: showItems
                      ? order.items!.length
                      : (order.items!.length > 3 ? 3 : order.items!.length),
                ),
                //Add Item
                if(order.orderStatus == 'Preparing')
                  InkWell(
                    onTap: () async {
                      int? timeLimit = await TimeLimitDialog.show(context);

                      if (timeLimit != null) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (c) => ModifyOrderMain(minutes: timeLimit, storeID: order.storeID!,)));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Add Item',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Order Total
            orderTotal(
              context: context,
              subTotal: order.subTotal!,
              ridersFee: order.riderFee!,
              serviceFee: order.serviceFee!,
              orderTotal: order.orderTotal!,
            ),
            //Cancel Order
            if(order.orderStatus == 'Pending')
              InkWell(
              onTap: () async {
                bool? isConfirm = await ConfirmationDialog.show(context, 'Are you sure you want to cancel this order?');

                if (isConfirm == true) {
                  cancelOrder(order.orderID!);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cancel Order',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: order.orderStatus == 'Cancelled'
            ? Container(
                height: 60,
                decoration: BoxDecoration(
                  color: grey20,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'Cancelled Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            : order.orderStatus != 'Delivering' && !orderCompleteStatus.contains(order.orderStatus)
            ? Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: grey20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Complete Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
            : orderCompleteStatus.contains(order.orderStatus)
            ? Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.sealCheck(
                                    PhosphorIconsStyle.fill),
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Text(
                                'Order Completed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
            : Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextButton(
                          onPressed: () {
                            completeOrderDialog(order);
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

Widget orderInfoContainer({
  BuildContext? context,
  required String orderStatus,
  required String orderID,
  required DateTime orderTime,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Order Icon
        Icon(
          PhosphorIcons.package(PhosphorIconsStyle.bold),
          size: 24,
          color: Theme.of(context!).primaryColor,
        ),
        const SizedBox(width: 16),
        // Order status, orderID, orderTime
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            orderStatusWidget(orderStatus),
            const SizedBox(height: 4),
            Text(
              orderID.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              orderDateRead(orderTime),
              style: const TextStyle(
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

Widget storeUserInfoContainer({
  BuildContext? context,
  required IconData icon,
  required String name,
  required String phone,
  required String address,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context!).primaryColor,
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 16,
                    color: gray,
                  ),
                ),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 16,
                    color: gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget riderInfoContainer({
  BuildContext? context,
  required IconData icon,
  required String name,
  required String phone,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context!).primaryColor,
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 16,
                    color: gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget paymentMethodInfoContainer(BuildContext? context, String paymentMethod) {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if(paymentMethod == 'cod')
          Row(
          children: [
            Icon(
              PhosphorIcons.wallet(PhosphorIconsStyle.bold),
              color: Theme.of(context!).primaryColor,
            ),
            const SizedBox(width: 8),
            const Text(
              'Cash on Delivery',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
            ),
          ],
        ),
        if(paymentMethod == 'paymongo')
          Row(
            children: [
              Icon(
                PhosphorIcons.creditCard(PhosphorIconsStyle.bold),
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              const Text(
                'Paymongo (PAID)',
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
                  fontWeight: FontWeight.bold,
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

Widget orderTotal({
  required BuildContext context,
  required double subTotal,
  required double ridersFee,
  required serviceFee,
  required orderTotal,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subtotal',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Rider\'s fee',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Service fee',
              style: TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₱ ${subTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '₱ ${ridersFee.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '₱ ${serviceFee.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: gray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
