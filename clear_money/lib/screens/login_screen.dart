import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController(); // Novo controlador para confirmar senha
  
  bool _isLogin = true; 
  bool _carregando = false;
  
  // Variáveis para controlar o "olhinho" de mostrar/ocultar senha
  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  Future<void> _submeter() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      try {
        if (_isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text.trim(),
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String mensagem = 'Ocorreu um erro.';
        if (e.code == 'user-not-found') mensagem = 'Usuário não encontrado.';
        if (e.code == 'wrong-password') mensagem = 'Senha incorreta.';
        if (e.code == 'email-already-in-use') mensagem = 'Este e-mail já está cadastrado.';
        if (e.code == 'weak-password') mensagem = 'A senha é muito fraca.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  Future<void> _loginComGoogle() async {
    setState(() => _carregando = true);
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
        if (googleUser == null) {
          setState(() => _carregando = false);
          return;
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao entrar com o Google: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    // Limpamos os controladores quando a tela for fechada
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 48,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFFFFD700),
                          size: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          children: [
                            TextSpan(text: 'Clear', style: TextStyle(color: Color(0xFFFFD700))),
                            TextSpan(text: 'Money', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white, letterSpacing: 0),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFFD700)),
                    ),
                    validator: (value) => value == null || !value.contains('@') ? 'E-mail inválido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _senhaController,
                    style: const TextStyle(color: Colors.white, letterSpacing: 0),
                    obscureText: _senhaOculta, // Usa a nossa variável para esconder/mostrar
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFD700)),
                      // O olhinho no final do campo
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaOculta ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaOculta = !_senhaOculta;
                          });
                        },
                      ),
                    ),
                    validator: (value) => value == null || value.length < 6 ? 'A senha deve ter pelo menos 6 caracteres' : null,
                  ),
                  
                  // --- CAMPO DE CONFIRMAR SENHA (SÓ APARECE NO CADASTRO) ---
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmarSenhaController,
                      style: const TextStyle(color: Colors.white, letterSpacing: 0),
                      obscureText: _confirmarSenhaOculta,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2C2C2C),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFD700)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmarSenhaOculta ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white54,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmarSenhaOculta = !_confirmarSenhaOculta;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirme a senha';
                        if (value != _senhaController.text) return 'As senhas não coincidem';
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _submeter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _carregando
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(_isLogin ? 'ENTRAR' : 'CADASTRAR', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0)),
                    ),
                  ),
                  
                  // --- BOTÃO DO GOOGLE (SÓ APARECE NO LOGIN) ---
                  if (_isLogin) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _loginComGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          foregroundColor: Colors.white, 
                          padding: const EdgeInsets.symmetric(horizontal: 4), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const SweepGradient(
                                    center: Alignment.center,
                                    startAngle: 0.0,
                                    endAngle: 3.14 * 2,
                                    colors: [
                                      Color(0xFF4285F4),
                                      Color(0xFF34A853),
                                      Color(0xFFFBBC05),
                                      Color(0xFFEA4335),
                                      Color(0xFF4285F4),
                                    ],
                                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                                  ).createShader(bounds);
                                },
                                child: const Icon(
                                  Icons.g_mobiledata, 
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Continuar com o Google',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 42), 
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        // Limpa os campos se o usuário alternar as telas
                        _emailController.clear();
                        _senhaController.clear();
                        _confirmarSenhaController.clear();
                      });
                    },
                    child: Text(
                      _isLogin ? 'Não tem uma conta? Cadastre-se' : 'Já tem uma conta? Entre',
                      style: const TextStyle(color: Color(0xFFFFD700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}