import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_list_new/repository/firebase.dart';
import 'package:shopping_list_new/models/product.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_new/pages/create_product_page.dart';

class ProductPage extends StatefulWidget {
  User user;

  ProductPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with AutomaticKeepAliveClientMixin<ProductPage> {
  bool loading = false;
  bool loadingError = false;
  List<Product> listProduct = [];

  Future<void> refreshListProducts([bool showLoading = false]) async {
    setState(() {
      loading = showLoading;
      loadingError = false;
    });
    try {
      QuerySnapshot firebaseProducts = await FirebaseFirestore.instance
          .collection('products')
          .where('user_id', isEqualTo: widget.user.uid)
          .get();
      setState(() {
        loading = false;
        loadingError = false;
        listProduct = firebaseProducts.docs.map((e) => Product.fromDocument(e)).toList();
        listProduct.sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
      });
    } catch (e) {
      setState(() {
        loading = false;
        loadingError = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    refreshListProducts(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_bag, size: 30,),
            SizedBox(width: 8),
            Text('Produtos'),
          ],
        ),
        backgroundColor: primaryBackground,
        titleTextStyle: appBarTextStyle,
      ),
      bottomNavigationBar: null,
      floatingActionButton: FloatingActionButton(
        heroTag: 'product',
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 400),
              reverseDuration: const Duration(milliseconds: 400),
              child: CreateProductPage(
                user: widget.user,
              ),
            ),
          ).then((value) {
            if (value != null) {
              setState(() {
                listProduct.insert(0, value);
              });
            }
          });
        },
        backgroundColor: primaryBackground,
        child: const Icon(
          Icons.add,
          color: primaryElement,
          size: 32,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: background,
        ),
        child: loadingError
            ? const Center(child: Text('Ocorreu um erro ao carregar as listas.'))
            : loading
                ? loadingAnimationPage
                : RefreshIndicator(
                  onRefresh: refreshListProducts,
                  child: ListView.builder(
                      itemCount: listProduct.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: secondaryBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Slidable(
                            startActionPane: ActionPane(
                              extentRatio: 0.25,
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    delete(listProduct[index], index);
                                  },
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    duration: const Duration(milliseconds: 400),
                                    reverseDuration: const Duration(milliseconds: 400),
                                    child: CreateProductPage(
                                      user: widget.user,
                                      product: listProduct[index],
                                    ),
                                  ),
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      listProduct[index] = value;
                                    });
                                  }
                                });
                              },
                              title: Text(
                                listProduct[index].name,
                                style: const TextStyle(
                                  color: secondaryElement,
                                  fontSize: fontSizeCards,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(listProduct[index].dtCreated),
                                style: const TextStyle(
                                  color: secondaryElement,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
      ),
    );
  }

  void delete(Product productDelete, int index) {
    ScaffoldMessenger.of(context).clearSnackBars();

    SnackBar snackBarError = const SnackBar(
      content: Text('Ocorreu um erro ao excluír o produto'),
      duration: Duration(seconds: 2),
    );
    SnackBar snackBarErrorCreate = const SnackBar(
      content: Text('Ocorreu um erro ao regravar o produto'),
      duration: Duration(seconds: 2),
    );
    SnackBar snackBar = SnackBar(
      content:
          Text('O produto ${productDelete.name} foi removido com sucesso.'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'DESFAZER',
        onPressed: () {
          setState(() {
            loading = true;
          });
          createProduct(productDelete).then((value) {
            if (value != null) {
              productDelete.id = value;
              listProduct.insert(index, productDelete);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(snackBarError);
            }
            setState(() {
              loading = false;
            });
          }).catchError(() {
            setState(() => loading = false);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(snackBarErrorCreate);
          });
        },
      ),
    );
    setState(() {
      loading = true;
    });
    deleteProduct(productDelete).then((value) {
      setState(() {
        listProduct.removeAt(index);
        loading = false;
      });
      if (value) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(snackBarError);
      }
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
