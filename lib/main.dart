import 'package:flutter/material.dart';
import 'package:pixcellz/models/auth_model.dart';
import 'package:pixcellz/ui/auth/login_page.dart';
import 'package:pixcellz/ui/auth/login_viewmodel.dart';
import 'package:pixcellz/ui/auth/signup_page.dart';
import 'package:pixcellz/ui/auth/signup_viewmodel.dart';
import 'package:pixcellz/ui/home/home_page.dart';
import 'package:pixcellz/utils/auth_observer.dart';
import 'package:provider/provider.dart';

void main() {
 runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LoginViewModel()),
      ChangeNotifierProvider(create: (context) => AuthModel()),
      ChangeNotifierProvider(create: (context) => SignupViewModel()),
    ],
    child: const PixCellZ(),
  ));
}

class PixCellZ extends StatelessWidget {
  const PixCellZ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projet Annuel',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
      navigatorObservers: [AuthObserver()],
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFD90B0B),
          onPrimary: Color(0xFFFFFFFF),
          secondary: Color(0xFF1C1C1C),
          onSecondary: Color(0xFFBABABA),
          tertiary: Color(0xFF4A4A4A),
          onTertiary: Color(0xFFFFFFFF),
          error: Colors.red,
          onError: Color.fromARGB(255, 1, 1, 1),
          surface: Color(0xFF292929),
          onSurface: Color(0xFFD90B0B),
        ),
      ),
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
    );
  }
}