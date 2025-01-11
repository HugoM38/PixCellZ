import 'package:flutter/material.dart';
import 'package:pixcellz/ui/auth/login_page.dart';
import 'package:pixcellz/ui/auth/signup_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pixcellz/ui/widgets/pixcellz_appbar.dart';
import 'package:pixcellz/ui/widgets/pixcellz_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignupViewModel>(context);

    return Scaffold(
      appBar: const PixCellZAppBar(title: "PixCellZ"),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Inscription à PixCellZ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                viewModel.setUsernameFieldTouched();
                              }
                            },
                            child: TextFormField(
                              controller: viewModel.usernameController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: "Pseudo",
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                errorText: viewModel.isUsernameFieldTouched
                                    ? viewModel.usernameError
                                    : null,
                                errorMaxLines: 2,
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                viewModel.setEmailFieldTouched();
                              }
                            },
                            child: TextFormField(
                              controller: viewModel.emailController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: "Adresse email",
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                errorText: viewModel.isEmailFieldTouched
                                    ? viewModel.emailError
                                    : null,
                                errorMaxLines: 2,
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                viewModel.setPasswordFieldTouched();
                              }
                            },
                            child: TextFormField(
                              controller: viewModel.passwordController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                errorText: viewModel.isPasswordFieldTouched
                                    ? viewModel.passwordError
                                    : null,
                                errorMaxLines: 6,
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.secondary,
                              ),
                              obscureText: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      PixCellZButton(
                        title: "S'inscrire",
                        isLoading: viewModel.isLoading,
                        isEnable: viewModel.isEnableSignupButton(),
                        onPressed: () async {
                          await viewModel.signup(context);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          "Déjà un compte ? Se connecter",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
