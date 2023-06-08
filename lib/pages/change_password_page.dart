import 'package:flutter/material.dart';
import 'package:shopping_list_new/general/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController emailController = TextEditingController();

  String? emailError;

  bool loading = false;

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
                  'Alteração de senha',
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
              controller: emailController,
              decoration: InputDecoration(
                label: const Text('E-mail'),
                border: const OutlineInputBorder(),
                errorText: emailError,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: resetPassword,
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(primaryBackground)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: loading
                          ? loadingAnimationButton
                          : const Text(
                              'Redefinir',
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
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  void resetPassword() {
    String email = emailController.text;

    if (email.isEmpty) {
      setState(() {
        emailError = 'Campo obrigatório';
      });
      return;
    }

    AlertDialog alertConfirm = AlertDialog(
      title: const Text('E-mail enviado'),
      content: const Text('Um e-mail com o link de alteração de senha foi enviado, '
          'através dele conseguirá alterar sua senha.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text('Ok'),
        )
      ],
    );

    setState(() {
      loading = true;
    });
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text)
        .then((value) {
      setState(() {
        loading = false;
      });
      showDialog(context: context, builder: (context) => alertConfirm);
    });
  }
}
