import 'package:flutter/material.dart';

void main() {
  runApp(const ClearMoneyApp());
}

class ClearMoneyApp extends StatelessWidget {
  const ClearMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearMoney',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Cor de fundo escura do seu design
      ),
      // Scaffold é a estrutura básica de uma tela, por enquanto estará vazia
      home: const Scaffold(), 
    );
  }
}