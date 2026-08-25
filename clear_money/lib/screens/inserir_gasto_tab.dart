import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class InserirGastoTab extends StatefulWidget {
  const InserirGastoTab({super.key});

  @override
  State<InserirGastoTab> createState() => _InserirGastoTabState();
}

class _InserirGastoTabState extends State<InserirGastoTab> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  DateTime? _dataSelecionada = DateTime.now();
  String? _categoriaSelecionada;
  String? _subcategoriaSelecionada;

  // 2. Criando o formatador de moeda para o padrão brasileiro
  final CurrencyTextInputFormatter _moedaFormatter = CurrencyTextInputFormatter.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  final Map<String, List<String>> _categorias = {
    'Moradia': ['Aluguel/Prestação', 'Condomínio', 'Energia Elétrica', 'Água', 'Gás', 'Internet', 'Manutenção e Reparos'],
    'Alimentação': ['Supermercado', 'Padaria', 'Restaurantes/Lanches fora', 'Delivery'],
    'Transporte': ['Passagem de Ônibus/Metrô', 'Combustível', 'Aplicativos de Transporte (Uber/99)', 'Manutenção do Veículo'],
    'Educação e Desenvolvimento': ['Mensalidades/Taxas', 'Materiais e Projetos (IFB)', 'Cursos de Tecnologia (Flutter/Dart)', 'Concursos Públicos', 'Livros'],
    'Tecnologia e Softwares': ['Serviços de Nuvem (Firebase/MCP)', 'Licenças de Softwares', 'Manutenção', 'Domínios'],
    'Outros': ['Presentes', 'Apoio a Projetos Sociais/Doações', 'Despesas Inesperadas'],
  };

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF2C2C2C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (escolhida != null && escolhida != _dataSelecionada) {
      setState(() {
        _dataSelecionada = escolhida;
      });
    }
  }

  Future<void> _salvarGasto() async {
    if (_formKey.currentState!.validate()) {
      // 1. Pega o número puro (sem R$ e vírgulas)
      final valorPuro = _moedaFormatter.getUnformattedValue().toDouble();
      
      // 2. Descobre quem é o usuário logado agora
      final usuario = FirebaseAuth.instance.currentUser;
      
      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não autenticado.'), backgroundColor: Colors.red),
        );
        return;
      }

      try {
        // 3. Monta o caminho exato que autorizamos nas regras de segurança:
        // /usuarios/{userId}/transacoes/{transacaoId}
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .collection('transacoes')
            .add({
          'valor': valorPuro,
          'data': Timestamp.fromDate(_dataSelecionada!), // Formato do Firebase
          'categoria': _categoriaSelecionada,
          'subcategoria': _subcategoriaSelecionada,
          'descricao': _descricaoController.text.trim(),
        });

        // 4. Se chegou aqui, o Firebase aceitou gravar!
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gasto salvo na nuvem com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Limpa o formulário para o próximo uso
          _valorController.clear();
          _descricaoController.clear();
          setState(() {
            _categoriaSelecionada = null;
            _subcategoriaSelecionada = null;
          });
        }
      } catch (e) {
        // Se a Regra de Segurança barrar ou houver erro de internet
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar no banco: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de VALOR ATUALIZADO
            TextFormField(
              controller: _valorController,
              keyboardType: TextInputType.number, // Mantém apenas o teclado numérico
              inputFormatters: [_moedaFormatter], // 3. Aplica a máscara aqui
              style: const TextStyle(fontSize: 32, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                // Removemos o prefixText manual daqui
                labelText: 'Valor',
                labelStyle: const TextStyle(color: Colors.white54, fontSize: 16),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              validator: (value) {
                // Valida se o usuário não deixou zerado
                if (value == null || value.isEmpty || _moedaFormatter.getUnformattedValue() <= 0) {
                  return 'Informe um valor maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de DATA
            InkWell(
              onTap: () => _selecionarData(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dataSelecionada != null 
                          ? '${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}' 
                          : 'Selecione uma data',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFFFFD700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de CATEGORIA
            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              dropdownColor: const Color(0xFF2C2C2C),
              decoration: InputDecoration(
                labelText: 'Categoria',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: _categorias.keys.map((String categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? novaCategoria) {
                setState(() {
                  _categoriaSelecionada = novaCategoria;
                  _subcategoriaSelecionada = null; 
                });
              },
              validator: (value) => value == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 20),

            // Campo de SUBCATEGORIA
            DropdownButtonFormField<String>(
              value: _subcategoriaSelecionada,
              dropdownColor: const Color(0xFF2C2C2C),
              decoration: InputDecoration(
                labelText: 'Subcategoria',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: _categoriaSelecionada == null 
                  ? [] 
                  : _categorias[_categoriaSelecionada]!.map((String sub) {
                      return DropdownMenuItem<String>(
                        value: sub,
                        child: Text(sub, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
              onChanged: _categoriaSelecionada == null ? null : (String? novaSub) {
                setState(() {
                  _subcategoriaSelecionada = novaSub;
                });
              },
              validator: (value) => value == null ? 'Selecione uma subcategoria' : null,
            ),
            const SizedBox(height: 20),

            // Campo de DESCRIÇÃO
            TextFormField(
              controller: _descricaoController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descrição ou Observação (Opcional)',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),

            // Botão de SALVAR
            ElevatedButton(
              onPressed: _salvarGasto,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'SALVAR GASTO',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}