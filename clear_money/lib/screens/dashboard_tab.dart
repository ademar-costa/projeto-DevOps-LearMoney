import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 20),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Lado Esquerdo (Textos) com Padding adicionado
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 80.0), // <-- Adicionamos 80 pixels de recuo à esquerda
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de\nGastos',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'R\$ 3.070,00', 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Lado Direito (Gráfico de Pizza)
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 160, 
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2, 
                    centerSpaceRadius: 0, 
                    sections: _buildPieChartSections(), 
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Categoria: Transporte
        _buildCategoryCard(
          icon: Icons.directions_car,
          title: 'Transporte',
          subtitle: 'Combustível, App de Transporte...',
          amount: 'R\$ 450,00',
          iconColor: const Color(0xFFEF9A9A),
          subcategorias: [
            {'nome': 'Combustível', 'data': '12/08/2026', 'valor': 'R\$ 300,00'},
            {'nome': 'App de Transporte (Uber)', 'data': '15/08/2026', 'valor': 'R\$ 50,00'},
            {'nome': 'Manutenção do Veículo', 'data': '18/08/2026', 'valor': 'R\$ 100,00'},
          ],
        ),

        // Categoria: Alimentação
        _buildCategoryCard(
          icon: Icons.restaurant,
          title: 'Alimentação',
          subtitle: 'Supermercado, Restaurantes...',
          amount: 'R\$ 840,00',
          iconColor: const Color(0xFFFFCC80),
          subcategorias: [
            {'nome': 'Supermercado', 'data': '05/08/2026', 'valor': 'R\$ 600,00'},
            {'nome': 'Restaurantes/Lanches', 'data': '10/08/2026', 'valor': 'R\$ 180,00'},
            {'nome': 'Padaria', 'data': '14/08/2026', 'valor': 'R\$ 60,00'},
          ],
        ),

        // Categoria: Educação e Desenvolvimento
        _buildCategoryCard(
          icon: Icons.school,
          title: 'Educação e Desenv.',
          subtitle: 'Cursos de Tecnologia, IFB...',
          amount: 'R\$ 250,00',
          iconColor: const Color(0xFFCE93D8),
          subcategorias: [
            {'nome': 'Mensalidades/Taxas', 'data': '01/08/2026', 'valor': 'R\$ 100,00'},
            {'nome': 'Cursos de Tecnologia', 'data': '08/08/2026', 'valor': 'R\$ 150,00'},
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    const double radius = 80; 
    
    return [
      PieChartSectionData(
        color: const Color(0xFF90CAF9), 
        value: 1250,
        title: '', 
        radius: radius,
        badgeWidget: _buildBadge(Icons.home),
        badgePositionPercentageOffset: 0.6, 
      ),
      PieChartSectionData(
        color: const Color(0xFFFFCC80), 
        value: 840,
        title: '',
        radius: radius,
        badgeWidget: _buildBadge(Icons.restaurant),
        badgePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: const Color(0xFFEF9A9A), 
        value: 450,
        title: '',
        radius: radius,
        badgeWidget: _buildBadge(Icons.directions_car),
        badgePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: const Color(0xFFCE93D8), 
        value: 250,
        title: '',
        radius: radius,
        badgeWidget: _buildBadge(Icons.school),
        badgePositionPercentageOffset: 0.6,
      ),
    ];
  }

  Widget _buildBadge(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.black54, 
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required Color iconColor,
    required List<Map<String, String>> subcategorias,
  }) {
    return Card(
      color: const Color(0xFF2C2C2C),
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white54,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
            ],
          ),
          children: subcategorias.map((sub) {
            return Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sub['nome']!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    sub['data']!,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    sub['valor']!,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}