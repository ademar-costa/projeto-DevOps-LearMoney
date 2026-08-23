import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importamos o arquivo que acabamos de criar
import 'screens/login_screen.dart';

void main() {
  runApp(const ClearMoneyApp());
}

class ClearMoneyApp extends StatelessWidget {
  const ClearMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearMoney',
      debugShowCheckedModeBanner: false, // Remove a faixa "DEBUG" do canto da tela
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD700),
      ),
      home: const LoginScreen(), // Agora apontamos para a nossa tela inicial customizada
    );
  }
}