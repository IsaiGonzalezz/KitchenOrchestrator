import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class KitchenOrderDetail extends StatefulWidget {
  final String orderId;
  final String restaurantName;

  const KitchenOrderDetail({
    Key? key,
    required this.orderId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  State<KitchenOrderDetail> createState() => _KitchenOrderDetailState();
}

class _KitchenOrderDetailState extends State<KitchenOrderDetail> {
  // CONEXIÓN FIREBASE
  late final DatabaseReference orderRef;
  Map<String, dynamic>? orderData;
  // ELIMINADO: La variable 'timeElapsed' y el 'Timer'.

  @override
  void initState() {
    super.initState();
    // Inicializar referencia a la orden específica: /RestauranteID/Pedidos/orderId
    orderRef = FirebaseDatabase.instance
        .ref('${widget.restaurantName}/Pedidos/${widget.orderId}');
  }

  // 💡 Mapeo del snapshot de Firebase (Adaptado al modelo de datos del usuario)
  void _mapSnapshotToData(DataSnapshot snapshot) {
    if (snapshot.value != null && snapshot.value is Map) {
      final Map<dynamic, dynamic> rawOrder =
          snapshot.value as Map<dynamic, dynamic>;

      // Mapeo de campos relevantes según el modelo proporcionado
      String status = rawOrder['estado']?.toString().toLowerCase() ?? 'nuevo';
      String customer = rawOrder['cliente']?.toString() ?? 'N/A';
      String address =
          rawOrder['direccion']?.toString() ?? 'N/A'; // ✅ Direccion
      double total = (rawOrder['total'] as num?)?.toDouble() ?? 0.0; // ✅ Total
      String timestamp =
          rawOrder['timestamp']?.toString() ?? DateTime.now().toIso8601String();

      // Ítems detallados
      List<Map<String, dynamic>> itemsList = [];
      if (rawOrder['items'] is List) {
        for (var item in rawOrder['items']) {
          if (item is Map) {
            itemsList.add({
              'producto':
                  item['producto']?.toString() ?? 'Producto Desconocido',
              'cantidad': (item['cantidad'] as int?) ?? 1,
              // ✅ Precio unitario del modelo de datos
              'precio_unitario':
                  (item['precio_unitario'] as num?)?.toDouble() ?? 0.0,
              'notas': item['notas']?.toString() ?? '',
            });
          }
        }
      }
      orderData = {
        'id': widget.orderId,
        'status': status,
        'customer': customer,
        'address': address,
        'total': total,
        'timestamp': timestamp,
        'items': itemsList,

        // Se mantienen estos campos solo si las funciones de acción los utilizan para grabar en DB
        'inicio_preparacion': rawOrder['inicio_preparacion']?.toString() ?? '',
        'tiempo_prep_final': rawOrder['tiempo_prep']?.toString() ?? 'N/A',
      };
    }
  }

  // FUNCIONES DE ACCIÓN
  Future<void> _startPreparation() async {
    final now = DateTime.now().toIso8601String();
    await orderRef.update({
      'estado': 'EN_PREPARACION',
      'inicio_preparacion': now,
    });
  }

  Future<void> _finishPreparation() async {
    final inicioPrepRaw = orderData!['inicio_preparacion']?.toString() ?? '';
    // Mantenemos la lógica de cálculo de tiempo final para el historial/métricas
    if (inicioPrepRaw.isEmpty) return;

    final inicio = DateTime.parse(inicioPrepRaw);
    final fin = DateTime.now();
    final diff = fin.difference(inicio);

    final totalMin = diff.inMinutes;
    final totalSec = diff.inSeconds % 60;

    final formatted =
        totalMin > 0 ? "$totalMin min ${totalSec}s" : "${totalSec}s";

    await orderRef.update({
      'estado': 'LISTO',
      'finalizacion_preparacion': fin.toIso8601String(),
      'tiempo_prep': formatted,
    });
  }

  // Helper para el Header (sin cambios)
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
        return 'NUEVO';
      case 'en_preparacion':
        return 'EN PREPARACIÓN';
      case 'listo':
        return 'LISTO';
      default:
        return 'DESCONOCIDO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: orderRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        _mapSnapshotToData(snapshot.data!.snapshot);

        if (orderData == null) {
          return const Center(child: Text("Orden no encontrada."));
        }

        final status = orderData!['status'];
        final total = orderData!['total'] as double;
        // Formato para mostrar el total en moneda
        final totalFormatted = NumberFormat.currency(
          locale: 'es_ES',
          symbol:
              '\$', // Ajusta el símbolo de moneda si es necesario (ej: 'MX\$')
        ).format(total);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: _getStatusColor(status).withOpacity(0.8),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Cerrar panel',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 💡 HEADER: Información General (SIN TIMER)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.95),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Número de Orden y Estado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${orderData!['id']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusLabel(status),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 💡 DATOS MOSTRADOS: Cliente, Dirección, Hora
                      _buildInfoRow(
                          Icons.person, orderData!['customer'], Colors.white),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, orderData!['address'],
                          Colors.white), // Dirección
                      const SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.access_time,
                          'Pedido: ${DateFormat('dd/MM HH:mm').format(DateTime.parse(orderData!['timestamp']))}',
                          Colors.white70),
                      const SizedBox(height: 16),

                      const Divider(color: Colors.white54),
                      const SizedBox(height: 8),

                      // TOTAL DEL PEDIDO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL DEL PEDIDO:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            totalFormatted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
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
                        itemCount: orderData!['items'].length,
                        itemBuilder: (context, index) {
                          final item = orderData!['items'][index];
                          return _buildItemCard(item);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // BOTONES DE ACCIÓN FIJOS
          bottomNavigationBar: _buildBottomActions(status),
        );
      },
    );
  }

  // Widget para filas de información (sin cambios, solo se usó Expanded)
  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget de Botones de Acción Fijos (sin cambios)
  Widget _buildBottomActions(String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (status == 'nuevo' || status == 'en_preparacion')
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    status == 'nuevo' ? _startPreparation : _finishPreparation,
                icon: Icon(
                  status == 'nuevo' ? Icons.play_arrow : Icons.check,
                ),
                label: Text(
                  status == 'nuevo'
                      ? 'INICIAR PREPARACIÓN'
                      : 'MARCAR COMO LISTO',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      status == 'nuevo' ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (status == 'listo')
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
                      'PEDIDO LISTO',
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
    );
  }

  // 💡 Widget de Tarjeta de Item (Adaptado para mostrar precio unitario y subtotal)
  Widget _buildItemCard(Map<String, dynamic> item) {
    final quantity = item['cantidad'] as int;
    final productName = item['producto'] as String;
    final unitPrice = item['precio_unitario'] as double;
    final subtotal = quantity * unitPrice;

    // Formato de moneda para subtotal y precio unitario
    final currencyFormat = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '\$',
    );
    final subtotalFormatted = currencyFormat.format(subtotal);
    final unitPriceFormatted = currencyFormat.format(unitPrice);

    final hasNotes = item['notas'] != null && item['notas'].isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre y Cantidad
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$quantity x $productName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  subtotalFormatted,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Precio Unitario
            Text(
              '($unitPriceFormatted c/u)',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            // Notas
            if (hasNotes) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['notas'],
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
            // ELIMINADO: La sección de Ingredientes
          ],
        ),
      ),
    );
  }
}
