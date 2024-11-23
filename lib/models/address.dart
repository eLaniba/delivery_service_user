import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  String? addressID;
  String? addressEng;
  GeoPoint? location;

  Address({
    this.addressID,
    this.addressEng,
    this.location,
  });

  Address.fromJson(Map<String, dynamic> json) {
    addressID = json['addressID'];
    addressEng = json['addressEng'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addressID'] = addressID;
    data['addressEng'] = addressEng;
    data['location'] = location;
    return data;
  }
}