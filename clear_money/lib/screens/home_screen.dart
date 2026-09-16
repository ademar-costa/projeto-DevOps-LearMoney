import 'package:flutter/material.dart';
import 'dashboard_tab.dart';
import 'inserir_gasto_tab.dart';
import 'perfil_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indiceAtual = 0;

  // Lista com as 3 abas
  final List<Widget> _telas = [
    const DashboardTab(),
    const InserirGastoTab(),
    const PerfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        // --- TÍTULO CORRIGIDO COM LOGO À DIREITA ---
        title: Row(
          mainAxisSize: MainAxisSize.min, // Garante que fique centralizado
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                children: [
                  TextSpan(text: 'Clear', style: TextStyle(color: Color(0xFFFFD700))),
                  TextSpan(text: 'Money', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/logo.png',
              height: 28,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFFFFD700),
                size: 28,
              ),
            ),
          ],
        ),
      ),
      body: _telas[_indiceAtual],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        currentIndex: _indiceAtual,
        onTap: (indice) {
          setState(() {
            _indiceAtual = indice;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Novo Gasto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}