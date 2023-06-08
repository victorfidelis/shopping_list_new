import 'package:flutter/material.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatelessWidget {
  User user;
  Function logout;
  AccountPage({Key? key, required this.user, required this.logout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.person, size: 30,),
              SizedBox(width: 8),
              Text('Conta'),
            ],
          ),
          backgroundColor: primaryBackground,
          titleTextStyle: appBarTextStyle,
        ),
      body: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.email ?? 'Nenhum e-mail cadastrado'),
            ),
            const SizedBox(height: 8),
            ListTile(
              selectedTileColor: secondaryBackground,
              leading: const Icon(Icons.output),
              title: const Text('Sair'),
              onTap: () => logout(),
            ),
          ],
        ),
      ),
    );
  }
}
