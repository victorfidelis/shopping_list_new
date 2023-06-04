import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  DateTime dtCreated;
  String name;
  String userId;

  Product({required this.dtCreated, required this.name, required this.userId});

  Product.fromDocument(DocumentSnapshot product)
      : id = product.id,
        dtCreated = product['dtCreated'].toDate(),
        name = product['name'],
        userId = product['user_id'];

  Map<String, dynamic> toMap () {
    return {
      'dtCreated': Timestamp.fromDate(dtCreated),
      'name': name,
      'user_id': userId,
    };
  }
}
