import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart'; // <-- Novo import da máscara

class InserirGastoTab extends StatefulWidget {
  const InserirGastoTab({super.key});

  @override
  State<InserirGastoTab> createState() => _InserirGastoTabState();
}

class _InserirGastoTabState extends State<InserirGastoTab> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _observacaoController = TextEditingController();

  // --- CONFIGURADOR DA MÁSCARA DE MOEDA (PT-BR) ---
  final CurrencyTextInputFormatter _moedaFormatter = CurrencyTextInputFormatter.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  );

  String? _categoriaSelecionada;
  String? _subcategoriaSelecionada;
  DateTime _dataSelecionada = DateTime.now();
  bool _carregando = false;

  final Map<String, List<String>> _categorias = {
    'Moradia': ['Aluguel', 'Condomínio', 'Água', 'Luz', 'Internet', 'Outros'],
    'Alimentação': ['Supermercado', 'Restaurante', 'Ifood/Delivery', 'Padaria', 'Outros'],
    'Transporte': ['Combustível', 'Uber/App', 'Transporte Público', 'Manutenção', 'Outros'],
    'Educação e Desenvolvimento': ['Cursos', 'Livros', 'Faculdade', 'Outros'],
    'Saúde e Cuidados Pessoais': ['Farmácia', 'Médico', 'Academia', 'Cabelereiro', 'Outros'],
    'Tecnologia e Softwares': ['Assinaturas', 'Equipamentos', 'Jogos', 'Outros'],
    'Lazer e Entretenimento': ['Cinema', 'Shows', 'Viagens', 'Outros'],
    'Vestuário': ['Roupas', 'Calçados', 'Acessórios', 'Outros'],
    'Impostos e Taxas': ['IPVA', 'IPTU', 'Bancárias', 'Outros'],
    'Poupança e Investimentos': ['Reserva', 'Ações', 'Cripto', 'Outros'],
    'Outros': ['Gerais'],
  };

  @override
  void dispose() {
    _valorController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
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
      setState(() => _dataSelecionada = escolhida);
    }
  }

  Future<void> _salvarGasto() async {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSelecionada == null || _subcategoriaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione a categoria e subcategoria'), backgroundColor: Colors.red));
        return;
      }

      // Validação para garantir que o valor não seja 0
      final num valorNumerico = _moedaFormatter.getUnformattedValue();
      if (valorNumerico <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um valor maior que zero'), backgroundColor: Colors.red));
        return;
      }

      setState(() => _carregando = true);
      try {
        final usuario = FirebaseAuth.instance.currentUser;
        if (usuario != null) {
          
          // O pacote já nos entrega o valor convertido em double limpo, sem precisar fazer "replace" manuais!
          double valorFinal = valorNumerico.toDouble();

          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario.uid)
              .collection('transacoes')
              .add({
            'valor': valorFinal,
            'categoria': _categoriaSelecionada,
            'subcategoria': _subcategoriaSelecionada,
            'data': Timestamp.fromDate(_dataSelecionada),
            'descricao': _observacaoController.text.trim(),
            'criadoEm': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gasto salvo com sucesso!'), backgroundColor: Colors.green));
            _valorController.clear();
            _observacaoController.clear();
            setState(() {
              _categoriaSelecionada = null;
              _subcategoriaSelecionada = null;
              _dataSelecionada = DateTime.now();
            });
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 800;

        final corFundoTela = isWeb ? Colors.transparent : const Color(0xFF121212);
        const corTexto = Colors.white;
        const corLabel = Colors.white54;
        const corFundoInput = Color(0xFF2C2C2C);
        final borda = OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        );

        return Container(
          color: corFundoTela,
          child: SingleChildScrollView(
            padding: isWeb ? const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0) : const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWeb ? 700 : double.infinity),
                
                child: Container(
                  padding: isWeb ? const EdgeInsets.all(40.0) : EdgeInsets.zero,
                  decoration: isWeb ? BoxDecoration(
                    color: const Color(0xFF1E1E1E), 
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ) : null,
                  
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Novo Gasto',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFD700), letterSpacing: 0),
                        ),
                        const SizedBox(height: 32),

                        TextFormField(
                          controller: _valorController,
                          style: const TextStyle(color: corTexto, fontSize: 18, letterSpacing: 0),
                          keyboardType: TextInputType.number, // Atualizado para chamar teclado numérico
                          inputFormatters: [_moedaFormatter], // <-- MÁSCARA APLICADA AQUI
                          decoration: InputDecoration(
                            labelText: 'Valor (R\$)',
                            labelStyle: const TextStyle(color: corLabel),
                            filled: true,
                            fillColor: corFundoInput,
                            border: borda,
                            enabledBorder: borda,
                            focusedBorder: borda.copyWith(borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
                            prefixIcon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Informe o valor' : null,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _categoriaSelecionada,
                          dropdownColor: corFundoInput,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
                          style: const TextStyle(color: corTexto, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            labelStyle: const TextStyle(color: corLabel),
                            filled: true,
                            fillColor: corFundoInput,
                            border: borda,
                            enabledBorder: borda,
                            focusedBorder: borda.copyWith(borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
                          ),
                          items: _categorias.keys.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: corTexto)));
                          }).toList(),
                          onChanged: (valor) {
                            setState(() {
                              _categoriaSelecionada = valor;
                              _subcategoriaSelecionada = null;
                            });
                          },
                          validator: (value) => value == null ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _subcategoriaSelecionada,
                          dropdownColor: corFundoInput,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
                          style: const TextStyle(color: corTexto, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Subcategoria',
                            labelStyle: const TextStyle(color: corLabel),
                            filled: true,
                            fillColor: corFundoInput,
                            border: borda,
                            enabledBorder: borda,
                            focusedBorder: borda.copyWith(borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
                          ),
                          items: _categoriaSelecionada == null 
                              ? [] 
                              : _categorias[_categoriaSelecionada]!.map((sub) {
                                  return DropdownMenuItem(value: sub, child: Text(sub, style: const TextStyle(color: corTexto)));
                                }).toList(),
                          onChanged: (valor) => setState(() => _subcategoriaSelecionada = valor),
                          validator: (value) => value == null ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 16),

                        InkWell(
                          onTap: () => _selecionarData(context),
                          child: IgnorePointer(
                            child: TextFormField(
                              style: const TextStyle(color: corTexto, letterSpacing: 0),
                              decoration: InputDecoration(
                                labelText: 'Data',
                                labelStyle: const TextStyle(color: corLabel),
                                filled: true,
                                fillColor: corFundoInput,
                                border: borda,
                                enabledBorder: borda,
                                suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFFFD700)),
                              ),
                              controller: TextEditingController(
                                text: '${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _observacaoController,
                          style: const TextStyle(color: corTexto, letterSpacing: 0),
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Observação (Opcional)',
                            labelStyle: const TextStyle(color: corLabel),
                            filled: true,
                            fillColor: corFundoInput,
                            border: borda,
                            enabledBorder: borda,
                            focusedBorder: borda.copyWith(borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2)),
                          ),
                        ),
                        const SizedBox(height: 40), 

                        Center(
                          child: SizedBox(
                            width: isWeb ? 300 : double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _carregando ? null : _salvarGasto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _carregando
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : const Text('SALVAR GASTO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}