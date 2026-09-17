import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  User? usuario = FirebaseAuth.instance.currentUser;

  Future<void> _sair() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

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
                      await usuario?.updateDisplayName(nomeController.text.trim());
                      await usuario?.reload(); 
                      
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
    final fotoUrl = usuario?.photoURL;
    final nome = usuario?.displayName ?? 'Usuário';
    final email = usuario?.email ?? 'Sem e-mail';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 800;

        // Se for Web, o fundo da tela é transparente (vaza o bege). No celular é o preto padrão.
        final corFundoTela = isWeb ? Colors.transparent : const Color(0xFF121212);

        return Container(
          color: corFundoTela,
          child: SingleChildScrollView(
            padding: isWeb ? const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0) : const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWeb ? 700 : double.infinity),
                
                // --- INÍCIO DO CARTÃO DA WEB ---
                child: Container(
                  padding: isWeb ? const EdgeInsets.all(40.0) : EdgeInsets.zero,
                  decoration: isWeb ? BoxDecoration(
                    color: const Color(0xFF1E1E1E), // Cor escura do cartão
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ) : null,
                  
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Se for celular a margem já vem do padding, na Web o card já dá o respiro
                      if (!isWeb) const SizedBox(height: 32),
                      
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 16, color: Colors.white54, letterSpacing: 0),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // --- BOTÃO EDITAR PERFIL (COMPACTO NA WEB) ---
                      Center(
                        child: SizedBox(
                          width: isWeb ? 300 : double.infinity,
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
                      ),
                      const SizedBox(height: 16),

                      // --- BOTÃO SAIR (COMPACTO NA WEB) ---
                      Center(
                        child: SizedBox(
                          width: isWeb ? 300 : double.infinity,
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
                      ),
                    ],
                  ),
                ),
                // --- FIM DO CARTÃO DA WEB ---
              ),
            ),
          ),
        );
      }
    );
  }
}