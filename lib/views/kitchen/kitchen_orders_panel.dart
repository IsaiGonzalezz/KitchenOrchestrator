import 'package:flutter/material.dart';

class KitchenOrdersPanel extends StatefulWidget {
  const KitchenOrdersPanel({Key? key}) : super(key: key);

  @override
  State<KitchenOrdersPanel> createState() => _KitchenOrdersPanelState();
}

class _KitchenOrdersPanelState extends State<KitchenOrdersPanel> {
  String selectedFilter = 'todos';

  // Mock data - reemplazar con datos reales de tu backend
  final List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD-001',
      'status': 'nuevo',
      'table': 'Mesa 5',
      'items': 3,
      'time': '2 min',
      'priority': 'alta',
    },
    {
      'id': 'ORD-002',
      'status': 'en_preparacion',
      'table': 'Mesa 12',
      'items': 2,
      'time': '15 min',
      'priority': 'media',
    },
    {
      'id': 'ORD-003',
      'status': 'listo',
      'table': 'Mesa 8',
      'items': 4,
      'time': '25 min',
      'priority': 'baja',
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter == 'todos') return orders;
    return orders.where((order) => order['status'] == selectedFilter).toList();
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
    setState(() {
      final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        orders[orderIndex]['status'] = newStatus;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Pedido actualizado a ${_getStatusLabel(newStatus)}')),
    );
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
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 8),
            Text('Panel de Cocina'),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
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

          // Lista de pedidos
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
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
                  Icon(Icons.table_restaurant,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(order['table']),
                  const SizedBox(width: 16),
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${order['items']} items'),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
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
