import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  // Puxa o usuário atual logado no Firebase
  User? usuario = FirebaseAuth.instance.currentUser;

  // Função para deslogar do aplicativo
  Future<void> _sair() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Função para exibir a janela de edição de nome
  void _editarPerfil() {
    final nomeController = TextEditingController(text: usuario?.displayName ?? '');
    bool carregando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Editar Perfil', style: TextStyle(color: Color(0xFFFFD700))),
              content: TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome de Exibição',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: carregando ? null : () async {
                    setStateDialog(() => carregando = true);
                    try {
                      // Atualiza o nome no Firebase
                      await usuario?.updateDisplayName(nomeController.text.trim());
                      await usuario?.reload(); // Recarrega os dados do usuário
                      
                      // Atualiza a tela de perfil com o novo nome
                      setState(() {
                        usuario = FirebaseAuth.instance.currentUser;
                      });
                      
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao atualizar perfil.'), backgroundColor: Colors.red),
                      );
                    } finally {
                      setStateDialog(() => carregando = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                  child: carregando 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('Salvar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se a foto existe, senão usa um ícone padrão
    final fotoUrl = usuario?.photoURL;
    final nome = usuario?.displayName ?? 'Usuário';
    final email = usuario?.email ?? 'Sem e-mail';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          
          // --- FOTO DE PERFIL ---
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF2C2C2C),
            backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
            child: fotoUrl == null 
                ? const Icon(Icons.person, size: 60, color: Color(0xFFFFD700)) 
                : null,
          ),
          const SizedBox(height: 24),
          
          // --- NOME E E-MAIL ---
          Text(
            nome,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: const TextStyle(fontSize: 16, color: Colors.white54, letterSpacing: 0),
          ),
          const SizedBox(height: 48),

          // --- BOTÃO EDITAR PERFIL ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _editarPerfil,
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text('Editar Perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- BOTÃO SAIR ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _sair,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Sair do Aplicativo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}