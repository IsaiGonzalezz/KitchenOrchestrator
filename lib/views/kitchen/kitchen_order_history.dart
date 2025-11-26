import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart'; // Importar Realtime Database
import 'dart:core';

class KitchenOrderHistory extends StatefulWidget {
  final String restaurantName;
  const KitchenOrderHistory({
    super.key,
    required this.restaurantName,
  });

  @override
  State<KitchenOrderHistory> createState() => _KitchenOrderHistoryState();
}

class _KitchenOrderHistoryState extends State<KitchenOrderHistory> {
  DateTime? selectedDate;
  String? selectedProduct;
  String searchQuery = '';

  // 1. Referencias a la base de datos
  late final DatabaseReference ordersRef;
  late final DatabaseReference productsRef; // Nueva referencia para productos

  List<Map<String, dynamic>> _rawHistoryOrders = [];

  @override
  void initState() {
    super.initState();
    // Inicialización dinámica de la referencia a ÓRDENES: /RestauranteID/Pedidos
    ordersRef =
        FirebaseDatabase.instance.ref('${widget.restaurantName}/Pedidos');
    // Inicialización de la referencia a PRODUCTOS: /RestauranteID/Productos
    productsRef =
        FirebaseDatabase.instance.ref('${widget.restaurantName}/Productos');
  }

  // Lógica de mapeo para órdenes históricas (ESTADO != NUEVO, EN_PREPARACION)
  List<Map<String, dynamic>> _mapSnapshotToHistoryOrders(
      AsyncSnapshot<DatabaseEvent> snapshot) {
    List<Map<String, dynamic>> ordersList = [];
    final rawValue = snapshot.data?.snapshot.value;

    const List<String> exclusionStatus = ['nuevo', 'en_preparacion'];

    if (rawValue != null && rawValue is Map) {
      final Map<dynamic, dynamic> ordersMap = rawValue;

      ordersMap.forEach((key, value) {
        String id = key.toString();
        String status = value['estado']?.toString().toLowerCase() ?? 'nuevo';

        if (!exclusionStatus.contains(status)) {
          List<String> itemNames = [];
          // 🔥 CAMBIO: Usaremos un Map para contar ítems y obtener la cantidad total más precisa
          Map<String, int> rawItems = {};
          int totalItems = 0;

          if (value['items'] is List) {
            for (var item in value['items']) {
              if (item is Map) {
                String productName = item['producto']?.toString() ?? '';
                int quantity = (item['cantidad'] as int?) ?? 0;

                if (productName.isNotEmpty) {
                  itemNames.add(productName);
                  rawItems[productName] =
                      quantity; // Guardar cantidad por producto
                  totalItems += quantity; // Sumar la cantidad total
                }
              }
            }
          }

          DateTime orderDate = DateTime.now();
          if (value['timestamp'] != null) {
            try {
              orderDate = DateTime.parse(value['timestamp']);
            } catch (_) {/* ignore */}
          }

          // EXTRAE tiempo_prep de Firebase
          String completedTime = value['tiempo_prep']?.toString() ?? 'N/A';

          ordersList.add({
            'id': id,
            'date': orderDate,
            'customer': value['cliente']?.toString() ?? 'N/A',
            'items': itemNames,
            'rawItems': rawItems, // ✅ AGREGADO: Mapa de {producto: cantidad}
            'totalItems': totalItems,
            'completedTime': completedTime,
            'status': status,
          });
        }
      });
    }

    ordersList.sort((a, b) => b['date'].compareTo(a['date']));
    return ordersList;
  }

  // ... (Resto de la lógica de getters y funciones auxiliares)

