import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_new/repository/firebase.dart';
import 'package:shopping_list_new/models/shopping_list.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:shopping_list_new/pages/create_list_page.dart';
import 'package:shopping_list_new/pages/list_product_page.dart';
import 'package:intl/intl.dart';

enum OrderList { dateCreate, dateShopping, orderAz, orderZa, orderValue }

class ListPage extends StatefulWidget {
  User user;

  ListPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPage();
}

class _ListPage extends State<ListPage>
    with AutomaticKeepAliveClientMixin<ListPage> {
  bool loading = false;
  bool loadingError = false;
  List<ShoppingList> listList = [];

  Future<void> refreshList([bool showLoading = false]) async {
    setState(() {
      loading = showLoading;
      loadingError = false;
    });
    try {
      QuerySnapshot firebaseLists = await FirebaseFirestore.instance
          .collection('lists')
          .where('user_id', isEqualTo: widget.user.uid)
          .get();
      setState(() {
        loading = false;
        loadingError = false;
        listList = firebaseLists.docs
            .map((e) => ShoppingList.fromDocument(e))
            .toList();
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
    refreshList(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('listpage');
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas'),
        backgroundColor: primaryBackground,
        titleTextStyle: appBarTextStyle,
        actions: [
          PopupMenuButton<OrderList>(
            onSelected: setOrderList,
            itemBuilder: (context) => <PopupMenuEntry<OrderList>>[
              const PopupMenuItem<OrderList>(
                value: OrderList.dateCreate,
                child: Text('Ordenar pela criação'),
              ),
              const PopupMenuItem<OrderList>(
                value: OrderList.dateShopping,
                child: Text('Ordenar pela data'),
              ),
              const PopupMenuItem<OrderList>(
                value: OrderList.orderAz,
                child: Text('Ordenar A a Z'),
              ),
              const PopupMenuItem<OrderList>(
                value: OrderList.orderZa,
                child: Text('Ordenar Z a A'),
              ),
              const PopupMenuItem<OrderList>(
                value: OrderList.orderValue,
                child: Text('Ordenar por Valor'),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: null,
      floatingActionButton: FloatingActionButton(
        heroTag: 'list',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CreateListPage(
                  user: widget.user,
                );
              },
            ),
          ).then((value) {
            if (value != null) {
              setState(() {
                listList.insert(0, value);
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
      body: loadingError
          ? const Center(child: Text('Ocorreu um erro ao carregar as listas.'))
          : loading
              ? loadingAnimationPage
              : Container(
                  margin: const EdgeInsets.all(4),
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: listList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            onSelectedList(listList[index], index);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: secondaryBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      listList[index].store,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: secondaryElement,
                                        fontSize: fontSizeCards,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${formatterMoney.format(listList[index].total ?? 0.00)}',
                                    style: const TextStyle(
                                      color: secondaryElement,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  listList[index].dtShopping == null
                                      ? const Text(
                                          'Sem data',
                                          style: TextStyle(
                                            color: secondaryElement,
                                            fontSize: 12,
                                          ),
                                        )
                                      : Text(
                                          DateFormat('dd/MM/yyyy').format(
                                            listList[index].dtShopping!,
                                          ),
                                          style: const TextStyle(
                                            color: secondaryElement,
                                            fontSize: 12,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  void onSelectedList(ShoppingList shoppingList, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            margin: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ListProductPage(
                        shoppingList: shoppingList,
                        user: widget.user,
                      );
                    })).then((value) {
                      if (value != null) {
                        setState(() {
                          listList[index] = value;
                        });
                      }
                    });
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(primaryBackground)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Acessar itens', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 16),
                        Icon(Icons.task),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CreateListPage(
                            user: widget.user,
                            shoppingList: shoppingList,
                          );
                        },
                      ),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          listList[index] = value;
                        });
                      }
                    });
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(primaryBackground)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Editar', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 16),
                        Icon(Icons.edit),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Deseja deletar?'),
                            content: Text(
                                'Uma vez deletada, a lista não poderá ser restaurada.\n\n'
                                'Tem certeza que deseja deletar a lista da loja "${shoppingList.store}"?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  setState(() {
                                    loading = true;
                                  });
                                  deleteList(shoppingList).then((value) {
                                    setState(() {
                                      loading = false;
                                      listList.removeAt(index);
                                    });
                                  });
                                },
                                child: const Text(
                                  'Sim',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Não'),
                              ),
                            ],
                          );
                        });
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.redAccent)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Deletar', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 16),
                        Icon(Icons.delete),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void setOrderList(OrderList orderList) {
    if (orderList == OrderList.dateCreate) {
      setState(() {
        listList.sort((a, b) => b.dtCreate.compareTo(a.dtCreate));
      });
    } else if (orderList == OrderList.dateShopping) {
      setState(() {
        listList.sort((a, b) {
          if (a.dtShopping == null && b.dtShopping == null) return 0;
          if (a.dtShopping == null) return 1;
          return b.dtShopping!.compareTo(a.dtShopping!);
        });
      });
    } else if (orderList == OrderList.orderAz) {
      setState(() {
        listList.sort((a, b) => a.store.compareTo(b.store));
      });
    } else if (orderList == OrderList.orderZa) {
      setState(() {
        listList.sort((a, b) => b.store.compareTo(a.store));
      });
    } else {
      setState(() {
        listList.sort((a, b) => (a.total ?? 0.00).compareTo(b.total ?? 0.00));
      });
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
