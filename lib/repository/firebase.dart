import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_list_new/models/list_product.dart';
import 'package:shopping_list_new/models/product.dart';
import 'package:shopping_list_new/models/shopping_list.dart';
import 'package:shopping_list_new/models/store.dart';

Future<Map> loginShoppingList(String emailAddress, String password) async {
  Map<String, dynamic> mapReturn = {
    'user': null,
    'message': '',
    'authenticated': false,
    'errorField': '',
    'emailVerify': false,
  };

  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (!(currentUser?.emailVerified ?? true)) {
      mapReturn['user'] = currentUser;
      mapReturn['message'] = 'Usuário não possui e-mail verificado';
      mapReturn['errorField'] = 'Verificação de e-mail';
      mapReturn['emailVerify'] = true;
    } else {
      mapReturn['user'] = currentUser;
      mapReturn['message'] = 'Usuário logado com sucesso';
      mapReturn['authenticated'] = true;
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      mapReturn['message'] = 'Usuário não encontrado';
      mapReturn['errorField'] = 'email';
    } else if (e.code == 'wrong-password') {
      mapReturn['message'] = 'Senha incorreta';
      mapReturn['errorField'] = 'password';
    }
    mapReturn['authenticated'] = false;
  }
  return mapReturn;
}

Future<Map> registerShoppingList(String emailAddress, String password) async {
  Map<String, dynamic> mapReturn = {
    'user': null,
    'message': '',
    'authenticated': false,
    'errorField': ''
  };

  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
    mapReturn['user'] = FirebaseAuth.instance.currentUser;
    mapReturn['authenticated'] = true;
    await userCredential.user?.sendEmailVerification();
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      mapReturn['message'] = 'A senha é muito fraca';
      mapReturn['errorerrorField'] = 'password';
    } else if (e.code == 'email-already-in-use') {
      mapReturn['message'] = 'E-mail informado já está cadastrado';
      mapReturn['errorerrorField'] = 'email';
    }
  } catch (e) {
    mapReturn['message'] = 'Erro desconhecido. Tente novamente';
  }
  FirebaseAuth.instance.signOut();

  return mapReturn;
}

Future<bool> deleteDocument(DocumentReference storeReference) async {
  bool returnStatus = true;
  try {
    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        transaction.delete(storeReference);
      },
    );
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}

Future<String?> createStore(Store store) async {
  try {
    DocumentReference storeDocument = await FirebaseFirestore.instance
        .collection('stores')
        .add(store.toMap());
    store.id = storeDocument.id;
  } catch (error) {
    store.id = null;
  }
  return store.id;
}

Future<bool> updateStore(Store store) async {
  bool returnStatus = true;
  try {
    await FirebaseFirestore.instance
        .collection('stores')
        .doc(store.id)
        .set(store.toMap());
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}

Future<bool> deleteStore(Store store) async {
  bool returnStatus = true;
  try {
    DocumentSnapshot storeDocument = await FirebaseFirestore.instance
        .collection('stores')
        .doc(store.id)
        .get();

    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        transaction.delete(storeDocument.reference);
      },
    );
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}

Future<bool> consultStoreInList(String storeId) async {
  User currentUser = FirebaseAuth.instance.currentUser!;
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('lists')
      .where('user_id', isEqualTo: currentUser.uid)
      .where('store_id', isEqualTo: storeId)
      .get();
  return querySnapshot.size > 0;
}

Future<String?> createProduct(Product product) async {
  try {
    DocumentReference productDocument = await FirebaseFirestore.instance
        .collection('products')
        .add(product.toMap());
    product.id = productDocument.id;
  } catch (error) {
    product.id = null;
  }
  return product.id;
}

Future<bool> updateProduct(Product product) async {
  bool returnStatus = true;
  try {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .set(product.toMap());
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}

Future<bool> deleteProduct(Product product) async {
  bool returnStatus = true;
  try {
    DocumentSnapshot productDocument = await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .get();

    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        transaction.delete(productDocument.reference);
      },
    );
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}

Future<bool> consultProductInList(String productId) async {
  User currentUser = FirebaseAuth.instance.currentUser!;
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('list_products')
      .where('user_id', isEqualTo: currentUser.uid)
      .where('product_id', isEqualTo: productId)
      .get();
  return querySnapshot.size > 0;
}

Future<String?> createList(ShoppingList list) async {
  try {
    DocumentReference listDocument =
        await FirebaseFirestore.instance.collection('lists').add(list.toMap());
    list.id = listDocument.id;
  } catch (error) {
    list.id = null;
  }
  return list.id;
}

Future<bool> updateList(ShoppingList list) async {
  bool returnStatus = true;
  try {
    await FirebaseFirestore.instance
        .collection('lists')
        .doc(list.id)
        .set(list.toMap());
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}

Future<bool> deleteList(ShoppingList shoppingList) async {
  bool returnStatus = true;
  try {
    DocumentSnapshot listDocument = await FirebaseFirestore.instance
        .collection('lists')
        .doc(shoppingList.id)
        .get();

    QuerySnapshot listProducts = await FirebaseFirestore.instance
        .collection('list_products')
        .where('list_id', isEqualTo: shoppingList.id)
        .get();

    listProducts.docs.forEach((element) async {
      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          transaction.delete(element.reference);
        },
      );
    });

    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        transaction.delete(listDocument.reference);
      },
    );
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}

Future<String?> createListProduct(ListProduct list) async {
  try {
    DocumentReference listDocument = await FirebaseFirestore.instance
        .collection('list_products')
        .add(list.toMap());
    list.id = listDocument.id;
  } catch (error) {
    list.id = null;
  }
  return list.id;
}

Future<bool> updateListProduct(ListProduct list) async {
  bool returnStatus = true;
  try {
    await FirebaseFirestore.instance
        .collection('list_products')
        .doc(list.id)
        .set(list.toMap());
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}

Future<bool> deleteListProduct(ListProduct listProduct) async {
  bool returnStatus = true;
  try {
    DocumentSnapshot listProductDocument = await FirebaseFirestore.instance
        .collection('list_products')
        .doc(listProduct.id)
        .get();

    await FirebaseFirestore.instance.runTransaction(
      (transaction) async {
        transaction.delete(listProductDocument.reference);
      },
    );
  } catch (error) {
    returnStatus = false;
  }
  return returnStatus;
}
