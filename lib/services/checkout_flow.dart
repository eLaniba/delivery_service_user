// checkout_flow.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';
import 'package:delivery_service_user/models/add_to_cart_storeInfo.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// For storing user data
import 'package:shared_preferences/shared_preferences.dart';

/// A helper class that encapsulates the checkout flow
/// for Cash on Delivery or E-wallets/Cards (via PayMongo Payment Link)
class CheckoutFlow {
  // PayMongo test secret key - for sandbox/demo only.
  // In production, keep this on a secure server, not in the client app.
  static const String _paymongoSecretKey = 'sk_test_bFe9sizt3PoC3jFwStqaQhGW';
  static const String _paymongoBaseUrl = 'https://api.paymongo.com/v1';

  final BuildContext context;
  final AddToCartStoreInfo storeInfo;
  final List<AddToCartItem> items;
  final double subTotal;
  final double riderFee;
  final double serviceFee;
  final double orderTotal;

  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final SharedPreferences sharedPreferences;

  CheckoutFlow({
    required this.context,
    required this.storeInfo,
    required this.items,
    required this.subTotal,
    required this.riderFee,
    required this.serviceFee,
    required this.orderTotal,
    required this.firestore,
    required this.storage,
    required this.sharedPreferences,
  });

  /// Call this from your Checkout screen's "Confirm Order" button,
  /// passing 'cod' or 'paymongo_link'.
  Future<void> startCheckout(String paymentMethod) async {
    debugPrint('startCheckout: $paymentMethod');
    if (paymentMethod == 'cod') {
      await _startCODFlow();
    } else if (paymentMethod == 'paymongo_link') {
      await _startPaymentLinkFlow();
    } else {
      debugPrint('Invalid payment method: $paymentMethod');
    }
  }

  // ---------------------------------------------------------------------------
  // 1) CASH ON DELIVERY FLOW
  // ---------------------------------------------------------------------------
  Future<void> _startCODFlow() async {
    debugPrint('_startCODFlow()');
    _placeOrderToFirestore(orderStatus: 'Pending');
  }

  // ---------------------------------------------------------------------------
  // 2) PAYMONGO PAYMENT LINK FLOW (E-wallets/Cards)
  // ---------------------------------------------------------------------------
  Future<void> _startPaymentLinkFlow() async {
    debugPrint('_startPaymentLinkFlow()');
    final int amountInCentavos = (orderTotal * 100).round();
    debugPrint('Amount in centavos: $amountInCentavos');

    // 1. Create Payment Link
    final linkData = await _createPaymentLink(amountInCentavos);
    if (linkData == null) {
      _showSnackBar('Failed to create Payment Link.');
      return;
    }

    final paymentLinkId = linkData['id'];
    final checkoutUrl = linkData['attributes']['checkout_url'];
    if (checkoutUrl == null) {
      _showSnackBar('No checkout URL found.');
      return;
    }
    debugPrint('Checkout URL: $checkoutUrl');

    // 2. Launch the checkout page in an external browser.
    final launched = await launchUrl(
      Uri.parse(checkoutUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      _showSnackBar('Could not open the payment page.');
      return;
    }

    bool paymentComplete = false;
    int maxAttempts = 150; // for example, polling for a maximum of 5 minutes
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      final paymentStatus = await _retrievePaymentLinkStatus(paymentLinkId);
      debugPrint('Polling attempt $attempt: status = $paymentStatus');
      if (paymentStatus == 'paid') {
        paymentComplete = true;
        break;
      }
    }

    if (paymentComplete) {
      _placeOrderToFirestore(orderStatus: 'Paid');
    } else {
      _showSnackBar('Payment not completed within the expected time.');
      Navigator.of(context).pop();
    }

  }

  // ---------------------------------------------------------------------------
  // HELPER METHODS
  // ---------------------------------------------------------------------------

  /// Creates a Payment Link in PayMongo
  Future<Map<String, dynamic>?> _createPaymentLink(int amountInCentavos) async {
    final url = Uri.parse('$_paymongoBaseUrl/links');
    final authHeader = _basicAuthHeader(_paymongoSecretKey);

    final requestBody = {
      'data': {
        'attributes': {
          'amount': amountInCentavos,
          'description': 'E-wallet/Card Checkout',
          // You can include additional parameters like remarks here.
        }
      }
    };

    try {
      debugPrint('Creating Payment Link - Body: ${jsonEncode(requestBody)}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Create Payment Link statusCode: ${response.statusCode}');
      debugPrint('Create Payment Link body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['data'];
      } else {
        debugPrint('Error creating Payment Link: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in _createPaymentLink: $e');
    }
    return null;
  }

  /// Retrieve Payment Link to check its status
  Future<String?> _retrievePaymentLinkStatus(String paymentLinkId) async {
    debugPrint('_retrievePaymentLinkStatus() - $paymentLinkId');
    final url = Uri.parse('$_paymongoBaseUrl/links/$paymentLinkId');
    final authHeader = _basicAuthHeader(_paymongoSecretKey);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
      );

      debugPrint('Retrieve Payment Link statusCode: ${response.statusCode}');
      debugPrint('Retrieve Payment Link body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return data['attributes']['status'];
      } else {
        debugPrint('Error retrieving Payment Link: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in _retrievePaymentLinkStatus: $e');
    }
    return null;
  }

