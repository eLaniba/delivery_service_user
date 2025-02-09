import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/services/calculate_riders_fee.dart';
import 'package:delivery_service_user/services/get_delivery_fees.dart'; // Import Firestore fetching function

Future<double> calculateTotalPayment({
  required double cartTotal,
  required GeoPoint storeLocation,
  required GeoPoint userLocation,
}) async {
  // Fetch delivery fees from Firestore
  Map<String, double> fees = await getDeliveryFees();

  double riderFee = await calculateRidersFee(
    storeLocation: storeLocation,
    userLocation: userLocation,
  );

  double serviceFee = fees["serviceFee"]!; // Dynamic service fee from Firestore

  return cartTotal + riderFee + serviceFee;
}
