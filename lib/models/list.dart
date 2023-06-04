// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class List {
//   String? id;
//   DateTime dtCreated;
//   DateTime? dtShopping;
//   String storeId;
//   double total;
//   String userId;
//
//   List({
//     required this.dtCreated,
//     required this.dtShopping,
//     required this.storeId,
//     required this.total,
//     required this.userId,
//   });
//
//   List.fromDocument(DocumentSnapshot list)
//       : id = list.id,
//         dtCreated = list['dtCreated'].toDate(),
//         dtShopping = list['dtShopping'].toDate(),
//         storeId = list['store_id'],
//         total = (list['total'] ?? 0.00) * 1.0,
//         userId = list['user_id'];
//
//   Map<String, dynamic> toMap() {
//     return {
//       'dtCreated': Timestamp.fromDate(dtCreated),
//       'dtShopping': dtShopping == null ? null : Timestamp.fromDate(dtShopping!),
//       'store_id': storeId,
//       'total': total,
//       'user_id': userId,
//     };
//   }
// }
