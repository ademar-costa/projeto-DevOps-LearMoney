import 'package:flutter/material.dart';

class InserirGastoTab extends StatefulWidget {
  const InserirGastoTab({super.key});

  @override
  State<InserirGastoTab> createState() => _InserirGastoTabState();
}

class _InserirGastoTabState extends State<InserirGastoTab> {
  // Chave do formulário para podermos validar os campos
  final _formKey = GlobalKey<FormState>();

  // Controladores para pegar o texto digitado
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  // Variáveis para guardar as escolhas do usuário
  DateTime? _dataSelecionada = DateTime.now();
  String? _categoriaSelecionada;
  String? _subcategoriaSelecionada;

  // Nosso "Banco de Dados" simulado baseado na minha planilha
  final Map<String, List<String>> _categorias = {
    'Moradia': ['Aluguel/Prestação', 'Condomínio', 'Energia Elétrica', 'Água', 'Gás', 'Internet', 'Manutenção e Reparos'],
    'Alimentação': ['Supermercado', 'Padaria', 'Restaurantes/Lanches fora', 'Delivery'],
    'Transporte': ['Passagem de Ônibus/Metrô', 'Combustível', 'Aplicativos de Transporte (Uber/99)', 'Manutenção do Veículo'],
    'Educação e Desenvolvimento': ['Mensalidades/Taxas', 'Materiais e Projetos (IFB)', 'Cursos de Tecnologia (Flutter/Dart)', 'Concursos Públicos', 'Livros'],
    'Tecnologia e Softwares': ['Serviços de Nuvem (Firebase/MCP)', 'Licenças de Softwares', 'Manutenção', 'Domínios'],
    'Outros': ['Presentes', 'Apoio a Projetos Sociais/Doações', 'Despesas Inesperadas'],
  };

  // Função para abrir o calendário
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
              primary: Color(0xFFFFD700), // Cor do cabeçalho do calendário
              onPrimary: Colors.black,    // Cor do texto no cabeçalho
              surface: Color(0xFF2C2C2C), // Cor de fundo do calendário
              onSurface: Colors.white,    // Cor dos números
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

  // Função chamada ao clicar em Salvar
  void _salvarGasto() {
    if (_formKey.currentState!.validate()) {
      // Se todos os campos forem válidos, mostramos uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto salvo com sucesso! (Simulação)'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Aqui no futuro chamaremos o Firebase para salvar os dados
      // Exemplo: firebaseService.salvarGasto(valor, data, categoria, ...);
      
      // Limpa os campos após salvar
      _valorController.clear();
      _descricaoController.clear();
      setState(() {
        _categoriaSelecionada = null;
        _subcategoriaSelecionada = null;
      });
    }
  }

  @override
  void dispose() {
    // É importante limpar os controladores quando a tela for fechada
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
          crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os botões até a borda
          children: [
            // Campo de VALOR
            TextFormField(
              controller: _valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 32, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                prefixStyle: const TextStyle(fontSize: 32, color: Colors.white54),
                labelText: 'Valor',
                labelStyle: const TextStyle(color: Colors.white54, fontSize: 16),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe o valor';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de DATA (Abre o calendário)
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
                  // Zera a subcategoria sempre que a categoria principal mudar
                  _subcategoriaSelecionada = null; 
                });
              },
              validator: (value) => value == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 20),

            // Campo de SUBCATEGORIA (Dependente da Categoria)
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
              // Só mostra as opções se uma categoria tiver sido selecionada
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

            // Campo de DESCRIÇÃO (Opcional)
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
                backgroundColor: const Color(0xFFFFD700), // Fundo amarelo
                foregroundColor: Colors.black,            // Texto preto
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