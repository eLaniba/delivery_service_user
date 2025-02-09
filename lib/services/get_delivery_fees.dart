import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, double>> getDeliveryFees() async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('appConfig')
      .doc('deliveryFees')
      .get();

  if (snapshot.exists) {
    return {
      "baseFee": snapshot["baseFee"].toDouble(),
      "perKmFee": snapshot["perKmFee"].toDouble(),
      "serviceFee": snapshot["serviceFee"].toDouble(),
    };
  } else {
    // Return default values if Firestore data is missing
    return {
      "baseFee": 15.0,
      "perKmFee": 5.0,
      "serviceFee": 7.0,
    };
  }
}
