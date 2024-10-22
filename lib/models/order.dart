import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/add_to_cart_item.dart';

class Order{
  //Order Information
  String? orderStatus;
  String? orderID;
  Timestamp? orderTime;
  Timestamp? orderDelivered;
  String? orderTotal;


  //Store information
  String? storeID;
  String? storeName;
  String? storePhone;
  String? storeAddress;
  // double? storeLat;
  // double? storeLng;

  //
  List<AddToCartItem>? items;

  //User Information
  String? userID;
  String? userName;
  String? userPhone;
  String? userAddress;
  // double? userLat;
  // double? userLng;

  //Rider information
  String? riderID;
  String? riderName;
  String? riderPhone;

  //Constructor for Order
  Order({
    //Order Information
    this.orderStatus,
    this.orderID,
    this.orderTime,
    this.orderDelivered,
    this.orderTotal,

    //Store information
    this.storeID,
    this.storeName,
    this.storePhone,
    this.storeAddress,
    // this.storeLat,
    // this.storeLng,

    this.items,

    //User Information
    this.userID,
    this.userName,
    this.userPhone,
    this.userAddress,
    // this.userLat,
    // this.userLng,

    //Rider information
    this.riderID,
    this.riderName,
    this.riderPhone,
  });

  Order.fromJson(Map<String, dynamic> json) {
    orderStatus = json['orderStatus'];
    orderID = json['orderID'];
    orderTime = json['orderTime'];
    orderDelivered = json['orderDelivered'];
    orderTotal = json['orderTotal'];

    storeID = json['storeID'];
    storeName = json['storeName'];
    storePhone = json['storePhone'];
    storeAddress = json['storeAddress'];
    // storeLat = json['storeLat'];
    // storeLng = json['storeLng'];

    if (json['items'] != null) {
      items = List<AddToCartItem>.from(json['items'].map((item) => AddToCartItem.fromJson(item)));
    }

    userID = json['userID'];
    userName = json['userName'];
    userPhone = json['userPhone'];
    userAddress = json['userAddress'];
    // userLat = json['userLat'];
    // userLng = json['userLng'];

    riderID = json['riderID'];
    riderName = json['riderName'];
    riderPhone = json['riderPhone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderStatus'] = this.orderStatus;
    data['orderID'] = this.orderID;
    data['orderTime'] = this.orderTime;
    data['orderDelivered'] = this.orderDelivered;
    data['orderTotal'] = this.orderTotal;

    data['storeID'] = this.storeID;
    data['storeName'] = this.storeName;
    data['storePhone'] = this.storePhone;
    data['storeAddress'] = this.storeAddress;
    // data['storeLat'] = this.storeLat;
    // data['storeLng'] = this.storeLng;

    if (this.items != null) {
      data['items'] = this.items!.map((item) => item.toJson()).toList();
    }

    data['userID'] = this.userID;
    data['userName'] = this.userName;
    data['userPhone'] = this.userPhone;
    data['userAddress'] = this.userAddress;
    // data['userLat'] = this.userLat;
    // data['userLng'] = this.userLng;

    data['riderID'] = this.riderID;
    data['riderName'] = this.riderName;
    data['riderPhone'] = this.riderPhone;

    return data;
  }

}