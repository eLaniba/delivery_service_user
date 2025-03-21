import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? status;
  String? userAddress;
  String? userEmail;
  String? userID;
  String? userProfileURL;
  String? userProfilePath;
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
    this.userProfileURL,
    this.userProfilePath,
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
    userProfileURL = json["userProfileURL"];
    userProfilePath = json["userProfilePath"];
    userLocation = json["userLocation"];
    userName = json["userName"];
    userPhone = json["userPhone"];
    emailVerified = json["emailVerified"];
    phoneVerified = json["phoneVerified"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["status"] = status;
    data["userAddress"] = userAddress;
    data["userEmail"] = userEmail;
    data["userID"] = userID;
    data["userProfileURL"] = userProfileURL;
    data["userProfilePath"] = userProfilePath;
    data["userLocation"] = userLocation;
    data["userName"] = userName;
    data["userPhone"] = userPhone;
    data["emailVerified"] = emailVerified;
    data["phoneVerified"] = phoneVerified;
    return data;
  }

  Map<String, dynamic> addStoreToCart() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["status"] = status;
    data["userAddress"] = userAddress;
    data["userEmail"] = userEmail;
    data["userID"] = userID;
    data["userProfileURL"] = userProfileURL;
    data["userProfilePath"] = userProfilePath;
    data["userLocation"] = userLocation;
    data["userName"] = userName;
    data["userPhone"] = userPhone;
    data["emailVerified"] = emailVerified;
    data["phoneVerified"] = phoneVerified;
    return data;
  }
}