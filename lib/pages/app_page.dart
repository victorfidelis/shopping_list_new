import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopping_list_new/pages/home_page.dart';
import 'package:shopping_list_new/pages/login_page.dart';
import 'package:shopping_list_new/general/styles.dart';

class AppPage extends StatefulWidget {

  AppPage({Key? key}) : super(key: key);

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late PageController pageController;
  bool loading = true;
  User? user;

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    Firebase.initializeApp().then((value) {
      FirebaseAuth.instance
        .authStateChanges()
        .listen((User? currentUser) {
          user = currentUser;
          if (!(user?.emailVerified ?? true)) user = null;
        });
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
            ? loadingAnimationPage
            : user == null
                ? LoginPage(enterUser: enterUser)
                : HomePage(user: user!, exitUser: exitUser);
  }

  void enterUser(User user) {
    setState(() {
      this.user = user;
    });
  }

  void exitUser() {
    FirebaseAuth.instance.signOut();
    setState(() {
      user = null;
    });
  }
}
