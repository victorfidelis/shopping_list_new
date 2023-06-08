import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_new/models/list_product.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list_new/models/product.dart';
import 'package:shopping_list_new/repository/firebase.dart';

enum ValidControll { quantity, value, total }

class UpdateListProductPage extends StatefulWidget {
  ListProduct listProduct;
  User user;

  UpdateListProductPage(
      {Key? key, required this.listProduct, required this.user})
      : super(key: key);

  @override
  State<UpdateListProductPage> createState() => _UpdateListProductPageState();
}

class _UpdateListProductPageState extends State<UpdateListProductPage> {
  String? errorTextProduct;
  TextEditingController productController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  Product? productList;
  String productText = '';
  bool loading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    productController.text = widget.listProduct.product;
    quantityController.text =
        formatterWeight.format(widget.listProduct.quantity ?? 0);
    valueController.text =
        formatterMoney.format(widget.listProduct.unitPrice ?? 0);
    totalController.text =
        formatterMoney.format(widget.listProduct.totalPrice ?? 0);
    productList = Product(
      dtCreated: DateTime.now(),
      name: widget.listProduct.product,
      userId: widget.user.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.listProduct.product),
        backgroundColor: primaryBackground,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveItem,
        backgroundColor: primaryBackground,
        child: const Icon(
          Icons.save,
          color: primaryElement,
        ),
      ),
      body: loading
          ? loadingAnimationPage
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
              child: Column(
                children: [
                  TextField(
                      controller: productController,
                      decoration: InputDecoration(
                        labelText: 'Produto',
                        errorText: errorTextProduct,
                        border: const OutlineInputBorder(),
                        prefixIcon: productList == null
                            ? null
                            : const Icon(Icons.check),
                      ),
                      onChanged: (text) {
                        setState(() {
                          productText = text;
                          productList = null;
                        });
                      }),
                  searchProduct(),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: FocusScope(
                          onFocusChange: (value) {
                            if (value) selectedField(quantityController);
                          },
                          child: TextField(
                            controller: quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Qtde',
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: false, decimal: true),
                            onChanged: (text) {
                              calculatePrice(ValidControll.quantity);
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Text('x'),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 5,
                        child: FocusScope(
                          onFocusChange: (value) {
                            if (value) selectedField(valueController);
                          },
                          child: TextField(
                            controller: valueController,
                            decoration: const InputDecoration(
                              labelText: 'Valor',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixText: 'R\$ ',
                              prefixStyle: TextStyle(color: Colors.grey),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: false, decimal: true),
                            onChanged: (text) {
                              calculatePrice(ValidControll.value);
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(9)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Text('='),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 5,
                        child: FocusScope(
                          onFocusChange: (value) {
                            if (value) selectedField(totalController);
                          },
                          child: TextField(
                            controller: totalController,
                            decoration: const InputDecoration(
                              labelText: 'Total',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixText: 'R\$ ',
                              prefixStyle: TextStyle(color: Colors.grey),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: false, decimal: true),
                            onChanged: (text) {
                              calculatePrice(ValidControll.total);
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(9)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void saveItem() {
    if (productController.text.isEmpty) {
      setState(() {
        errorTextProduct = 'Campo obrigatório';
      });
      return;
    }

    setState(() {
      errorTextProduct = null;
    });

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
                      name: productText,
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
      widget.listProduct.product = productController.text;
      widget.listProduct.quantity = double.tryParse(quantityController.text.replaceAll(',', '.'));
      widget.listProduct.unitPrice = double.tryParse(valueController.text.replaceAll(',', '.'));
      widget.listProduct.totalPrice = double.tryParse(totalController.text.replaceAll(',', '.'));

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Deseja salvar?'),
              content: const Text(
                  'Tem certeza que deseja salvar as alterações deste item?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    SnackBar snackBarError = const SnackBar(
                      content: Text('Ocorreu um erro ao gravar a loja'),
                      duration: Duration(seconds: 2),
                    );

                    setState(() {loading = true;});
                    updateListProduct(widget.listProduct).then((value) {
                      if (value) {
                        Navigator.pop(scaffoldKey.currentContext!, widget.listProduct);
                      } else {
                        setState(() {loading = false;});
                        ScaffoldMessenger.of(context).showSnackBar(snackBarError);
                      }
                    });
                  },
                  child: const Text(
                      'Sim', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Não', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          });
    }
  }

  void calculatePrice(ValidControll validControll) {
    double quantity =
        double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0;
    double value =
        double.tryParse(valueController.text.replaceAll(',', '.')) ?? 0;
    double total =
        double.tryParse(totalController.text.replaceAll(',', '.')) ?? 0;

    if (validControll == ValidControll.quantity) {
      total = quantity * value;
      totalController.text = formatterMoney.format(total);
      valueController.text = formatterMoney.format(value);
    } else if (validControll == ValidControll.value) {
      total = quantity * value;
      quantityController.text = formatterWeight.format(quantity);
      totalController.text = formatterMoney.format(total);
    } else if (quantity == 0) {
      value = 0;
      quantityController.text = formatterWeight.format(quantity);
      valueController.text = formatterMoney.format(value);
    } else {
      value = total / quantity;
      quantityController.text = formatterWeight.format(quantity);
      valueController.text = formatterMoney.format(value);
    }
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

  void selectedField(TextEditingController controller) {
    controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
  }
}
