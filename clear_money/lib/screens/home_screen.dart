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

  final List<Widget> _telas = [
    const DashboardTab(),
    const InserirGastoTab(),
    const PerfilTab(),
  ];

  Widget _buildTituloText() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        children: [
          TextSpan(text: 'Clear', style: TextStyle(color: Color(0xFFFFD700))),
          TextSpan(text: 'Money', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLogoIcon(double tamanho) {
    return Image.asset(
      'assets/logo.png',
      height: tamanho,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.account_balance_wallet,
        color: const Color(0xFFFFD700),
        size: tamanho,
      ),
    );
  }

  Widget _buildTopBarMobile() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTituloText(),
        const SizedBox(width: 8),
        _buildLogoIcon(28),
      ],
    );
  }

  Widget _buildSidebarItem(String titulo, IconData icone, int indice) {
    final selecionado = _indiceAtual == indice;
    final corAtiva = selecionado ? const Color(0xFFFFD700) : Colors.white54;

    return InkWell(
      onTap: () => setState(() => _indiceAtual = indice),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        color: selecionado ? const Color(0xFF2C2C2C) : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: TextStyle(
                color: corAtiva,
                fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            Icon(
              icone,
              color: corAtiva,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: isWeb ? null : AppBar(
            backgroundColor: const Color(0xFF1E1E1E),
            elevation: 0,
            centerTitle: true,
            title: _buildTopBarMobile(),
          ),
          
          body: isWeb 
            ? Column(
                children: [
                  Container(
                    height: 60,
                    color: const Color(0xFF1E1E1E),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.centerLeft,
                    child: _buildTituloText(),
                  ),
                  
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 250,
                          color: const Color(0xFF161616),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 40),
                              _buildSidebarItem('Dashboard', Icons.pie_chart, 0),
                              _buildSidebarItem('Adicionar gastos', Icons.add_circle, 1),
                              _buildSidebarItem('Perfil', Icons.person, 2),
                              
                              const Spacer(), 
                              
                              Center(child: _buildLogoIcon(90)), 
                              const SizedBox(height: 16), 
                              
                              // --- RODAPÉ MOVIDO PARA A BARRA LATERAL ---
                              const Center(
                                child: Text(
                                  'Todos os Direitos reservados 2026',
                                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                        
                        Expanded(
                          child: Container(
                            color: const Color(0xFFF2EDD5), // Agora essa cor ocupa 100% da área
                            child: _telas[_indiceAtual],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : _telas[_indiceAtual],
            
          bottomNavigationBar: isWeb ? null : BottomNavigationBar(
            backgroundColor: const Color(0xFF1E1E1E),
            selectedItemColor: const Color(0xFFFFD700),
            unselectedItemColor: Colors.white54,
            currentIndex: _indiceAtual,
            onTap: (indice) => setState(() => _indiceAtual = indice),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Novo Gasto'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        );
      }
    );
  }
}