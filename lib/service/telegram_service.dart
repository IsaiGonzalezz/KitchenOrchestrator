import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramService {
  static const String botToken = '8381689303:AAFKVoco-6LKlRIWW2EYAp2gIcJ7qHeL8vE';
  static const String baseUrl = 'https://api.telegram.org/bot$botToken';

  Future<bool> sendMessage(String chatId, String message) async {
    try {
      final url = Uri.parse('$baseUrl/sendMessage');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML',
        }),
      );

      if (response.statusCode == 200) {
        print('Mensaje enviado exitosamente');
        return true;
      } else {
        print('Error al enviar mensaje: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en sendMessage: $e');
      return false;
    }
  }

  // actualizaciones del bot
  Future<List<dynamic>> getUpdates({int offset = 0}) async {
    try {
      final url = Uri.parse('$baseUrl/getUpdates?offset=$offset');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] ?? [];
      } else {
        print('Error al obtener actualizaciones: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error en getUpdates: $e');
      return [];
    }
  }

  //  notificación de pedido
  Future<bool> sendOrderNotification(String chatId, Map<String, dynamic> order) async {
    final message = '''
 <b>Nuevo Pedido</b>

 <b>Orden #${order['id']}</b>
 Cliente: ${order['customer'] ?? 'N/A'}
 Hora: ${order['time'] ?? DateTime.now().toString()}

<b>Detalles:</b>
${_formatOrderItems(order['items'] ?? [])}

 Total: \$${order['total'] ?? '0.00'}

Estado: ${order['status'] ?? 'Pendiente'}
    ''';

    return await sendMessage(chatId, message);
  }

  // Enviar actualización de estado
  Future<bool> sendStatusUpdate(String chatId, String orderId, String newStatus) async {
    final message = '''
 <b>Actualización de Pedido</b>

 Orden #$orderId
 Nuevo Estado: <b>$newStatus</b>

 ${DateTime.now().toString().substring(0, 16)}
    ''';

    return await sendMessage(chatId, message);
  }

  // Formatear items del pedido
  String _formatOrderItems(List<dynamic> items) {
    if (items.isEmpty) return '• Sin items';
    
    return items.map((item) {
      final name = item['name'] ?? 'Item';
      final quantity = item['quantity'] ?? 1;
      final price = item['price'] ?? '0.00';
      return '• $quantity x $name - \$$price';
    }).join('\n');
  }

  // información del bot
  Future<Map<String, dynamic>?> getBotInfo() async {
    try {
      final url = Uri.parse('$baseUrl/getMe');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'];
      }
      return null;
    } catch (e) {
      print('Error en getBotInfo: $e');
      return null;
    }
  }

  // Enviar mensaje con botones
  Future<bool> sendMessageWithButtons(
    String chatId,
    String message,
    List<List<Map<String, String>>> buttons,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/sendMessage');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML',
          'reply_markup': {
            'inline_keyboard': buttons,
          },
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error en sendMessageWithButtons: $e');
      return false;
    }
  }
}