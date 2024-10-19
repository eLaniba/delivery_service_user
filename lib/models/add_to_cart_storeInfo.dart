class AddToCartStoreInfo {
  //Seller Info
  String? sellerUID;
  String? sellerName;
  String? phone;
  String? address;

  AddToCartStoreInfo({
    this.sellerUID,
    this.sellerName,
    this.phone,
    this.address,
  });

  AddToCartStoreInfo.fromJson(Map<String, dynamic> json) {
    sellerUID = json["sellerUID"];
    sellerName = json["sellerName"];
    phone = json["phone"];
    address = json["address"];
  }
}