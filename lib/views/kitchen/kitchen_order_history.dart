import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KitchenOrderHistory extends StatefulWidget {
  const KitchenOrderHistory({Key? key}) : super(key: key);

  @override
  State<KitchenOrderHistory> createState() => _KitchenOrderHistoryState();
}

class _KitchenOrderHistoryState extends State<KitchenOrderHistory> {
  DateTime? selectedDate;
  String? selectedProduct;
  String searchQuery = '';

  // Mock data - reemplazar con datos reales
  final List<Map<String, dynamic>> historyOrders = [
    {
      'id': 'ORD-101',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'table': 'Mesa 3',
      'customer': 'Juan Pérez',
      'items': ['Pizza Napolitana', 'Ensalada César'],
      'totalItems': 2,
      'completedTime': '18 min',
      'status': 'completado',
    },
    {
      'id': 'ORD-100',
      'date': DateTime.now().subtract(const Duration(hours: 3)),
      'table': 'Mesa 7',
      'customer': 'María González',
      'items': ['Pasta Carbonara', 'Tiramisu', 'Café'],
      'totalItems': 3,
      'completedTime': '25 min',
      'status': 'completado',
    },
    {
      'id': 'ORD-099',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'table': 'Mesa 12',
      'customer': 'Carlos Rodríguez',
      'items': ['Hamburguesa', 'Papas fritas'],
      'totalItems': 2,
      'completedTime': '15 min',
      'status': 'completado',
    },
    {
      'id': 'ORD-098',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      'table': 'Mesa 5',
      'customer': 'Ana Martínez',
      'items': ['Sushi variado', 'Sopa miso'],
      'totalItems': 2,
      'completedTime': '30 min',
      'status': 'completado',
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    return historyOrders.where((order) {
      bool matchesDate = selectedDate == null ||
          DateUtils.isSameDay(order['date'], selectedDate);

      bool matchesProduct = selectedProduct == null ||
          (order['items'] as List).any((item) =>
              item.toLowerCase().contains(selectedProduct!.toLowerCase()));

      bool matchesSearch = searchQuery.isEmpty ||
          order['id'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          order['customer'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          order['table'].toLowerCase().contains(searchQuery.toLowerCase());

      return matchesDate && matchesProduct && matchesSearch;
    }).toList();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedProduct = null;
      searchQuery = '';
    });
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Reporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Exportar como PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exportando PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Exportar como Excel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exportando Excel...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.history),
            SizedBox(width: 8),
            Text('Historial de Pedidos'),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportReport,
            tooltip: 'Exportar reporte',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
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
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por ID, cliente o mesa...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Filtros
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          selectedDate == null
                              ? 'Fecha'
                              : DateFormat('dd/MM/yyyy').format(selectedDate!),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selectedDate != null
                              ? Colors.deepOrange.withOpacity(0.1)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showProductFilterDialog();
                        },
                        icon: const Icon(Icons.restaurant),
                        label: Text(
                          selectedProduct ?? 'Producto',
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selectedProduct != null
                              ? Colors.deepOrange.withOpacity(0.1)
                              : null,
                        ),
                      ),
                    ),
                    if (selectedDate != null || selectedProduct != null)
                      IconButton(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear),
                        tooltip: 'Limpiar filtros',
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Estadísticas rápidas
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    '${filteredOrders.length}',
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Tiempo Promedio',
                    '22 min',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Items',
                    '${_calculateTotalItems()}',
                    Icons.shopping_bag,
                    Colors.green,
                  ),
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
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron pedidos',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Limpiar filtros'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildHistoryCard(order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showProductFilterDialog() {
    final products = [
      'Pizza Napolitana',
      'Pizza Margarita',
      'Pasta Carbonara',
      'Ensalada César',
      'Hamburguesa',
      'Sushi variado',
      'Tiramisu',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Producto'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product),
                selected: selectedProduct == product,
                onTap: () {
                  setState(() {
                    selectedProduct = product;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedProduct = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  int _calculateTotalItems() {
    return filteredOrders.fold(
        0, (sum, order) => sum + (order['totalItems'] as int));
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.green),
        ),
        title: Text(
          order['id'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.table_restaurant, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(order['table']),
                const SizedBox(width: 12),
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['customer'],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(dateFormat.format(order['date'])),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              order['completedTime'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${order['totalItems']} items',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items del pedido:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  (order['items'] as List).length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, size: 8),
                        const SizedBox(width: 8),
                        Text(order['items'][index]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // Ver más detalles
                        Navigator.pushNamed(
                          context,
                          '/kitchen/order-detail',
                          arguments: order['id'],
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Ver detalles'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Imprimiendo ticket...')),
                        );
                      },
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Reimprimir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