  /// Places the order in Firestore, etc.
  Future<void> _placeOrderToFirestore({required String orderStatus}) async {
    showDialog(
      context: context,
      builder: (c) => const LoadingDialog(message: "Processing order"),
    );

    debugPrint('_placeOrderToFirestore() - status: $orderStatus');

    try {
      final userId = sharedPreferences.getString('uid') ?? '';
      final userName = sharedPreferences.getString('name') ?? '';
      final userPhone = sharedPreferences.getString('phone') ?? '';
      final userAddress = sharedPreferences.getString('address') ?? '';

      final newOrder = NewOrder(
        orderStatus: orderStatus,
        orderTime: Timestamp.now(),
        subTotal: subTotal,
        riderFee: riderFee,
        serviceFee: serviceFee,
        orderTotal: orderTotal,
        storeID: storeInfo.storeID,
        storeName: storeInfo.storeName,
        storePhone: storeInfo.storePhone,
        storeAddress: storeInfo.storeAddress,
        storeLocation: storeInfo.storeLocation,
        storeConfirmDelivery: false,
        items: items,
        userID: userId,
        userName: userName,
        userPhone: userPhone,
        userAddress: userAddress,
        userConfirmDelivery: false,
        userLocation: storeInfo.storeLocation,
      );

      // 1) Add to Firestore
      DocumentReference orderRef = await firestore
          .collection('active_orders')
          .add(newOrder.toJson());

      // 2) Save the generated orderID
      await orderRef.update({'orderID': orderRef.id});

      // 3) (Optional) Upload item images
      await _uploadItemImages(orderRef);

      // 4) Remove items from cart
      await _deleteItemsFromCart(userId, storeInfo.storeID!);

      Navigator.pop(context); // close loading dialog
      Navigator.pop(context); // close the checkout screen

      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      });
    } catch (e) {
      Navigator.pop(context); // close loading dialog
      debugPrint('Exception in _placeOrderToFirestore: $e');
      _showSnackBar('Failed to place order: $e');
    }
  }

  Future<void> _uploadItemImages(DocumentReference orderRef) async {
    debugPrint('_uploadItemImages()');
    final docSnapshot = await orderRef.get();
    List<dynamic> itemsFromFirestore = docSnapshot['items'];

    for (var item in itemsFromFirestore) {
      try {
        final imageURL = item['itemImageURL'];
        if (imageURL == null || imageURL.isEmpty) continue;

        final response = await http.get(Uri.parse(imageURL));
        if (response.statusCode == 200) {
          Uint8List imageData = response.bodyBytes;
          final destinationRef = storage
              .ref()
              .child('active_orders/${orderRef.id}/items/${item['itemID']}.jpg');
          await destinationRef.putData(imageData);
          final newImageUrl = await destinationRef.getDownloadURL();
          item['itemImageURL'] = newImageUrl;
        }
      } catch (e) {
        debugPrint('Image upload error: $e');
      }
    }

    // Write updated array back to Firestore
    await orderRef.update({'items': itemsFromFirestore});
  }

  Future<void> _deleteItemsFromCart(String userId, String storeID) async {
    debugPrint('_deleteItemsFromCart() - userId: $userId, storeID: $storeID');
    try {
      final storeDoc = firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(storeID);
      final itemsCollection = storeDoc.collection('items');

      final itemsSnapshot = await itemsCollection.get();
      for (var itemDoc in itemsSnapshot.docs) {
        await itemDoc.reference.delete();
      }

      await storeDoc.delete();
    } catch (e) {
      debugPrint('Error deleting items from cart: $e');
    }
  }

  void _showLoadingDialog(String message) {
    debugPrint('_showLoadingDialog: $message');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    debugPrint('_showSnackBar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _basicAuthHeader(String secretKey) {
    final bytes = utf8.encode('$secretKey:');
    return 'Basic ${base64Encode(bytes)}';
  }
}
