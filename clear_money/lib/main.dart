import 'package:flutter/material.dart';
import 'package:clearmoney/screens/login_screen.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}