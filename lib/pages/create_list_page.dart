import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_new/models/shopping_list.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:date_field/date_field.dart';
import 'package:shopping_list_new/models/store.dart';
import 'package:shopping_list_new/repository/firebase.dart';

class CreateListPage extends StatefulWidget {
  User user;
  ShoppingList? shoppingList;

  CreateListPage({Key? key, required this.user, this.shoppingList})
      : super(key: key);

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  Store? storeList;
  TextEditingController storeController = TextEditingController();
  DateTime? fieldDtShopping;
  String? errorTextName;
  bool newList = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  String storeText = '';

  @override
  void initState() {
    super.initState();

    if (widget.shoppingList != null) {
      setState(() {
        newList = false;
        storeController.text = widget.shoppingList!.store;
        storeList = Store(
          dtCreated: DateTime.now(),
          name: widget.shoppingList!.store,
          userId: widget.user.uid,
          id: widget.shoppingList!.storeId,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: newList
            ? const Text('Nova Lista')
            : const Text('Alteração de Lista'),
        backgroundColor: primaryBackground,
        titleTextStyle: appBarTextStyle,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveList,
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
                      controller: storeController,
                      decoration: InputDecoration(
                        labelText: 'Nome da loja',
                        hintText: 'Carrefour',
                        border: const OutlineInputBorder(),
                        errorText: errorTextName,
                        prefixIcon:
                            storeList == null ? null : const Icon(Icons.check),
                      ),
                      onChanged: (text) {
                        setState(() {
                          storeText = text;
                          storeList = null;
                        });
                      },
                    ),
                    searchStore(),
                    DateTimeFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.event_note),
                        labelText: 'Data da compra',
                      ),
                      mode: DateTimeFieldPickerMode.date,
                      autovalidateMode: AutovalidateMode.always,
                      onDateSelected: (DateTime value) {
                        fieldDtShopping = value;
                      },
                      initialValue: widget.shoppingList?.dtShopping,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void saveList() {
    String storeText = storeController.text;

    if (storeText.isEmpty) {
      setState(() {
        errorTextName = 'Campo obrigatório';
      });
      return;
    }

    if (storeList == null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Loja não cadastrada'),
              content: const Text('Não foi selecionada uma loja cadastrada. '
                  'Para continuar será necessário o cadastro desta loja em sua conta. '
                  'Deseja continuar?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    SnackBar snackBarError = const SnackBar(
                      content: Text('Ocorreu um erro ao gravar a loja'),
                      duration: Duration(seconds: 2),
                    );

                    storeList = Store(
                      dtCreated: DateTime.now(),
                      name: storeText,
                      userId: widget.user.uid,
                    );
                    setState(() {
                      storeText = '';
                      loading = true;
                    });
                    createStore(storeList!).then((value) {
                      setState(() {
                        loading = false;
                      });
                      if (value != null) {
                        storeList!.id = value;
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(snackBarError);
                        storeList = null;
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
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Salvar lista?'),
            content: Text(
                'Tem certeza que deseja salvar a lista da loja "${storeController.text}"?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  SnackBar snackBarError = const SnackBar(
                    content: Text('Ocorreu um erro ao gravar o produto'),
                    duration: Duration(seconds: 2),
                  );

                  if (newList) {
                    widget.shoppingList = ShoppingList(
                      dtCreate: DateTime.now(),
                      dtShopping: fieldDtShopping,
                      store: storeList!.name,
                      storeId: storeList!.id!,
                      userId: widget.user.uid,
                    );

                    setState(() {
                      loading = true;
                    });
                    createList(widget.shoppingList!).then((value) {
                      if (value!= null) {
                        widget.shoppingList!.id = value;
                        Navigator.pop(scaffoldKey.currentContext!, widget.shoppingList);
                      } else {
                        setState(() {
                          loading = false;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(snackBarError);
                      }
                    });
                  } else {
                    widget.shoppingList!.store = storeList!.name;
                    widget.shoppingList!.storeId = storeList!.id!;
                    widget.shoppingList!.dtShopping = fieldDtShopping;

                    setState(() {
                      loading = true;
                    });
                    updateList(widget.shoppingList!).then((value) {
                      if (value) {
                        Navigator.pop(scaffoldKey.currentContext!, widget.shoppingList);
                      } else {
                        setState(() {
                          loading = false;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(snackBarError);
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

  Widget searchStore() {
    return storeText.isEmpty
        ? const SizedBox(height: 16)
        : FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('stores')
                .where('user_id', isEqualTo: widget.user.uid)
                .orderBy('name')
                .startAt([storeText]).endAt(['$storeText\uf8ff']).get(),
            builder: (context, snapshot) {
              Widget widgetReturn;
              if (snapshot.hasError) {
                widgetReturn = Container();
              } else if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.connectionState == ConnectionState.waiting) {
                widgetReturn = loadingAnimationSearch;
              } else {
                List<Store> stores = snapshot.data!.docs
                    .map((e) => Store.fromDocument(e))
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
                          'Lojas:',
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
                            itemCount: stores.length,
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
                                              stores[index].name,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      storeController.text = stores[index].name;
                                      setState(() {
                                        storeList = stores[index];
                                        storeText = '';
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
}
