import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:shopping_list_new/pages/product_page.dart';
import 'package:shopping_list_new/pages/list_page.dart';
import 'package:shopping_list_new/pages/store_page.dart';
import 'package:shopping_list_new/pages/account_page.dart';

class HomePage extends StatefulWidget {
  User user;
  Function exitUser;

  HomePage({
    Key? key,
    required this.user,
    required this.exitUser,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController();
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_outlined), label: 'Listas'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Lojas'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Conta'),
        ],
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        backgroundColor: primaryElement,
        unselectedFontSize: 10,
        currentIndex: selectedPage,
        selectedItemColor: selectedIconBar,
        unselectedItemColor: inactivated,
        onTap: onTapItem,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: background,
        ),
        child: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ListPage(user: widget.user!),
            StorePage(user: widget.user!),
            ProductPage(user: widget.user!),
            AccountPage(user: widget.user, logout: logout,),
          ],
        ),
      ),
    );
  }

  void logout () {
    AlertDialog alertDialog = AlertDialog(
      title: const Text('Deseja sair?'),
      content: const Text('Tem certeza que deseja sair de sua lista?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.exitUser();
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
    showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }

  void onTapItem(int item) {
    setState(() {
      selectedPage = item;
      pageController.jumpToPage(item);
    });
  }
}
