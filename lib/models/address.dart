import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  String? addressEng;
  GeoPoint? location;

  Address({
    this.addressEng,
    this.location,
  });

  Address.fromJson(Map<String, dynamic> json) {
    addressEng = json['addressEng'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addressEng'] = addressEng;
    data['location'] = location;
    return data;
  }
}