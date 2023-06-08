import 'package:flutter/material.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:shopping_list_new/repository/firebase.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();
  GlobalKey scaffoldKey = GlobalKey();

  bool hidePassword = true;
  bool hideConfirmation = true;

  String? emailError;
  String? passwordError;
  String? confirmationError;
  String? unknowError;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Cadastro de Usuário',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    color: primaryBackground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                label: const Text('E-Mail'),
                border: const OutlineInputBorder(),
                errorText: emailError,
              ),
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
            TextField(
              controller: confirmationController,
              decoration: InputDecoration(
                label: const Text('Confirmação de senha'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    hideConfirmation ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      hideConfirmation = !hideConfirmation;
                    });
                  },
                ),
                errorText: confirmationError,
              ),
              obscureText: hideConfirmation,
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: register,
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(primaryBackground)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: loading
                      ? loadingAnimationButton
                      : const Text(
                        'Registar',
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
            const SizedBox(
              height: 12,
            ),
            Text(unknowError ?? '', style: const TextStyle(color: Colors.red)),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  void register() {
    String email = emailController.text;
    String password = passwordController.text;
    String confirmation = confirmationController.text;

    if (email.isEmpty) {
      setState(() {
        emailError = 'O e-mail é obrigatório';
        passwordError = null;
        confirmationError = null;
        unknowError = null;
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        emailError = null;
        passwordError = 'A senha é obrigatória';
        confirmationError = null;
        unknowError = null;
      });
      return;
    }
    if (confirmation.isEmpty) {
      setState(() {
        emailError = null;
        passwordError = null;
        confirmationError = 'A confirmação é obrigatória';
        unknowError = null;
      });
      return;
    }
    if (password != confirmation) {
      setState(() {
        emailError = null;
        passwordError = null;
        confirmationError = 'A senha está diferente da confirmação';
        unknowError = null;
      });
      return;
    }

    setState(() {loading = true;});
    registerShoppingList(email, password).then(
      (value) {
        setState(() {loading = false;});
        if (value['authenticated']) {
          AlertDialog alertDialog = AlertDialog(
            title: const Text('Parabéns!'),
            content: const Text('Seu usuário foi cadastrado com sucesso. '
                'Verifique se recebeu seu e-mail de confirmação.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, scaffoldKey);
                },
                child: const Text('Ok'),
              )
            ],
          );
          showDialog(
              context: context,
              builder: (context) {
                return alertDialog;
              });
        } else if (value['errorField'] == 'email') {
          setState(() {
            emailError = value['message'];
            passwordError = null;
            confirmationError = null;
            unknowError = null;
          });
        } else if (value['errorField'] == 'password') {
          setState(() {
            emailError =  null;
            passwordError = value['message'];
            confirmationError = null;
            unknowError = null;
          });
        } else if (value['errorField'] == 'confirmation') {
          setState(() {
            emailError = null;
            passwordError = null;
            confirmationError = value['message'];
            unknowError = null;
          });
        } else {
          setState(() {
            emailError = null;
            passwordError = null;
            confirmationError = null;
            unknowError = value['message'];
          });
        }
      },
    );
  }
}
