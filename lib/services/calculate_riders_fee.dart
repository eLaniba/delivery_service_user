import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/services/get_distance_from_google_maps.dart';

Future<double> calculateRidersFee({
  required GeoPoint storeLocation,
  required GeoPoint userLocation,
  required double baseFee,
  required double perKmFee,
}) async {
  double distanceKm = await getDistanceFromGoogleMaps(
    storeLocation: storeLocation,
    userLocation: userLocation,
  );
  //
  // baseFee = 15.0; // Fixed rate for the first 1 km
  // perKmFee = 5.0; // ₱5 for each additional km

  double additionalFee = (distanceKm > 1) ? (distanceKm - 1) * perKmFee : 0.0;
  print('ridersTotal is ${baseFee + additionalFee}');
  return baseFee + additionalFee.ceilToDouble();

}
