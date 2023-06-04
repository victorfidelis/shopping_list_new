import 'package:flutter/material.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:shopping_list_new/models/product.dart';
import 'package:shopping_list_new/repository/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateProductPage extends StatefulWidget {
  User user;
  Product? product;

  CreateProductPage({Key? key, required this.user, this.product}) : super(key: key);

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? errorName;
  bool newProduct = true;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.product != null) {
      setState(() {
        newProduct = false;
        nameController.text = widget.product!.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: newProduct
            ? const Text('Novo Produto')
            : const Text('Alteração de Produto'),
        backgroundColor: primaryBackground,
        titleTextStyle: appBarTextStyle,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveProduct,
        backgroundColor: primaryBackground,
        child: const Icon(
          Icons.save,
          color: primaryElement,
        ),
      ),
      body: loading
          ? loadingAnimationPage
          : SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Produto',
                        hintText: 'Toddy 1,02 Kg',
                        border: const OutlineInputBorder(),
                        errorText: errorName,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  void saveProduct() {
    String name = nameController.text;

    if (name.isEmpty) {
      setState(() {
        errorName = 'Campo obrigatório';
      });
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salvar produto?'),
          content: Text('Tem certeza que deseja salvar o produto "$name"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SnackBar snackBarError = const SnackBar(
                  content: Text('Ocorreu um erro ao gravar o produto'),
                  duration: Duration(seconds: 2),
                );
                if (newProduct) {
                  widget.product = Product(
                    dtCreated: DateTime.now(),
                    name: name,
                    userId: widget.user.uid,
                  );
                  setState(() {loading = true;});
                  createProduct(widget.product!).then((value) {
                    if (value != null) {
                      widget.product!.id = value;
                      Navigator.pop(scaffoldKey.currentContext!, widget.product);
                    } else {
                      setState(() {loading = false;});
                      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
                    }
                  });
                } else {
                  widget.product!.name = name;
                  setState(() {loading = true;});
                  updateProduct(widget.product!).then((value) {
                    if (value) {
                      Navigator.pop(scaffoldKey.currentContext!, true);
                    } else {
                      setState(() {loading = false;});
                      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
                    }
                  });
                }
              },
              child: const Text('Sim', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Não', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
