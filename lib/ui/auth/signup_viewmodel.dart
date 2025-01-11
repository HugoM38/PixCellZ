import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pixcellz/services/auth_service.dart';
import 'package:pixcellz/utils/show_error_snackbar.dart';

class SignupViewModel extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9])[^\s]{8,}$',
  );

  String? usernameError;
  String? emailError;
  String? passwordError;
  bool isLoading = false;
  bool isUsernameFieldTouched = false;
  bool isEmailFieldTouched = false;
  bool isPasswordFieldTouched = false;

  SignupViewModel() {
    usernameController.addListener(_onUsernameChanged);
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onUsernameChanged() {
    if (isUsernameFieldTouched) validateUsername();
    notifyListeners();
  }

  void _onEmailChanged() {
    if (isEmailFieldTouched) validateEmail();
    notifyListeners();
  }

  void _onPasswordChanged() {
    if (isPasswordFieldTouched) validatePassword();
    notifyListeners();
  }

  void setUsernameFieldTouched() {
    isUsernameFieldTouched = true;
    validateUsername();
  }

  void setEmailFieldTouched() {
    isEmailFieldTouched = true;
    validateEmail();
  }

  void setPasswordFieldTouched() {
    isPasswordFieldTouched = true;
    validatePassword();
  }

  void validateUsername() {
    if (!isUsernameFieldTouched) return;

    if (usernameController.text.isEmpty) {
      usernameError = "Le pseudo est requis";
    } else if (!usernameRegex.hasMatch(usernameController.text)) {
      usernameError =
          "Le pseudo doit contenir entre 3 et 20 caractères alphanumériques ou _";
    } else {
      usernameError = null;
    }
    notifyListeners();
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
- Au moins un caractère spécial""";
    } else {
      passwordError = null;
    }
    notifyListeners();
  }

  bool isEnableSignupButton() {
    return usernameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        usernameError == null &&
        emailError == null &&
        passwordError == null &&
        !isLoading;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signup(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      Response response = await AuthService().signup(
        usernameController.text,
        emailController.text,
        passwordController.text,
      );

      if (response.statusCode == 201) {
        if (context.mounted) {
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
