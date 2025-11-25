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
        if (value['timestamp'] != null) {
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
            timeDisplay = 'N/A';
          }
        }

        // Estructura final de la orden
        fetchedOrders.add({
          'id': id,
          'status': status,
          'cliente': cliente,
          'items': totalItems,
          'time': timeDisplay,
        });
      });
    }

    // IMPRESIÓN DE DEPURACIÓN #2: Órdenes mapeadas
    print('--- MAPPED ORDERS (Before Filter) ---');
    print(fetchedOrders);

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

  void _updateOrderStatus(String orderId, String newStatus) {
    // Convierte el estado local (lowercase) al formato de base de datos (uppercase, ej. NUEVO)
    ordersRef.child(orderId).update({
      'estado': newStatus.toUpperCase(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Pedido actualizado a ${_getStatusLabel(newStatus)}')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $error')),
      );
    });
  }

  void _printTicket(String orderId) {
    // Implementar lógica de impresión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imprimiendo ticket...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 21, 21, 21),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 248, 161, 69).withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip('todos', 'Todos', Icons.list),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('nuevo', 'Nuevos', Icons.fiber_new),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                      'en_preparacion', 'En Prep.', Icons.pending),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child:
                      _buildFilterChip('listo', 'Listos', Icons.check_circle),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: ordersRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  // Muestra el error de conexión
                  return Center(
                      child:
                          Text('Error al cargar pedidos: ${snapshot.error}'));
                }

                final List<Map<String, dynamic>> filteredOrders =
                    _mapSnapshotToOrders(snapshot);

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay pedidos ${selectedFilter != "todos" ? _getStatusLabel(selectedFilter).toLowerCase() : ""}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    // ... (Método buildFilterChip)
    final isSelected = selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
        });
      },
      selectedColor: Colors.deepOrange.withOpacity(0.2),
      checkmarkColor: Colors.deepOrange,
    );
  }

  // Widget de la tarjeta de orden usando los campos confirmados
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/kitchen/order-detail',
            arguments: order['id'],
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
                        // ID de la orden (Key de Firebase)
                        order['id'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(order['status']),
                      style: TextStyle(
                        color: _getStatusColor(order['status']),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Info
              Row(
                children: [
                  // Muestra el nombre del cliente
                  const Icon(Icons.person, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    order['cliente'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  // Muestra el total de items
                  const Icon(Icons.shopping_bag,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text('${order['items']} items'),
                  const SizedBox(width: 16),
                  // Muestra el tiempo transcurrido
                  const Icon(Icons.access_time,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(order['time']),
                ],
              ),
              const SizedBox(height: 16),

              // Acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order['status'] == 'nuevo')
                    ElevatedButton.icon(
                      onPressed: () =>
                          _updateOrderStatus(order['id'], 'en_preparacion'),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Iniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (order['status'] == 'en_preparacion')
                    ElevatedButton.icon(
                      onPressed: () => _updateOrderStatus(order['id'], 'listo'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Listo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _printTicket(order['id']),
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Imprimir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
