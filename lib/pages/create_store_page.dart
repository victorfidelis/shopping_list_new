import 'package:flutter/material.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:shopping_list_new/models/store.dart';
import 'package:shopping_list_new/repository/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateStorePage extends StatefulWidget {
  User user;
  Store? store;

  CreateStorePage({Key? key, required this.user, this.store}) : super(key: key);

  @override
  State<CreateStorePage> createState() => _CreateStorePageState();
}

class _CreateStorePageState extends State<CreateStorePage> {
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? errorName;
  bool newStore = true;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.store != null) {
      setState(() {
        newStore = false;
        nameController.text = widget.store!.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: newStore
            ? const Text('Nova Loja')
            : const Text('Alteração de Loja'),
        backgroundColor: primaryBackground,
        titleTextStyle: appBarTextStyle,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveStore,
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
                        labelText: 'Loja',
                        hintText: 'Extra Shopping Campo Limpo',
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

  void saveStore() {
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
          title: const Text('Salvar loja?'),
          content: Text('Tem certeza que deseja salvar a loja "$name"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SnackBar snackBarError = const SnackBar(
                  content: Text('Ocorreu um erro ao gravar a loja'),
                  duration: Duration(seconds: 2),
                );
                if (newStore) {
                  widget.store = Store(
                    dtCreated: DateTime.now(),
                    name: name,
                    userId: widget.user.uid,
                  );
                  setState(() {loading = true;});
                  createStore(widget.store!).then((value) {
                    if (value != null) {
                      widget.store!.id = value;
                      Navigator.pop(scaffoldKey.currentContext!, widget.store);
                    } else {
                      setState(() {loading = false;});
                      ScaffoldMessenger.of(context).showSnackBar(snackBarError);
                    }
                  });
                } else {
                  widget.store!.name = name;
                  setState(() {loading = true;});
                  updateStore(widget.store!).then((value) {
                    if (value) {
                      Navigator.pop(scaffoldKey.currentContext!, widget.store);
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
