import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class InserirGastoTab extends StatefulWidget {
  const InserirGastoTab({super.key});

  @override
  State<InserirGastoTab> createState() => _InserirGastoTabState();
}

class _InserirGastoTabState extends State<InserirGastoTab> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  String? _categoriaSelecionada;
  String? _subcategoriaSelecionada;
  DateTime _dataSelecionada = DateTime.now();
  
  final CurrencyTextInputFormatter _moedaFormatter = CurrencyTextInputFormatter.currency(
    locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2,
  );

  // Mapeamento atualizado conforme a nova imagem enviada
  final Map<String, List<String>> _mapaDespesas = {
    'Moradia': ['Aluguel/Prestação', 'Condomínio', 'Energia Elétrica', 'Água', 'Gás', 'Internet', 'Manutenção e Reparos'],
    'Alimentação': ['Supermercado', 'Padaria', 'Restaurantes/Lanches fora', 'Delivery'],
    'Transporte': ['Passagem de Ônibus/Metrô', 'Combustível', 'Aplicativos de Transporte (Uber/99)', 'Manutenção do Veículo'],
    'Educação e Desenvolvimento': ['Mensalidades/Taxas Escolares', 'Materiais e Projetos', 'Cursos', 'Inscrição em Concursos Públicos', 'Livros e Apostilas'],
    'Saúde e Cuidados Pessoais': ['Plano de Saúde', 'Farmácia/Medicamentos', 'Academia', 'Cabelereiro/Barbearia', 'Higiene Pessoal'],
    'Tecnologia e Softwares': ['Serviços de Nuvem', 'Licenças de Softwares', 'Manutenção de Equipamentos', 'Domínios e Hospedagem'],
    'Lazer e Entretenimento': ['Serviços de Streaming', 'Cinema e Teatro', 'Música e Instrumentos', 'Passeios e Eventos'],
    'Vestuário': ['Roupas', 'Calçados', 'Acessórios'],
    'Impostos e Taxas': ['Tarifas Bancárias', 'Anuidade de Cartão de Crédito', 'Impostos (IPVA/IPTU/etc)'],
    'Poupança e Investimentos': ['Reserva de Emergência', 'Tesouro Direto / Renda Fixa', 'Investimentos Variáveis'],
    'Outros': ['Presentes', 'Apoio a Projetos Sociais/Doações', 'Despesas Inesperadas']
  };

  Future<void> _salvarTransacao() async {
    if (_formKey.currentState!.validate()) {
      final valorPuro = _moedaFormatter.getUnformattedValue().toDouble();
      if (valorPuro <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('O valor deve ser maior que zero.'), backgroundColor: Colors.red));
        return;
      }

      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return;

      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .collection('transacoes')
            .add({
          'valor': valorPuro,
          'data': Timestamp.fromDate(_dataSelecionada),
          'categoria': _categoriaSelecionada ?? 'Outros',
          'subcategoria': _subcategoriaSelecionada ?? 'Outros',
          'descricao': _descricaoController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gasto salvo com sucesso!'), 
              backgroundColor: Colors.green,
            ),
          );
          
          _valorController.clear();
          _descricaoController.clear();
          setState(() {
            _categoriaSelecionada = null;
            _subcategoriaSelecionada = null;
          });
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? escolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
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

  @override
  Widget build(BuildContext context) {
    final categoriasAtuais = _mapaDespesas.keys.toList();
    
    List<String> subcategoriasAtuais = [];
    if (_categoriaSelecionada != null && _mapaDespesas.containsKey(_categoriaSelecionada)) {
      subcategoriasAtuais = _mapaDespesas[_categoriaSelecionada]!;
    } else {
      _categoriaSelecionada = null; 
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Novo Gasto', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
            const SizedBox(height: 24),

            TextFormField(
              controller: _valorController,
              style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0),
              keyboardType: TextInputType.number,
              inputFormatters: [_moedaFormatter],
              decoration: InputDecoration(
                labelText: 'Valor',
                labelStyle: const TextStyle(color: Colors.white54, fontSize: 16),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Informe o valor' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              dropdownColor: const Color(0xFF2C2C2C),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Categoria',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: categoriasAtuais.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) {
                setState(() {
                  _categoriaSelecionada = val;
                  _subcategoriaSelecionada = null; 
                });
              },
              validator: (value) => value == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _subcategoriaSelecionada,
              dropdownColor: const Color(0xFF2C2C2C),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Subcategoria',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: subcategoriasAtuais.isEmpty
                  ? null
                  : subcategoriasAtuais.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))).toList(),
              onChanged: subcategoriasAtuais.isEmpty
                  ? null
                  : (val) => setState(() => _subcategoriaSelecionada = val),
              validator: (value) => value == null ? 'Selecione uma subcategoria' : null,
              disabledHint: const Text('Selecione uma categoria primeiro...', style: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 16),

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
                    Text('${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}', style: const TextStyle(color: Colors.white, letterSpacing: 0)),
                    const Icon(Icons.calendar_today, color: Color(0xFFFFD700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descricaoController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Observação (Opcional)',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _salvarTransacao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SALVAR GASTO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}