import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:shopping_list_new/pages/change_password_page.dart';
import 'package:shopping_list_new/repository/firebase.dart';
import 'package:shopping_list_new/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  Function enterUser;

  LoginPage({
    Key? key,
    required this.enterUser,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidePassword = true;
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? userError;
  String? passwordError;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Shopping List',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    color: primaryBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            TextField(
              controller: userController,
              decoration: InputDecoration(
                label: const Text('Usuário'),
                border: const OutlineInputBorder(),
                errorText: userError,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                label: const Text('Senha'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
                errorText: passwordError,
              ),
              obscureText: hidePassword,
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: login,
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(primaryBackground)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: loading
                          ? loadingAnimationButton
                          : const Text(
                              'Entrar',
                              style: TextStyle(
                                color: primaryElement,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 400),
                      reverseDuration: const Duration(milliseconds: 400),
                      child: const ChangePasswordPage(),
                    )
                );
              },
              child: const Text(
                'Esqueci a senha',
                style: TextStyle(fontSize: 14),
              ),
            ),
            TextButton(
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 400),
                      reverseDuration: const Duration(milliseconds: 400),
                      child: const RegisterPage(),
                    )
                );
              },
              child: const Text(
                'Registrar-se',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  void login() {
    final user = userController.text;
    final password = passwordController.text;

    if (user.isEmpty) {
      setState(() {
        userError = 'O campo de usuário é obrigatório';
        passwordError = null;
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        userError = null;
        passwordError = 'O campo de senha é obrigatório';
      });
      return;
    }

    setState(() {loading = true;});
    loginShoppingList(user, password).then((value) {
      if (value['emailVerify']) {
        setState(() {
          loading = false;
        });
        sendEmailVerify(value['user']);
      } else if (value['authenticated']) {
        setState(() {
          loading = false;
          userError = null;
          passwordError = null;
        });
        widget.enterUser(value['user']);
      } else if (value['errorField'] == 'email') {
        setState(() {
          loading = false;
          userError = value['message'];
          passwordError = null;
        });
      } else {
        setState(() {
          loading = false;
          userError = null;
          passwordError = value['message'];
        });
      }
    });
  }

  void sendEmailVerify(User user) {
    AlertDialog alertConfirm = AlertDialog(
      title: const Text('E-mail enviado'),
      content: Text('Seu e-mail de confirmação foi enviado ao e-mail "${user.email}". '
          'Realize a confirmação antes de efetuar o login.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Ok'),
        ),
      ],
    );

    AlertDialog alertSendEmail = AlertDialog(
      title: const Text('Verificação de e-mail'),
      content: const Text('Sua conta possui pendência de confirmação de e-mail. '
          'Deseja realizar a vericação agora?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            user.sendEmailVerification().then((value) {
              showDialog(context: context, builder: (context) => alertConfirm);
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

    showDialog(context: context, builder: (context) => alertSendEmail);
  }
}
