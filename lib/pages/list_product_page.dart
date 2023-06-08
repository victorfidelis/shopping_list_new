import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shopping_list_new/models/product.dart';
import 'package:shopping_list_new/models/shopping_list.dart';
import 'package:shopping_list_new/models/list_product.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:shopping_list_new/pages/update_list_product_page.dart';
import 'package:shopping_list_new/repository/firebase.dart';

enum OrderItem { orderCheck, orderAz, orderZa, orderValue, orderTotal}

class ListProductPage extends StatefulWidget {
  ShoppingList shoppingList;
  User user;

  ListProductPage({
    Key? key,
    required this.shoppingList,
    required this.user,
  }) : super(key: key);

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  TextEditingController productController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? errorTextProduct;
  bool loading = true;
  bool loadingError = false;
  String productText = '';
  Product? productList;
  List<ListProduct> listProduct = [];

  void refreshListProduct() {
    setState(() {
      loading = true;
      loadingError = false;
      productController.clear();
      productList = null;
    });
    FirebaseFirestore.instance
        .collection('list_products')
        .where('list_id', isEqualTo: widget.shoppingList.id!)
        .get()
        .then((value) {
          setState(() {
            loading = false;
            loadingError = false;
            listProduct =
                value.docs.map((e) => ListProduct.fromDocument(e)).toList();
          });
        })
        .catchError(() {
          setState(() {
            loading = false;
            loadingError = true;
          });
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    refreshListProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.shoppingList.store, style: appBarTextStyle),
        backgroundColor: primaryBackground,
        actions: [
          PopupMenuButton<OrderItem>(
            onSelected: setOrderItems,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<OrderItem>>[
              const PopupMenuItem<OrderItem>(
                value: OrderItem.orderCheck,
                child: Text('Ordenar checks'),
              ),
              const PopupMenuItem<OrderItem>(
                value: OrderItem.orderAz,
                child: Text('Ordenar A a Z'),
              ),
              const PopupMenuItem<OrderItem>(
                value: OrderItem.orderZa,
                child: Text('Ordenar Z a A'),
              ),
              const PopupMenuItem<OrderItem>(
                value: OrderItem.orderValue,
                child: Text('Ordernar por Valor'),
              ),
              const PopupMenuItem<OrderItem>(
                value: OrderItem.orderTotal,
                child: Text('Ordernar por Total'),
              ),
            ],
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, widget.shoppingList);
          return true;
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: productController,
                      decoration: InputDecoration(
                        labelText: 'Novo item',
                        hintText: 'Ex.: Bolacha Trakinas',
                        border: const OutlineInputBorder(),
                        errorText: errorTextProduct,
                        prefixIcon:
                            productList == null ? null : const Icon(Icons.check),
                      ),
                      onChanged: (text) {
                        setState(() {
                          productText = text;
                          productList = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  ElevatedButton(
                    onPressed: addItem,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              searchProduct(),
              Expanded(
                  child: loadingError
                      ? const Center(
                          child: Text('Ocorreu um erro ao carregar as listas.'),
                        )
                      : loading
                          ? loadingAnimationPage
                          : ListView.builder(
                              itemCount: listProduct.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Slidable(
                                    startActionPane: ActionPane(
                                      extentRatio: 0.25,
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          padding: const EdgeInsets.all(8),//
                                          onPressed: (context) {
                                            delete(listProduct[index], index);
                                          },
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                            PageTransition(
                                              type: PageTransitionType.fade,
                                              duration: const Duration(milliseconds: 400),
                                              reverseDuration: const Duration(milliseconds: 400),
                                              child: UpdateListProductPage(
                                                listProduct: listProduct[index],
                                                user: widget.user,
                                              ),
                                            ),
                                        ).then((value) {
                                          if (value != null) {
                                            setState(() {
                                              listProduct[index] = value;
                                            });
                                            calculateTotal();
                                            updateList(widget.shoppingList);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: secondaryBackground,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  listProduct[index].check
                                                      ? Colors.green
                                                      : Colors.blue,
                                              child: Icon(
                                                listProduct[index].check
                                                    ? Icons.check
                                                    : Icons.pending,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    listProduct[index].product,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      IntrinsicWidth(
                                                        stepWidth: 75,
                                                        child: Text(
                                                          'Qtde: ${formatterWeight.format(listProduct[index].quantity ?? 0.0)}',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Text(
                                                        'Valor: R\$ ${formatterMoney.format(listProduct[index].unitPrice ?? 0.0)}',
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Total: R\$ ${formatterMoney.format(listProduct[index].totalPrice ?? 0.0)}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Checkbox(
                                              value: listProduct[index].check,
                                              onChanged: (check) {
                                                setState(() {
                                                  listProduct[index].check = check ?? false;
                                                });
                                                updateListProduct(
                                                        listProduct[index])
                                                    .then((value) {
                                                  if (!value) {
                                                    ScaffoldMessenger.of(context).clearSnackBars();
                                                    setState(() {
                                                      listProduct[index].check = !listProduct[index].check;
                                                    });
                                                    SnackBar snackBarErro =
                                                        const SnackBar(content: Text(
                                                          'Ocorreu um erro ao alterar o statys do item'),
                                                          duration: Duration(seconds: 2),
                                                        );
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBarErro);
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.white30,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Quantidade de itens: ${listProduct.length}',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Valor total: R\$ ${formatterMoney.format(widget.shoppingList.total ?? 0.00)}',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void addItem() {
    String productTextAux = productController.text;

    if (productTextAux.isEmpty) {
      setState(() {
        errorTextProduct = 'Necessário informar um produto';
      });
      return;
    }

    if (productList == null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Produto não cadastrado'),
              content: const Text('Não foi selecionado um produto cadastrado. '
                  'Para continuar será necessário o cadastro deste produto em sua conta. '
                  'Deseja continuar?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    SnackBar snackBarError = const SnackBar(
                      content: Text('Ocorreu um erro ao gravar a loja'),
                      duration: Duration(seconds: 2),
                    );

                    productList = Product(
                      dtCreated: DateTime.now(),
                      name: productTextAux,
                      userId: widget.user.uid,
                    );
                    setState(() {
                      productText = '';
                      loading = true;
                    });
                    createProduct(productList!).then((value) {
                      setState(() {
                        loading = false;
                      });
                      if (value != null) {
                        productList!.id = value;
                        saveItem();
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(snackBarError);
                        productList = null;
                      }
                    });
                  },
                  child: const Text(
                    'Sim',
                    style: TextStyle(color: yesButton),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Não',
                    style: TextStyle(color: noButton),
                  ),
                ),
              ],
            );
          });
    } else {
      saveItem();
    }
  }

  void saveItem() {
    SnackBar snackBarError = const SnackBar(
      content: Text('Ocorreu um erro ao gravar o produto'),
      duration: Duration(seconds: 2),
    );

    ListProduct listProductItem = ListProduct(
      check: false,
      listId: widget.shoppingList.id!,
      product: productList!.name,
      productId: productList!.id!,
      quantity: 0,
      totalPrice: 0,
      unitPrice: 0,
      userId: widget.user.uid,
    );

    setState(() {
      loading = true;
    });
    createListProduct(listProductItem).then((value) {
      setState(() {
        loading = false;
      });
      if (value != null) {
        productController.clear();
        productList = null;
        listProductItem.id = value;
        listProduct.insert(0, listProductItem);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(snackBarError);
      }
    });
  }

  Widget searchProduct() {
    return productText.isEmpty
        ? const SizedBox(height: 4)
        : FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('products')
                .where('user_id', isEqualTo: widget.user.uid)
                .orderBy('name')
                .startAt([productText]).endAt(['$productText\uf8ff']).get(),
            builder: (context, snapshot) {
              Widget widgetReturn;
              if (snapshot.hasError) {
                widgetReturn = Container();
              } else if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.connectionState == ConnectionState.waiting) {
                widgetReturn = loadingAnimationSearch;
              } else {
                List<Product> products = snapshot.data!.docs
                    .map((e) => Product.fromDocument(e))
                    .toList();
                widgetReturn = Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 16),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: inactivated,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 4, top: 4),
                        child: const Text(
                          'Produtos:',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Container(
                        constraints: const BoxConstraints(
                          maxHeight: 200,
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  InkWell(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              products[index].name,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      productController.text =
                                          products[index].name;
                                      setState(() {
                                        productList = products[index];
                                        productText = '';
                                      });
                                    },
                                  ),
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                );
              }
              return widgetReturn;
            },
          );
  }

  void delete(ListProduct listProductDelete, int index) {
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
      content: Text(
          'O produto ${listProductDelete.product} foi removido com sucesso.'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'DESFAZER',
        onPressed: () {
          setState(() {
            loading = true;
          });
          createListProduct(listProductDelete).then((value) {
                if (value != null) {
                  productController.clear();
                  productList = null;
                  listProductDelete.id = value;
                  listProduct.insert(index, listProductDelete);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(snackBarError);
                }
                setState(() {
                  loading = false;
                  calculateTotal();
                });
              })
              .catchError(() {
                setState(() {
                  loading = false;
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(snackBarErrorCreate);
              });
        },
      ),
    );
    setState(() {
      loading = true;
    });
    deleteListProduct(listProductDelete).then((value) {
      if (value) {
        setState(() {
          listProduct.removeAt(index);
          calculateTotal();
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(snackBarError);
      }
    });
  }

  void setOrderItems(OrderItem orderItem) {
    if (orderItem == OrderItem.orderCheck) {
      setState(() {
        listProduct.sort((a, b) {
          if (a.check == b.check) return 0;
          if (a.check) return 1;
          return -1;
        });
      });
    } else if (orderItem == OrderItem.orderAz) {
      setState(() {
        listProduct.sort((a, b) => a.product.compareTo(b.product));
      });
    } else if (orderItem == OrderItem.orderZa){
      setState(() {
        listProduct.sort((a, b) => b.product.compareTo(a.product));
      });
    }
    else if (orderItem == OrderItem.orderValue) {
      setState(() {
        listProduct.sort((a, b) =>
            (a.unitPrice ?? 0.00).compareTo(b.unitPrice ?? 0.00));
      });
    }
    else {
      setState(() {
        listProduct.sort((a, b) => (a.totalPrice ?? 0.00).compareTo(b.totalPrice ?? 0.00));
      });
    }
  }

  void calculateTotal () {
    if (listProduct.isEmpty) {
      widget.shoppingList.total = 0;
    } else {
      widget.shoppingList.total = listProduct.map((e) => e.totalPrice ?? 0.00).reduce((a, b) => a + b);
    }
  }
}
