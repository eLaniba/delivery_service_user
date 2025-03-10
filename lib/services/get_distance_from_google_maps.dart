import 'package:delivery_service_user/global/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for GeoPoint

Future<double> getDistanceFromGoogleMaps({
  required GeoPoint storeLocation,
  required GeoPoint userLocation,
}) async {
  String url = "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=${storeLocation.latitude},${storeLocation.longitude}"
      "&destination=${userLocation.latitude},${userLocation.longitude}"
      "&key=$apiKey";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);

    if (jsonData["routes"].isNotEmpty) {
      // Extract distance in meters and convert to KM
      double distanceMeters = (jsonData["routes"][0]["legs"][0]["distance"]["value"] as num).toDouble();
      print('Distance Meter is ${distanceMeters}');
      return distanceMeters / 500; // Convert meters to km
      return distanceMeters / 1000; // Convert meters to km
    }
  }

  return 0.0; // Default to 0 if API fails
}
