import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options_web.dart'; // Importa o arquivo das chaves
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Chama a variável que está no outro arquivo com a chaves
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web, 
  );

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