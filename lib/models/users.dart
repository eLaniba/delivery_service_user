import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? status;
  String? userAddress;
  String? userEmail;
  String? userID;
  String? userImageURL;
  GeoPoint? userLocation;
  String? userName;
  String? userPhone;
  bool? emailVerified;
  bool? phoneVerified;

  Users({
    this.status,
    this.userAddress,
    this.userEmail,
    this.userID,
    this.userImageURL,
    this.userLocation,
    this.userName,
    this.userPhone,
    this.emailVerified,
    this.phoneVerified,
  });

  Users.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    userAddress = json["userAddress"];
    userEmail = json["userEmail"];
    userID = json["userID"];
    userImageURL = json["userImageURL"];
    userLocation = json["userLocation"];
    userName = json["userName"];
    userPhone = json["userPhone"];
    emailVerified = json["emailVerified"];
    phoneVerified = json["phoneVerified"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["status"] = this.status;
    data["userAddress"] = this.userAddress;
    data["userEmail"] = this.userEmail;
    data["userID"] = this.userID;
    data["userImageURL"] = this.userImageURL;
    data["userLocation"] = this.userLocation;
    data["userName"] = this.userName;
    data["userPhone"] = this.userPhone;
    data["emailVerified"] = this.emailVerified;
    data["phoneVerified"] = this.phoneVerified;
    return data;
  }

  Map<String, dynamic> addStoreToCart() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["status"] = this.status;
    data["userAddress"] = this.userAddress;
    data["userEmail"] = this.userEmail;
    data["userID"] = this.userID;
    data["userImageURL"] = this.userImageURL;
    data["userLocation"] = this.userLocation;
    data["userName"] = this.userName;
    data["userPhone"] = this.userPhone;
    data["emailVerified"] = this.emailVerified;
    data["phoneVerified"] = this.phoneVerified;
    return data;
  }
}