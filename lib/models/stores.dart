import 'package:cloud_firestore/cloud_firestore.dart';

class Stores {
  String? storeID;
  String? storeName;
  String? storeProfileURL;
  String? storeCoverURL;
  String? storePhone;
  String? storeAddress;
  GeoPoint? storeLocation;

  Stores({
    this.storeID,
    this.storeName,
    this.storeProfileURL,
    this.storeCoverURL,
    this.storePhone,
    this.storeAddress,
    this.storeLocation,

  });

  Stores.fromJson(Map<String, dynamic> json) {
    storeID = json["storeID"];
    storeName = json["storeName"];
    storeProfileURL = json["storeProfileURL"];
    storeCoverURL = json["storeCoverURL"];
    storePhone = json["storePhone"];
    storeAddress = json["storeAddress"];
    storeLocation = json["storeLocation"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["storeID"] = storeID;
    data["storeName"] = storeName;
    data["storeProfileURL"] = storeProfileURL;
    data["storeCoverURL"] = storeCoverURL;
    data["storePhone"] = storePhone;
    data["storeAddress"] = storeAddress;
    data["storeLocation"] = storeLocation;
    return data;
  }

  Map<String, dynamic> addStoreToCart() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["storeID"] = storeID;
    data["storeName"] = storeName;
    data["storeProfileURL"] = storeProfileURL;
    // data["storeCoverURL"] = storeCoverURL;
    data["storePhone"] = storePhone;
    data["storeAddress"] = storeAddress;
    data["storeLocation"] = storeLocation;
    return data;
  }
}