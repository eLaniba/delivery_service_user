class AddToCartStoreInfo {
  //Seller Info
  String? storeID;
  String? storeName;
  String? storePhone;
  String? storeAddress;

  AddToCartStoreInfo({
    this.storeID,
    this.storeName,
    this.storePhone,
    this.storeAddress,
  });

  AddToCartStoreInfo.fromJson(Map<String, dynamic> json) {
    storeID = json["storeID"];
    storeName = json["storeName"];
    storePhone = json["storePhone"];
    storeAddress = json["storeAddress"];
  }


}