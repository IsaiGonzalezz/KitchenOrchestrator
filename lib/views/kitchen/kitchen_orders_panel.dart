import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class KitchenOrdersPanel extends StatefulWidget {
  // 1. Parámetro restaurantName para construir la ruta de Firebase
  final String restaurantName;

  const KitchenOrdersPanel({Key? key, required this.restaurantName})
      : super(key: key);

  @override
  State<KitchenOrdersPanel> createState() => _KitchenOrdersPanelState();
}

class _KitchenOrdersPanelState extends State<KitchenOrdersPanel> {
  String selectedFilter = 'todos';

  // 2. ordersRef se declara como late final
  late final DatabaseReference ordersRef;

  @override
  void initState() {
    super.initState();
    // 3. Inicialización dinámica de la referencia: /RestauranteID/Pedidos
    ordersRef =
        FirebaseDatabase.instance.ref('${widget.restaurantName}/Pedidos');
  }

  //Funcion para iniciar preparacion de orden
  Future<void> _startPreparation(String orderId) async {
    final now = DateTime.now().toIso8601String();

    await ordersRef.child(orderId).update({
      'estado': 'EN_PREPARACION',
      'inicio_preparacion': now,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Orden $orderId en preparación')),
    );
  }

  //Funcion para marcar orden como lista
  Future<void> _finishPreparation(String orderId, String inicioPrepRaw) async {
    if (inicioPrepRaw.isEmpty) return;

    final inicio = DateTime.parse(inicioPrepRaw);
    final fin = DateTime.now();
    final diff = fin.difference(inicio);

    final totalMin = diff.inMinutes;
    final totalSec = diff.inSeconds % 60;

    final formatted =
        totalMin > 0 ? "$totalMin min ${totalSec}s" : "$totalSec s";

    await ordersRef.child(orderId).update({
      'estado': 'LISTO',
      'finalizacion_preparacion': fin.toIso8601String(),
      'tiempo_prep': formatted,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Orden $orderId lista para entregar')),
    );
  }

  // Función para mapear el snapshot de Firebase a la lista de órdenes.
  List<Map<String, dynamic>> _mapSnapshotToOrders(
      AsyncSnapshot<DatabaseEvent> snapshot) {
    List<Map<String, dynamic>> fetchedOrders = [];

    final rawValue = snapshot.data?.snapshot.value;

    if (rawValue != null && rawValue is Map) {
      final Map<dynamic, dynamic> ordersMap = rawValue;

      ordersMap.forEach((key, value) {
        // Mapeo de campos
        String id = key.toString();
        String status = value['estado']?.toString().toLowerCase() ?? 'nuevo';
        String cliente = value['cliente']?.toString() ?? 'N/A';

        //Tiempo de preparacion
        String inicioPrep = value['inicio_preparacion']?.toString() ?? '';
        String tiempoPrep = value['finalizacion_preparacion']?.toString() ?? '';

        // Conteo de items
        int totalItems = 0;
        if (value['items'] is List) {
          for (var item in value['items']) {
            if (item is Map && item['cantidad'] is int) {
              totalItems += item['cantidad'] as int;
            }
          }
        }

        // Cálculo de tiempo transcurrido (time)
        String timeDisplay = 'N/A';
        if (status == 'listo' && tiempoPrep.isNotEmpty) {
          timeDisplay = tiempoPrep;
        } else if (value['timestamp'] != null) {
          try {
            DateTime orderTime = DateTime.parse(value['timestamp']);
            Duration elapsed = DateTime.now().difference(orderTime);

            if (elapsed.inHours > 0) {
              timeDisplay = '${elapsed.inHours} hr';
            } else if (elapsed.inMinutes > 0) {
              timeDisplay = '${elapsed.inMinutes} min';
            } else {
              timeDisplay = 'Ahora';
            }
          } catch (_) {
            timeDisplay = "N/A";
          }
        }

        // Estructura final de la orden + tiempo de preparacion
        fetchedOrders.add({
          'id': id,
          'status': status,
          'cliente': cliente,
          'items': totalItems,
          'time': timeDisplay,
          'inicio_preparacion': inicioPrep,
        });
      });
    }

    // Aplicar el filtro de estado seleccionado
    final List<Map<String, dynamic>> filtered = fetchedOrders.where((order) {
      bool matchesFilter =
          selectedFilter == 'todos' || order['status'] == selectedFilter;
      return matchesFilter;
    }).toList();

    // IMPRESIÓN DE DEPURACIÓN #3: Órdenes filtradas
    print('--- FINAL FILTERED ORDERS (Filter: $selectedFilter) ---');
    print(filtered);
    print('----------------------------------------');

    return filtered;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'nuevo':
        return Colors.red;
      case 'en_preparacion':
        return Colors.orange;
      case 'listo':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'nuevo':
        return 'Nuevo';
      case 'en_preparacion':
        return 'En Preparación';
      case 'listo':
        return 'Listo';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: ordersRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final orders = _mapSnapshotToOrders(snapshot);

                if (orders.isEmpty) {
                  return const Center(
                    child: Text("No hay pedidos."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(orders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 21, 21, 21),
    );
  }

  // -------------------------------------------------------------
  //  Widgets adicionales
  // -------------------------------------------------------------

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Color.fromARGB(255, 21, 21, 21),
      child: Row(
        children: [
          Expanded(child: _buildFilterChip('todos', 'Todos', Icons.list)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterChip('nuevo', 'Nuevos', Icons.fiber_new)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildFilterChip(
                  'en_preparacion', 'En Prep.', Icons.access_time)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterChip('listo', 'Listos', Icons.check)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (_) {
        setState(() => selectedFilter = value);
      },
      selectedColor: Color.fromARGB(255, 248, 161, 69).withOpacity(0.2),
      checkmarkColor: Color.fromARGB(255, 248, 161, 69),
    );
  }

  // -------------------------------------------------------------
  //  Order Card
  // -------------------------------------------------------------
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          // Usamos InkWell para detectar el toque
          onTap: () {
            // Abrir la vista de detalle de la orden
            Navigator.pushNamed(
              context,
              '/kitchen/order-detail', // Ruta  definida en tu main.dart
              arguments: {
                'orderId': order['id'],
                'restaurantName': widget.restaurantName,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(order['status']),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order['id'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(order['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusLabel(order['status']),
                        style: TextStyle(
                          color: _getStatusColor(order['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Información
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 4),
                    Text(order['cliente']),
                    const SizedBox(width: 16),
                    const Icon(Icons.shopping_bag, size: 16),
                    const SizedBox(width: 4),
                    Text('${order['items']} items'),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(order['time']),
                  ],
                ),

                const SizedBox(height: 16),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order['status'] == 'nuevo') _btnIniciar(order['id']),
                    if (order['status'] == 'en_preparacion')
                      _btnListo(order['id'], order['inicio_preparacion']),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget _btnIniciar(String id) {
    return ElevatedButton.icon(
      onPressed: () => _startPreparation(id),
      icon: const Icon(Icons.play_arrow),
      label: const Text("Iniciar"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _btnListo(String id, String inicio) {
    return ElevatedButton.icon(
      onPressed: () => _finishPreparation(id, inicio),
      icon: const Icon(Icons.check),
      label: const Text("Listo"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
    );
  }
}
