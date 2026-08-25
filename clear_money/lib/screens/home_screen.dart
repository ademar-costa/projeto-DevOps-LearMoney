import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'dashboard_tab.dart';
import 'inserir_gasto_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Função para deslogar do Firebase
  Future<void> _sair(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), 
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          // 1 e 2. Nome na esquerda com duas cores
          title: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.2,
              ),
              children: [
                TextSpan(
                  text: 'Clear', 
                  style: TextStyle(color: Color(0xFFFFD700)), // Amarelo
                ),
                TextSpan(
                  text: 'Money', 
                  style: TextStyle(color: Colors.grey), // Cinza
                ),
              ],
            ),
          ),
          // 1. Logo jogada para a direita (actions)
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset(
                'assets/logo.png', 
                height: 32, 
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_wallet, 
                  color: Color(0xFFFFD700), 
                  size: 32,
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFD700), 
            labelColor: Color(0xFFFFD700),     
            unselectedLabelColor: Colors.white54, 
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Inserir Gasto'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardTab(),     
            InserirGastoTab(),  
          ],
        ),
        
        // 3. Botão preso no rodapé (não passa por cima do conteúdo)
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: const Color(0xFF121212), // Mesma cor do fundo da tela
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Joga o botão para a direita
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C), // Fundo escuro do botão
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    tooltip: 'Sair da conta',
                    onPressed: () => _sair(context),
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