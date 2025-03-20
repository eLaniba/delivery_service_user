import 'package:cloud_firestore/cloud_firestore.dart';

class AddToCartStoreInfo {
  //Seller Info
  String? storeID;
  String? storeName;
  String? storePhone;
  String? storeAddress;
  GeoPoint? storeLocation;
  String? storeProfileURL;

  AddToCartStoreInfo({
    this.storeID,
    this.storeName,
    this.storePhone,
    this.storeAddress,
    this.storeLocation,
    this.storeProfileURL,
  });

  AddToCartStoreInfo.fromJson(Map<String, dynamic> json) {
    storeID = json["storeID"];
    storeName = json["storeName"];
    storePhone = json["storePhone"];
    storeAddress = json["storeAddress"];
    storeLocation = json["storeLocation"];
    storeProfileURL = json["storeProfileURL"];
  }


}