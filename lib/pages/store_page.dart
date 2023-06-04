import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_list_new/models/store.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shopping_list_new/pages/create_store_page.dart';
import 'package:shopping_list_new/repository/firebase.dart';

class StorePage extends StatefulWidget {
  User user;

  StorePage({Key? key, required this.user}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage>
    with AutomaticKeepAliveClientMixin<StorePage> {
  bool loading = false;
  bool loadingError = false;
  List<Store> listStore = [];

  Future<void> refreshListStores([bool showLoading = false]) async {
    setState(() {
      loading = showLoading;
      loadingError = false;
    });
    try {
      QuerySnapshot firebaseStores = await FirebaseFirestore.instance
          .collection('stores')
          .where('user_id', isEqualTo: widget.user.uid)
          .get();
      setState(() {
        loading = false;
        loadingError = false;
        listStore = firebaseStores.docs.map((e) => Store.fromDocument(e)).toList();
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
    refreshListStores(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Lojas'),
          backgroundColor: primaryBackground,
          titleTextStyle: appBarTextStyle,
        ),
        bottomNavigationBar: null,
        floatingActionButton: FloatingActionButton(
          heroTag: 'store',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return CreateStorePage(
                  user: widget.user,
                );
              }),
            ).then((value) {
              if (value != null) {
                setState(() {
                  listStore.insert(0, value);
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
            ? const Center(
                child: Text('Ocorreu um erro ao carregar as listas.'))
            : loading
                ? loadingAnimationPage
                : RefreshIndicator(
                  onRefresh: refreshListStores,
                  child: ListView.builder(
                      itemCount: listStore.length,
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
                                    delete(listStore[index], index);
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
                                  MaterialPageRoute(builder: (context) {
                                    return CreateStorePage(
                                      user: widget.user,
                                      store: listStore[index],
                                    );
                                  }),
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      listStore[index] = value;
                                    });
                                  }
                                });
                              },
                              title: Text(
                                listStore[index].name,
                                style: const TextStyle(
                                  color: secondaryElement,
                                  fontSize: fontSizeCards,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(listStore[index].dtCreated),
                                style: const TextStyle(
                                  color: secondaryElement,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ));
  }

  void delete(Store storeDelete, int index) {
    ScaffoldMessenger.of(context).clearSnackBars();

    SnackBar snackBarError = const SnackBar(
      content: Text('Ocorreu um erro ao excluír a loja'),
      duration: Duration(seconds: 2),
    );
    SnackBar snackBarErrorCreate = const SnackBar(
      content: Text('Ocorreu um erro ao regravar a loja'),
      duration: Duration(seconds: 2),
    );
    SnackBar snackBar = SnackBar(
      content: Text('A loja ${storeDelete.name} foi removida com sucesso.'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'DESFAZER',
        onPressed: () {
          setState(() {
            loading = true;
          });
          createStore(storeDelete).then((value) {
            if (value != null) {
              storeDelete.id = value;
              listStore.insert(index, storeDelete);
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

    deleteStore(storeDelete).then((value) {
      setState(() {
        listStore.removeAt(index);
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
  bool get wantKeepAlive => true;
}
