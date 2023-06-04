import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  String? id;
  DateTime dtCreated;
  String name;
  String userId;

  Store({required this.dtCreated, required this.name, required this.userId, this.id});

  Store.fromDocument(DocumentSnapshot store)
      : id = store.id,
        dtCreated = store['dtCreated'].toDate(),
        name = store['name'],
        userId = store['user_id'];

  Map<String, dynamic> toMap () {
    return {
      'dtCreated': Timestamp.fromDate(dtCreated),
      'name': name,
      'user_id': userId,
    };
  }
}
