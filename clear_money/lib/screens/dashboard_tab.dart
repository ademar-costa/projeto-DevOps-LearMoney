import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // Variável que guarda o mês/ano que o usuário está visualizando agora
  DateTime _dataSelecionada = DateTime.now();

  // Funções para navegar no tempo
  void _mesAnterior() {
    setState(() {
      _dataSelecionada = DateTime(_dataSelecionada.year, _dataSelecionada.month - 1, 1);
    });
  }

  void _proximoMes() {
    setState(() {
      _dataSelecionada = DateTime(_dataSelecionada.year, _dataSelecionada.month + 1, 1);
    });
  }

  Color _getCorCategoria(String categoria) {
    switch (categoria) {
      case 'Moradia': return Colors.blue;
      case 'Alimentação': return Colors.orange; 
      case 'Transporte': return Colors.green;
      case 'Educação e Desenvolvimento': return Colors.purpleAccent;
      case 'Tecnologia e Softwares': return Colors.deepPurple;
      default: return Colors.teal;
    }
  }

  IconData _getIconeCategoria(String categoria) {
    switch (categoria) {
      case 'Moradia': return Icons.home;
      case 'Alimentação': return Icons.restaurant;
      case 'Transporte': return Icons.directions_car;
      case 'Educação e Desenvolvimento': return Icons.school;
      case 'Tecnologia e Softwares': return Icons.computer;
      default: return Icons.category;
    }
  }

  void _confirmarExclusao(BuildContext context, String docId, String subcategoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Excluir Gasto', style: TextStyle(color: Colors.redAccent)),
        content: Text('Tem certeza que deseja apagar "$subcategoria"?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              final usuario = FirebaseAuth.instance.currentUser;
              if (usuario != null) {
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(usuario.uid)
                    .collection('transacoes')
                    .doc(docId)
                    .delete();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gasto excluído com sucesso!'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _abrirGraficoAnual(BuildContext context, Map<int, Map<String, double>> gastosPorMes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Histórico Anual (${_dataSelecionada.year})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                    IconButton(icon: const Icon(Icons.close, color: Color(0xFFFFD700)), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                              if (value.toInt() >= 1 && value.toInt() <= 12) {
                                return Text(meses[value.toInt() - 1], style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _gerarDadosDoGraficoAnual(gastosPorMes),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _gerarDadosDoGraficoAnual(Map<int, Map<String, double>> gastosPorMes) {
    List<BarChartGroupData> grupos = [];
    for (int i = 1; i <= 12; i++) {
      final mesData = gastosPorMes[i] ?? {};
      double alturaBase = 0;
      List<BarChartRodStackItem> pilhas = [];
      
      mesData.forEach((categoria, valor) {
        if (valor > 0) {
          pilhas.add(BarChartRodStackItem(alturaBase, alturaBase + valor, _getCorCategoria(categoria)));
          alturaBase += valor;
        }
      });

      grupos.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: alturaBase,
              width: 16,
              rodStackItems: pilhas,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return const Center(child: Text('Usuário não autenticado', style: TextStyle(color: Color(0xFFFFD700))));
    }

    const listaMeses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final nomeMesAtual = '${listaMeses[_dataSelecionada.month - 1]} ${_dataSelecionada.year}';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('transacoes')
          .orderBy('data', descending: true) 
          .snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
        }

        final transacoes = snapshot.data?.docs ?? [];

        double totalGasto = 0;
        Map<String, double> totaisPorCategoria = {};
        Map<String, List<Map<String, dynamic>>> listaPorCategoria = {};
        Map<int, Map<String, double>> gastosPorMes = {}; 

        for (var doc in transacoes) {
          final dados = doc.data() as Map<String, dynamic>;
          dados['id'] = doc.id; 
          
          final categoria = dados['categoria'] as String? ?? 'Outros';
          final valor = (dados['valor'] as num?)?.toDouble() ?? 0.0;
          final dataOriginal = (dados['data'] as Timestamp).toDate();

          // 1. Agrupa para o gráfico Anual (pega tudo do ano selecionado)
          if (dataOriginal.year == _dataSelecionada.year) {
            final mes = dataOriginal.month;
            if (!gastosPorMes.containsKey(mes)) {
              gastosPorMes[mes] = {};
            }
            gastosPorMes[mes]![categoria] = (gastosPorMes[mes]![categoria] ?? 0) + valor;
          }

          // 2. Filtra a Pizza e a Lista apenas para o mês e ano selecionados
          if (dataOriginal.year == _dataSelecionada.year && dataOriginal.month == _dataSelecionada.month) {
            totalGasto += valor;

            totaisPorCategoria[categoria] = (totaisPorCategoria[categoria] ?? 0) + valor;
            if (!listaPorCategoria.containsKey(categoria)) {
              listaPorCategoria[categoria] = [];
            }
            listaPorCategoria[categoria]!.add(dados);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seletor de Meses interativo
                      Row(
                        children: [
                          const Text('Total Gasto', style: TextStyle(fontSize: 16, color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.grey, size: 24),
                            onPressed: _mesAnterior,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Text(nomeMesAtual, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
                            onPressed: _proximoMes,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('R\$ ${totalGasto.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _abrirGraficoAnual(context, gastosPorMes),
                    icon: const Icon(Icons.bar_chart, color: Colors.black),
                    label: const Text('Anual', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )
                ],
              ),
              const SizedBox(height: 5),
              
              // Se não houver gastos no mês, exibe uma mensagem
              if (totaisPorCategoria.isEmpty)
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: Text('Nenhum gasto neste mês.', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  ),
                )
              else
                SizedBox(
                  height: 220, 
                  child: PieChart(
                    PieChartData(
                      sections: totaisPorCategoria.entries.map((entry) {
                        return PieChartSectionData(
                          color: _getCorCategoria(entry.key),
                          value: entry.value,
                          showTitle: false, 
                          badgeWidget: Icon(
                            _getIconeCategoria(entry.key),
                            color: Colors.black87, 
                            size: 20, 
                          ),
                          badgePositionPercentageOffset: 0.55, 
                          radius: 100, 
                        );
                      }).toList(),
                      centerSpaceRadius: 0, 
                      sectionsSpace: 2, 
                    ),
                  ),
                ),
              const SizedBox(height: 30),

              const Text('Despesas por Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))), 
              const SizedBox(height: 16),

              if (totaisPorCategoria.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text('A lista está vazia para o período selecionado.', style: TextStyle(color: Colors.white54)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), 
                  itemCount: totaisPorCategoria.length,
                  itemBuilder: (context, index) {
                    final categoria = totaisPorCategoria.keys.elementAt(index);
                    final totalDaCategoria = totaisPorCategoria[categoria]!;
                    final transacoesDaCategoria = listaPorCategoria[categoria]!;

                    return Card(
                      color: const Color(0xFF2C2C2C),
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: const Color(0xFFFFD700),
                          collapsedIconColor: Colors.white54,
                          leading: CircleAvatar(
                            backgroundColor: _getCorCategoria(categoria).withOpacity(0.2),
                            child: Icon(_getIconeCategoria(categoria), color: _getCorCategoria(categoria)),
                          ),
                          title: Text(categoria, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)), 
                          trailing: Text('R\$ ${totalDaCategoria.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)), 
                          
                          children: transacoesDaCategoria.map((transacao) {
                            final docId = transacao['id'] as String; 
                            
                            final subcategoria = transacao['subcategoria'] ?? 'Outros';
                            final valorGasto = (transacao['valor'] as num).toDouble();
                            final dataCompra = (transacao['data'] as Timestamp).toDate();
                            final dataFormatada = '${dataCompra.day.toString().padLeft(2, '0')}/${dataCompra.month.toString().padLeft(2, '0')}/${dataCompra.year}';
                            
                            final descricao = transacao['descricao'] as String?;
                            final temDescricao = descricao != null && descricao.trim().isNotEmpty;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                              title: Text(subcategoria, style: const TextStyle(color: Colors.white70)),
                              subtitle: Text(dataFormatada, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (temDescricao)
                                    IconButton(
                                      icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFFFD700), size: 20),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: const Color(0xFF2C2C2C),
                                            title: const Text('Observação', style: TextStyle(color: Color(0xFFFFD700))),
                                            content: Text(descricao, style: const TextStyle(color: Colors.white)),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Fechar', style: TextStyle(color: Color(0xFFFFD700))),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  Text('R\$ ${valorGasto.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)), 
                                  
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                                    onPressed: () => _confirmarExclusao(context, docId, subcategoria),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}