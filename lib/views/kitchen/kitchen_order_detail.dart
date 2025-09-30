import 'package:flutter/material.dart';

class KitchenOrderDetail extends StatefulWidget {
  final String orderId;

  const KitchenOrderDetail({Key? key, required this.orderId}) : super(key: key);

  @override
  State<KitchenOrderDetail> createState() => _KitchenOrderDetailState();
}

class _KitchenOrderDetailState extends State<KitchenOrderDetail> {
  // Mock data - reemplazar con datos reales
  late Map<String, dynamic> orderData;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  void _loadOrderData() {
    // Simular carga de datos
    orderData = {
      'id': widget.orderId,
      'status': 'en_preparacion',
      'table': 'Mesa 5',
      'customer': 'Cliente VIP',
      'time': '15:30',
      'estimatedTime': '20 min',
      'items': [
        {
          'name': 'Pizza Margarita',
          'quantity': 2,
          'notes': 'Sin cebolla, extra queso',
          'ingredients': ['Masa', 'Salsa de tomate', 'Mozzarella', 'Albahaca'],
        },
        {
          'name': 'Ensalada César',
          'quantity': 1,
          'notes': 'Aderezo aparte',
          'ingredients': [
            'Lechuga romana',
            'Crutones',
            'Queso parmesano',
            'Pollo'
          ],
        },
        {
          'name': 'Pasta Carbonara',
          'quantity': 1,
          'notes': '',
          'ingredients': ['Pasta', 'Huevo', 'Panceta', 'Queso pecorino'],
        },
      ],
    };
  }

  void _printTicket() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Imprimir Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Deseas imprimir el ticket de cocina?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Diseño ecológico optimizado',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket impreso correctamente')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(String newStatus) {
    setState(() {
      orderData['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pedido actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido ${orderData['id']}'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printTicket,
            tooltip: 'Imprimir ticket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderData['table'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            orderData['customer'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          orderData['time'],
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tiempo estimado: ${orderData['estimatedTime']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Items List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items del Pedido',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderData['items'].length,
                    itemBuilder: (context, index) {
                      final item = orderData['items'][index];
                      return _buildItemCard(item);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (orderData['status'] == 'nuevo' ||
                orderData['status'] == 'en_preparacion')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(
                    orderData['status'] == 'nuevo' ? 'en_preparacion' : 'listo',
                  ),
                  icon: Icon(
                    orderData['status'] == 'nuevo'
                        ? Icons.play_arrow
                        : Icons.check,
                  ),
                  label: Text(
                    orderData['status'] == 'nuevo'
                        ? 'Iniciar Preparación'
                        : 'Marcar como Listo',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orderData['status'] == 'nuevo'
                        ? Colors.orange
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            if (orderData['status'] == 'listo')
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Pedido Listo',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'x${item['quantity']}',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (item['notes'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['notes'],
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Ingredientes:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item['ingredients']
                  .map<Widget>(
                    (ingredient) => Chip(
                      label: Text(ingredient),
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
