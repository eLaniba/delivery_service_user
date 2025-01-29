class Category {
  String? categoryID;
  String? categoryName;
  String? categoryImageURL;
  String? categoryImagePath;

  Category({
    this.categoryID,
    this.categoryName,
    this.categoryImageURL,
    this.categoryImagePath,
  });

  Category.fromJson(Map<String, dynamic> json) {
    categoryID = json['categoryID'];
    categoryName = json['categoryName'];
    categoryImageURL = json['categoryImageURL'];
    categoryImagePath = json['categoryImagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryID'] = categoryID;
    data['categoryName'] = categoryName;
    data['categoryImageURL'] = categoryImageURL;
    data['categoryImagePath'] = categoryImagePath;
    return data;
  }
}

class Item {
  String? categoryID;
  String? itemID;
  String? itemName;
  double? itemPrice;
  int? itemStock;
  String? itemImagePath;
  String? itemImageURL;

  Item({
    this.categoryID,
    this.itemID,
    this.itemName,
    this.itemPrice,
    this.itemStock,
    this.itemImagePath,
    this.itemImageURL,
  });

  Item.fromJson(Map<String, dynamic> json) {
    categoryID = json['categoryID'];
    itemID = json['itemID'];
    itemName = json['itemName'];
    itemPrice = json['itemPrice'];
    itemStock = json['itemStock'];
    itemImagePath = json['itemImagePath'];
    itemImageURL = json['itemImageURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryID'] = this.categoryID;
    data['itemID'] = this.itemID;
    data['itemName'] = this.itemName;
    data['itemPrice'] = this.itemPrice;
    data['itemStock'] = this.itemStock;
    data['itemImagePath'] = this.itemImagePath;
    data['itemImageURL'] = this.itemImageURL;
    return data;
  }
}