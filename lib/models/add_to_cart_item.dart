class AddToCartItem {
  //Seller Item
  String? itemID;
  String? itemName;
  String? itemImagePath;
  String? itemImageURL;
  double? itemPrice;
  int? itemQnty;
  double? itemTotal;

  AddToCartItem({
    this.itemID,
    this.itemName,
    this.itemImagePath,
    this.itemImageURL,
    this.itemPrice,
    this.itemQnty,
    this.itemTotal,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemID'] = this.itemID;
    data['itemName'] = this.itemName;
    data['itemImagePath'] = this.itemImagePath;
    data['itemImageURL'] = this.itemImageURL;
    data['itemPrice'] = this.itemPrice;
    data['itemQnty'] = this.itemQnty;
    data['itemTotal'] = (this.itemPrice ?? 0) * (this.itemQnty ?? 0);
    return data;
  }

  AddToCartItem.fromJson(Map<String, dynamic> json) {
    itemID = json['itemID'];
    itemName = json['itemName'];
    itemImagePath = json['itemImagePath'];
    itemImageURL = json['itemImageURL'];
    itemPrice = json['itemPrice'];
    itemQnty = json['itemQnty'];
    itemTotal = json['itemTotal'];
  }
}

// //Seller Information
// String? sellerUID;
// String? sellerName;
// String? sellerPhone;
// String? sellerAddress;

// //User Information
// String? userID;
// String? userName;
// String? userPhone;