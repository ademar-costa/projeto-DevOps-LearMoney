import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import do Firebase Auth
import 'home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true; 
  bool _isLoading = false; // Controla o ícone de carregamento

  // Instância do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Mostra que está carregando
      });

      try {
        if (_isLogin) {
          // Tenta FAZER LOGIN
          await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          // Tenta CRIAR UMA CONTA
          await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        }

        // Se deu tudo certo, navega para a tela principal
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Se o Firebase retornar um erro, mostramos na tela
        String mensagemErro = 'Ocorreu um erro ao autenticar.';
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          mensagemErro = 'E-mail ou senha incorretos.';
        } else if (e.code == 'email-already-in-use') {
          mensagemErro = 'Este e-mail já está cadastrado.';
        } else if (e.code == 'weak-password') {
          mensagemErro = 'A senha é muito fraca.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensagemErro), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Esconde o carregamento
          });
        }
      }
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
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/logo.png', height: 100, errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet, size: 100, color: Color(0xFFFFD700))),
                const SizedBox(height: 40),
                
                Text(
                  _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
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
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
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
                
                // Botão dinâmico (mostra carregando ou o texto)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      disabledBackgroundColor: Colors.grey,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            _isLogin ? 'ENTRAR' : 'CADASTRAR',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
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