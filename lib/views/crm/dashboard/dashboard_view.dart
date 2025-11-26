import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class DashboardView extends StatefulWidget {
  final String restaurantName;
  final String role;

  const DashboardView({
    super.key,
    required this.restaurantName,
    required this.role,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<Map<String, dynamic>> pedidos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  Future<void> cargarPedidos() async {
    try {
      final ref = FirebaseDatabase.instance.ref("${widget.restaurantName}/Pedidos");
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        
        // Verificamos si es un Map con datos válidos
        if (data is Map && data.isNotEmpty) {
          final lista = data.entries.map((e) {
            final pedido = Map<String, dynamic>.from(e.value);

            // --- TOTAL SEGURO ---
            final totalValue = pedido['total'];
            final total = (totalValue is num)
                ? totalValue.toDouble()
                : double.tryParse(totalValue.toString()) ?? 0.0;

            return {
              'timestamp': DateTime.parse(pedido['timestamp']),
              'estado': pedido['estado'],
              'inicio': DateTime.parse(pedido['inicio_preparacion']),
              'fin': DateTime.parse(pedido['finalizacion_preparacion']),
              'total': total,
            };
          }).toList();

          setState(() {
            pedidos = lista;
            isLoading = false;
          });
          return;
        }
      }
      
      // Si no hay pedidos o el nodo está vacío
      setState(() {
        pedidos = [];
        isLoading = false;
      });
    } catch (e) {
      // Si hay error, también dejamos de cargar
      setState(() {
        pedidos = [];
        isLoading = false;
      });
    }
  }

  // --- KPI: Pedidos por hora ---
  int get pedidosPorHora {
    final ahora = DateTime.now();
    return pedidos.where(
      (p) => p['timestamp'].isAfter(ahora.subtract(const Duration(hours: 1))),
    ).length;
  }

  // --- KPI: Tiempo promedio ---
  String get tiempoPromedio {
    final tiempos = pedidos
        .map((p) => p['fin'].difference(p['inicio']).inSeconds)
        .toList();

    if (tiempos.isEmpty) return "0 min";

    final promedio = tiempos.reduce((a, b) => a + b) ~/ tiempos.length;
    return "${(promedio ~/ 60)} min";
  }

  // --- KPI: Entregas completadas ---
  String get entregasCompletadas {
    final total = pedidos.length;
    final completadas = pedidos.where((p) => p['estado'] == "LISTO").length;

    if (total == 0) return "0%";

    final porcentaje = ((completadas / total) * 100).toStringAsFixed(0);
    return "$porcentaje%";
  }

  // --- ✨ NUEVA FUNCIÓN: Ventas por semana del mes actual ---
  Map<String, double> get ventasPorSemana {
    final agrupado = <String, double>{};
    final ahora = DateTime.now();
    
    // Filtramos solo pedidos del mes actual
    final pedidosDelMes = pedidos.where((p) {
      final fecha = p['timestamp'] as DateTime;
      return fecha.year == ahora.year && fecha.month == ahora.month;
    }).toList();

    // Agrupamos por semana
    for (var p in pedidosDelMes) {
      final fecha = p['timestamp'] as DateTime;
      final semana = _getWeekOfMonth(fecha);
      final key = 'Semana $semana';
      
      agrupado[key] = (agrupado[key] ?? 0) + p['total'];
    }

    // Aseguramos que todas las semanas del mes existan (aunque sea en 0)
    final numSemanas = _getWeekOfMonth(DateTime(ahora.year, ahora.month + 1, 0));
    for (int i = 1; i <= numSemanas; i++) {
      final key = 'Semana $i';
      if (!agrupado.containsKey(key)) {
        agrupado[key] = 0.0;
      }
    }

    // Ordenamos por número de semana
    return SplayTreeMap<String, double>.from(
      agrupado,
      (a, b) {
        final numA = int.parse(a.replaceAll('Semana ', ''));
        final numB = int.parse(b.replaceAll('Semana ', ''));
        return numA.compareTo(numB);
      },
    );
  }

  // --- ✨ Calcular número de semana dentro del mes ---
  int _getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final daysSinceFirstDay = date.difference(firstDayOfMonth).inDays;
    return (daysSinceFirstDay / 7).floor() + 1;
  }

  // --- ✨ Obtener nombre del mes actual ---
  String get mesActual {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[DateTime.now().month - 1];
  }

  // --- Generar barras (ahora por semana) ---
  List<BarChartGroupData> getBarGroups() {
    final ventas = ventasPorSemana;
    int index = 0;

    return ventas.entries.map((e) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: e.value == 0 ? 0.1 : e.value, // Mínimo visible
            width: 16,
            color: Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  List<String> getBarLabels() => ventasPorSemana.keys.toList();

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: const Color(0xFF151515),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF151515),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KPIs",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // ✨ KPI CARDS - RESPONSIVO
            Row(
              children: [
                _buildKpiCard("Pedidos por hora", pedidosPorHora.toString()),
                const SizedBox(width: 8),
                _buildKpiCard("Tiempo promedio", tiempoPromedio),
                const SizedBox(width: 8),
                _buildKpiCard("Entregas completadas", entregasCompletadas),
              ],
            ),

            const SizedBox(height: 32),
            
            // ✨ Título mejorado con mes actual
            Text(
              "Ventas por semana - $mesActual",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // ✨ GRÁFICA RESPONSIVE CON MEJOR ESPACIADO
            SizedBox(
              height: 280,
              child: pedidos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 60,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sin datos para mostrar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crea pedidos para ver estadísticas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: _calculateMaxY(),
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final labels = getBarLabels();
                          return BarTooltipItem(
                            '${labels[groupIndex]}\n\${rod.toY.toStringAsFixed(0)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    barGroups: getBarGroups(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _calculateInterval(),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),

                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      // --- Labels abajo (semanas) - MEJORADO ---
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final labels = getBarLabels();
                            final index = value.toInt();

                            if (index < 0 || index >= labels.length) {
                              return const SizedBox();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[index].replaceAll('Semana ', 'S'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // --- Eje Y (ventas) - MEJORADO ---
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          interval: _calculateInterval(),
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return const Text(
                                '\$0',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return Text(
                              '\$${value.toInt()}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ✨ INFO ADICIONAL: Total del mes (solo si hay pedidos)
            if (pedidos.isNotEmpty && ventasPorSemana.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total del mes:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${ventasPorSemana.values.reduce((a, b) => a + b).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// --- Calcular el valor máximo del eje Y ---
  double _calculateMaxY() {
    if (ventasPorSemana.isEmpty) return 100;
    
    double maxValue = ventasPorSemana.values.reduce((a, b) => a > b ? a : b);
    
    // Si no hay ventas, mostramos hasta 100
    if (maxValue == 0) return 100;
    
    // Agregamos un 20% más para que las barras no toquen el tope
    return maxValue * 1.2;
  }

  /// --- Intervalo dinámico para no sobrecargar el eje ---
  double _calculateInterval() {
    if (ventasPorSemana.isEmpty) return 20;

    double maxY = _calculateMaxY();
    
    // Calculamos un intervalo limpio
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    
    return (maxY / 5).roundToDouble();
  }

  // --- Tarjeta KPI - MEJORADA ---
  Widget _buildKpiCard(String titulo, String valor) {
    return Expanded(
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}