  List<Map<String, dynamic>> get filteredOrders {
    return _rawHistoryOrders.where((order) {
      bool matchesDate = selectedDate == null ||
          DateUtils.isSameDay(order['date'], selectedDate);

      // Filtrado por producto usando la lista de nombres
      bool matchesProduct = selectedProduct == null ||
          (order['items'] as List<String>).any((item) =>
              item.toLowerCase().contains(selectedProduct!.toLowerCase()));

      bool matchesSearch = searchQuery.isEmpty ||
          order['id'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          order['customer'].toLowerCase().contains(searchQuery.toLowerCase());

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

  // 2. Modificación de _showProductFilterDialog para usar Firebase StreamBuilder
  void _showProductFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por Producto'),
          content: SizedBox(
            width: double.maxFinite,
            // StreamBuilder para obtener la lista de productos en tiempo real
            child: StreamBuilder<DatabaseEvent>(
              stream: productsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Mapeo para obtener solo los nombres ('nombre')
                List<String> products = [];
                final rawValue = snapshot.data?.snapshot.value;

                if (rawValue != null && rawValue is Map) {
                  rawValue.forEach((key, value) {
                    if (value is Map && value['nombre'] is String) {
                      products.add(value['nombre'] as String);
                    }
                  });
                }

                if (products.isEmpty) {
                  return const Center(
                      child: Text('No hay productos disponibles.'));
                }

                return ListView.builder(
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
                        // Cierra el diálogo después de la selección
                        Navigator.pop(context);
                      },
                    );
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
        );
      },
    );
  }

  int _calculateTotalItems() {
    return filteredOrders.fold(
        0, (sum, order) => sum + (order['totalItems'] as int));
  }

  // ✅ NUEVA FUNCIÓN: Calcula el producto más vendido en la lista filtrada
  String _calculateMostSoldProduct() {
    if (filteredOrders.isEmpty) {
      return 'N/A';
    }

    final Map<String, int> productCounts = {};

    // 1. Recorrer todas las órdenes filtradas
    for (var order in filteredOrders) {
      // 2. Recorrer el mapa 'rawItems' ({producto: cantidad})
      if (order['rawItems'] is Map<String, int>) {
        (order['rawItems'] as Map<String, int>)
            .forEach((productName, quantity) {
          // 3. Sumar la cantidad de cada producto
          productCounts.update(
            productName,
            (value) => value + quantity,
            ifAbsent: () => quantity,
          );
        });
      }
    }

    if (productCounts.isEmpty) {
      return 'N/A';
    }

    // 4. Encontrar el producto con la mayor cantidad
    String mostSoldProduct = 'N/A';
    int maxCount = 0;

    productCounts.forEach((productName, count) {
      if (count > maxCount) {
        maxCount = count;
        mostSoldProduct = productName;
      }
    });

    // Devuelve el producto más vendido y su cantidad
    return '$mostSoldProduct ($maxCount)';
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
          // ✅ Cambio: Usamos una lógica de truncado para valores muy largos (Producto más vendido)
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  value.length > 15 ? 14 : 20, // Ajustar fuente si es largo
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                // Solo mostramos el nombre del cliente
                const Icon(Icons.person, size: 14, color: Colors.grey),
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
                // Asumiendo que 'rawItems' tiene {producto: cantidad}
                ...List.generate(
                  (order['rawItems'] as Map<String, int>).length,
                  (index) {
                    final itemName = (order['rawItems'] as Map<String, int>)
                        .keys
                        .toList()[index];
                    final itemQuantity = (order['rawItems'] as Map<String, int>)
                        .values
                        .toList()[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text('$itemQuantity x'), // Mostrar la cantidad
                          const SizedBox(width: 8),
                          Expanded(child: Text(itemName)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                /*Row(
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
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aquí se utiliza ordersRef.onValue del código anterior para cargar los datos de la tabla.
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 21, 21),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 21, 21, 21),
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
                // Barra de búsqueda (ocupa el espacio restante)
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por ID o cliente ...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Botón de filtro por fecha (solo icono)
                IconButton(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  tooltip: selectedDate == null
                      ? 'Filtrar por fecha'
                      : DateFormat('dd/MM/yyyy').format(selectedDate!),
                  style: IconButton.styleFrom(
                    backgroundColor: selectedDate != null
                        ? Colors.deepOrange.withOpacity(0.2)
                        : Colors.grey[800],
                    foregroundColor:
                        selectedDate != null ? Colors.deepOrange : Colors.white,
                  ),
                ),
                const SizedBox(width: 8),

                // Botón de filtro por producto (solo icono)
                IconButton(
                  onPressed: _showProductFilterDialog,
                  icon: const Icon(Icons.restaurant),
                  tooltip: selectedProduct ?? 'Filtrar por producto',
                  style: IconButton.styleFrom(
                    backgroundColor: selectedProduct != null
                        ? Colors.deepOrange.withOpacity(0.2)
                        : Colors.grey[800],
                    foregroundColor: selectedProduct != null
                        ? Colors.deepOrange
                        : Colors.white,
                  ),
                ),

                // Botón para limpiar filtros
                if (selectedDate != null || selectedProduct != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar filtros',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // StreamBuilder envuelve tanto las estadísticas como la lista
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: ordersRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error de conexión: ${snapshot.error}'));
                }

                // 1. Mapear y actualizar _rawHistoryOrders con los datos (¡AQUÍ ES CLAVE!)
                _rawHistoryOrders = _mapSnapshotToHistoryOrders(snapshot);

                // El resto de la lógica de build se moverá aquí DENTRO del builder

                return Column(
                  // <-- Añadimos un Column para contener las tarjetas y la lista
                  children: [
                    // Estadísticas rápidas (Ahora dentro del StreamBuilder)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 1. Tarjeta de Total de Pedidos (Órdenes)
                          Expanded(
                            child: _buildStatCard(
                              'Total Pedidos',
                              '${filteredOrders.length}',
                              Icons.receipt_long,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 2. Tarjeta de Producto Más Vendido
                          Expanded(
                            child: _buildStatCard(
                              'Producto + Vendido',
                              _calculateMostSoldProduct(),
                              Icons.star,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 3. Tarjeta de Total de Ítems
                          Expanded(
                            child: _buildStatCard(
                              'Total Items',
                              '${_calculateTotalItems()}',
                              Icons.shopping_bag,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lista de Órdenes (Ahora dentro del StreamBuilder)
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
                                    'No se encontraron pedidos terminados que coincidan con los filtros.',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 16),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                return _buildHistoryCard(order);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
