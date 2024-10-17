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
  String? itemID;
  String? itemName;
  double? itemPrice;

  Item({
    this.itemID,
    this.itemName,
    this.itemPrice,
  });

  Item.fromJson(Map<String, dynamic> json) {
    itemID = json['itemID'];
    itemName = json['itemName'];
    itemPrice = json['itemPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['itemID'] = this.itemID;
    data['itemName'] = this.itemName;
    data['itemPrice'] = this.itemPrice;
    return data;
  }
}