import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importa a tela principal para navegarmos até ela

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Variável que controla se a tela exibe o modo "Login" ou "Cadastro"
  bool _isLogin = true; 

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Como ainda não conectamos o Firebase ao app, vamos apenas 
      // simular o sucesso e navegar para a tela de Dashboard/Home.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Fundo principal escuro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nossa logo dourada resgatada
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 40),
                
                Text(
                  _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
                // Campo de E-mail
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.email, color: Colors.white54),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Informe seu e-mail' : null,
                ),
                const SizedBox(height: 16),
                
                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Oculta a senha digitada
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe sua senha';
                    if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Botão de Ação
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isLogin ? 'ENTRAR' : 'CADASTRAR',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Botão para alternar entre Login e Cadastro
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin; // Inverte o estado da tela
                    });
                  },
                  child: Text(
                    _isLogin ? 'Não tem uma conta? Cadastre-se' : 'Já tem uma conta? Entre aqui',
                    style: const TextStyle(color: Color(0xFFFFD700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}