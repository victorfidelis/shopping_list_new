import 'package:cloud_firestore/cloud_firestore.dart';

class ListProduct {
  String? id;
  bool check;
  String listId;
  String product;
  String productId;
  double? quantity;
  double? totalPrice;
  double? unitPrice;
  String userId;

  ListProduct({
    this.id,
    required this.check,
    required this.listId,
    required this.product,
    required this.productId,
    this.quantity,
    this.totalPrice,
    this.unitPrice,
    required this.userId,
  });

  ListProduct.fromDocument(DocumentSnapshot documentListProduct)
      : id = documentListProduct.id,
        check = documentListProduct['check'],
        listId = documentListProduct['list_id'],
        product = documentListProduct['product'],
        productId = documentListProduct['product_id'],
        quantity = documentListProduct['quantity'] * 1.0,
        totalPrice = documentListProduct['total_price'] * 1.0,
        unitPrice = documentListProduct['unit_price'] * 1.0,
        userId = documentListProduct['user_id'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'check': check,
      'list_id': listId,
      'product': product,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'unit_price': unitPrice,
      'user_id': userId,
    };
  }
}
