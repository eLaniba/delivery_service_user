import 'package:cloud_firestore/cloud_firestore.dart';

class Stores {
  String? storeID;
  String? storeName;
  String? storeImageURL;
  String? storePhone;
  String? storeAddress;
  GeoPoint? storeLocation;

  Stores({
    this.storeID,
    this.storeName,
    this.storeImageURL,
    this.storePhone,
    this.storeAddress,
    this.storeLocation,
  });

  Stores.fromJson(Map<String, dynamic> json) {
    storeID = json["storeID"];
    storeName = json["storeName"];
    storeImageURL = json["storeImageURL"];
    storePhone = json["storePhone"];
    storeAddress = json["storeAddress"];
    storeLocation = json["storeLocation"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["storeID"] = this.storeID;
    data["storeName"] = this.storeName;
    data["storeImageURL"] = this.storeImageURL;
    data["storePhone"] = this.storePhone;
    data["storeAddress"] = this.storeAddress;
    data["storeLocation"] = this.storeLocation;
    return data;
  }

  Map<String, dynamic> addStoreToCart() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["storeID"] = this.storeID;
    data["storeName"] = this.storeName;
    data["storeImageURL"] = this.storeImageURL;
    data["storePhone"] = this.storePhone;
    data["storeAddress"] = this.storeAddress;
    data["storeLocation"] = this.storeLocation;
    return data;
  }
}