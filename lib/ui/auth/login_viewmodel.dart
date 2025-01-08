import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pixcellz/services/auth_service.dart';
import 'package:pixcellz/utils/show_error_snackbar.dart';
import 'package:provider/provider.dart';

import '../../models/auth_model.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  
  final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&.])[A-Za-z\d@$!%*?&.]{8,}$',
  );

  String? emailError;
  String? passwordError;
  bool isLoading = false;
  bool isEmailFieldTouched = false;
  bool isPasswordFieldTouched = false;

  LoginViewModel() {
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onEmailChanged() {
    if (isEmailFieldTouched) {
      validateEmail();
    }
    notifyListeners();
  }

  void _onPasswordChanged() {
    if (isPasswordFieldTouched) {
      validatePassword();
    }
    notifyListeners();
  }

  void setEmailFieldTouched() {
    isEmailFieldTouched = true;
    validateEmail();
  }

  void setPasswordFieldTouched() {
    isPasswordFieldTouched = true;
    validatePassword();
  }

  void validateEmail() {
    if (!isEmailFieldTouched) return;

    if (emailController.text.isEmpty) {
      emailError = "L'email est requis";
    } else if (!emailRegex.hasMatch(emailController.text)) {
      emailError = "Format d'email invalide";
    } else {
      emailError = null;
    }
    notifyListeners();
  }

  void validatePassword() {
    if (!isPasswordFieldTouched) return;

    if (passwordController.text.isEmpty) {
      passwordError = "Le mot de passe est requis";
    } else if (!passwordRegex.hasMatch(passwordController.text)) {
      passwordError = """Le mot de passe doit contenir :
- Au moins 8 caractères
- Au moins une majuscule
- Au moins une minuscule
- Au moins un chiffre
- Au moins un caractère spécial (@\$!%*?&.)""";
    } else {
      passwordError = null;
    }
    notifyListeners();
  }

  bool isEnableLoginButton() {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        emailError == null &&
        passwordError == null &&
        !isLoading;
  }

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordChanged);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      Response response =
          await AuthService().login(emailController.text, passwordController.text);

      if (response.statusCode == 200) {
        if (context.mounted) {
          final authModel = Provider.of<AuthModel>(context, listen: false);
          authModel.isLoggedIn = true;
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackbar(context, e.toString());
      }
    }

    isLoading = false;
    notifyListeners();
  }
}