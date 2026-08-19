import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O DefaultTabController é um atalho do Flutter que já cria a lógica 
    // de deslizar o dedo ou clicar para trocar de aba, sem precisarmos gerenciar estado complexo agora.
    return DefaultTabController(
      length: 2, // Quantidade de abas que teremos
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212), // Mesma cor de fundo do app
          elevation: 0, // Remove a sombra abaixo da barra
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Afasta o título do ícone
            children: [
              // RichText permite ter palavras com cores diferentes na mesma frase
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
                  children: [
                    TextSpan(
                      text: 'Clear',
                      style: TextStyle(color: Color(0xFFFFD700)), // Amarelo Dourado
                    ),
                    TextSpan(
                      text: 'Money',
                      style: TextStyle(color: Colors.white70), // Branco levemente acinzentado
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/logo.png', // O nome deve ser EXATAMENTE igual ao arquivo
                height: 35, // Você pode aumentar ou diminuir esse número para ajustar o tamanho
              ),
            ],
          ),
          // TabBar é a barra inferior do AppBar, onde ficam os botões das abas
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFD700), // Cor da linha abaixo da aba selecionada
            labelColor: Color(0xFFFFD700),     // Cor do texto da aba selecionada
            unselectedLabelColor: Colors.grey, // Cor da aba inativa
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Inserir Gasto'),
            ],
          ),
        ),
        // O TabBarView mostra o conteúdo correspondente a cada aba.
        // Como o DefaultTabController tem length: 2, o TabBarView precisa ter exatamente 2 filhos (children).
        body: const TabBarView(
          children: [
            Center(
              child: Text(
                'Tela do Dashboard em construção...', 
                style: TextStyle(color: Colors.white)
              ),
            ),
            Center(
              child: Text(
                'Tela de Inserir Gasto em construção...', 
                style: TextStyle(color: Colors.white)
              ),
            ),
          ],
        ),
      ),
    );
  }
}