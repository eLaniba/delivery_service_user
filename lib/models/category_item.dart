class Category {
  String? categoryID;
  String? categoryName;

  Category({
    this.categoryID,
    this.categoryName,
  });

  Category.fromJson(Map<String, dynamic> json) {
    categoryID = json['categoryID'];
    categoryName = json['categoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryID'] = this.categoryID;
    data['categoryName'] = this.categoryName;
    return data;
  }
}

class Item {
  String? categoryID;
  String? itemID;
  String? itemName;
  double? itemPrice;
  String? itemImageURL;

  Item({
    this.categoryID,
    this.itemID,
    this.itemName,
    this.itemPrice,
    this.itemImageURL,
  });

  Item.fromJson(Map<String, dynamic> json) {
    categoryID = json['categoryID'];
    itemID = json['itemID'];
    itemName = json['itemName'];
    itemPrice = json['itemPrice'];
    itemImageURL = json['itemImageURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryID'] = this.categoryID;
    data['itemID'] = this.itemID;
    data['itemName'] = this.itemName;
    data['itemPrice'] = this.itemPrice;
    data['itemImageURL'] = this.itemImageURL;
    return data;
  }
}