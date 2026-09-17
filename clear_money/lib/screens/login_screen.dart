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
  final _confirmarSenhaController = TextEditingController();
  
  bool _isLogin = true; 
  bool _carregando = false;
  bool _senhaOculta = true;
  bool _confirmarSenhaOculta = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _submeter() async {
    if (_formKey.currentState?.validate() ?? false) {
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      } on FirebaseAuthException catch (e) {
        String mensagem = 'Ocorreu um erro.';
        if (e.code == 'user-not-found') mensagem = 'Usuário não encontrado.';
        if (e.code == 'wrong-password') mensagem = 'Senha incorreta.';
        if (e.code == 'email-already-in-use') mensagem = 'Este e-mail já está cadastrado.';
        if (e.code == 'weak-password') mensagem = 'A senha é muito fraca.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: Colors.red));
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
        final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao entrar com o Google: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Widget _buildLogoInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo.png',
          height: 120,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance_wallet, color: Color(0xFFFFD700), size: 120),
        ),
        const SizedBox(height: 24),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            children: [
              TextSpan(text: 'Clear', style: TextStyle(color: Color(0xFFFFD700))),
              TextSpan(text: 'Money', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isFundoClaro) {
    final corTexto = isFundoClaro ? Colors.black87 : Colors.white;
    final corLabel = isFundoClaro ? Colors.black54 : Colors.white54;
    // Se for o fundo claro da Web, deixa as caixas de input brancas para dar contraste!
    final corFundoInput = isFundoClaro ? Colors.white : const Color(0xFF2C2C2C);
    final corIcone = isFundoClaro ? Colors.black54 : const Color(0xFFFFD700);
    final corBotaoTexto = isFundoClaro ? Colors.black87 : const Color(0xFFFFD700); 

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: corTexto, letterSpacing: 0),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail',
              labelStyle: TextStyle(color: corLabel),
              filled: true,
              fillColor: corFundoInput,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.email_outlined, color: corIcone),
            ),
            validator: (value) => value == null || !value.contains('@') ? 'E-mail inválido' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _senhaController,
            style: TextStyle(color: corTexto, letterSpacing: 0),
            obscureText: _senhaOculta,
            decoration: InputDecoration(
              labelText: 'Senha',
              labelStyle: TextStyle(color: corLabel),
              filled: true,
              fillColor: corFundoInput,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.lock_outline, color: corIcone),
              suffixIcon: IconButton(
                icon: Icon(_senhaOculta ? Icons.visibility_off : Icons.visibility, color: corLabel),
                onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
              ),
            ),
            validator: (value) => value == null || value.length < 6 ? 'Mínimo de 6 caracteres' : null,
          ),
          
          if (!_isLogin) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmarSenhaController,
              style: TextStyle(color: corTexto, letterSpacing: 0),
              obscureText: _confirmarSenhaOculta,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                labelStyle: TextStyle(color: corLabel),
                filled: true,
                fillColor: corFundoInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: Icon(Icons.lock_outline, color: corIcone),
                suffixIcon: IconButton(
                  icon: Icon(_confirmarSenhaOculta ? Icons.visibility_off : Icons.visibility, color: corLabel),
                  onPressed: () => setState(() => _confirmarSenhaOculta = !_confirmarSenhaOculta),
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

          if (_isLogin) ...[
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
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const SweepGradient(
                          center: Alignment.center,
                          startAngle: 0.0,
                          endAngle: 3.14 * 2,
                          colors: [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05), Color(0xFFEA4335), Color(0xFF4285F4)],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ).createShader(bounds),
                        child: const Icon(Icons.g_mobiledata, size: 40, color: Colors.white),
                      ),
                    ),
                    const Expanded(child: Center(child: Text('Continuar com o Google', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                  : Text(_isLogin ? 'ENTRAR' : 'CADASTRAR', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
                _emailController.clear();
                _senhaController.clear();
                _confirmarSenhaController.clear();
              });
            },
            child: Text(
              _isLogin ? 'Não tem uma conta? Cadastre-se' : 'Já tem uma conta? Entre', 
              style: TextStyle(color: corBotaoTexto, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;

          if (isWeb) {
            return Row(
              children: [
                Expanded(
                  flex: 65, 
                  child: Container(
                    color: const Color(0xFF121212),
                    child: Center(child: _buildLogoInfo()),
                  ),
                ),
                Expanded(
                  flex: 35, 
                  child: Container(
                    // --- COR DO FUNDO WEB APLICADA AQUI (#F2EDD5 em vez de Colors.white) ---
                    color: const Color(0xFFF2EDD5),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _buildForm(true),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogoInfo(),
                      const SizedBox(height: 48),
                      _buildForm(false),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}