
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingList {
  String? id;
  DateTime dtCreate;
  DateTime? dtShopping;
  String store;
  String storeId;
  double? total;
  String userId;

  ShoppingList({
    this.id,
    required this.dtCreate,
    this.dtShopping,
    required this.store,
    required this.storeId,
    this.total,
    required this.userId,
  });

  ShoppingList.fromDocument(DocumentSnapshot shoppingList)
      : id = shoppingList.id,
        dtCreate = shoppingList['dtCreate'].toDate(),
        dtShopping = shoppingList['dtShopping']?.toDate(),
        store = shoppingList['store'],
        storeId = shoppingList['store_id'],
        total = (shoppingList['total'] ?? 0) * 1.0,
        userId = shoppingList['user_id'];

  Map<String, dynamic> toMap() {
    return {
      'dtCreate': Timestamp.fromDate(dtCreate),
      'dtShopping': dtShopping == null ? null : Timestamp.fromDate(dtShopping!),
      'store': store,
      'store_id': storeId,
      'total': total,
      'user_id': userId,
    };
  }
}
