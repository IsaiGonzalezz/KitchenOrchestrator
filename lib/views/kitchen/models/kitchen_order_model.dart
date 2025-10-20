import 'package:flutter/material.dart';

// Modelo de datos para pedidos de cocina
class KitchenOrder {
  final String id;
  final OrderStatus status;
  final String table;
  final String customer;
  final DateTime orderTime;
  final int estimatedMinutes;
  final List<OrderItem> items;
  final OrderPriority priority;

  KitchenOrder({
    required this.id,
    required this.status,
    required this.table,
    required this.customer,
    required this.orderTime,
    required this.estimatedMinutes,
    required this.items,
    this.priority = OrderPriority.media,
  });

  // Calcular tiempo transcurrido
  Duration get elapsedTime => DateTime.now().difference(orderTime);

  // Convertir de JSON
  factory KitchenOrder.fromJson(Map<String, dynamic> json) {
    return KitchenOrder(
      id: json['id'] as String,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.nuevo,
      ),
      table: json['table'] as String,
      customer: json['customer'] as String,
      orderTime: DateTime.parse(json['orderTime'] as String),
      estimatedMinutes: json['estimatedMinutes'] as int,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      priority: OrderPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => OrderPriority.media,
      ),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'table': table,
      'customer': customer,
      'orderTime': orderTime.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'items': items.map((item) => item.toJson()).toList(),
      'priority': priority.name,
    };
  }

  // Copiar con cambios
  KitchenOrder copyWith({
    String? id,
    OrderStatus? status,
    String? table,
    String? customer,
    DateTime? orderTime,
    int? estimatedMinutes,
    List<OrderItem>? items,
    OrderPriority? priority,
  }) {
    return KitchenOrder(
      id: id ?? this.id,
      status: status ?? this.status,
      table: table ?? this.table,
      customer: customer ?? this.customer,
      orderTime: orderTime ?? this.orderTime,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      items: items ?? this.items,
      priority: priority ?? this.priority,
    );
  }
}

// Item individual del pedido
class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final String notes;
  final List<String> ingredients;
  final ItemStatus status;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.notes = '',
    required this.ingredients,
    this.status = ItemStatus.pendiente,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] as List),
      status: ItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ItemStatus.pendiente,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'notes': notes,
      'ingredients': ingredients,
      'status': status.name,
    };
  }

  OrderItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? notes,
    List<String>? ingredients,
    ItemStatus? status,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      ingredients: ingredients ?? this.ingredients,
      status: status ?? this.status,
    );
  }
}

// Estados del pedido
enum OrderStatus {
  nuevo,
  en_preparacion,
  listo,
  entregado,
  cancelado,
}

// Estados de items individuales
enum ItemStatus {
  pendiente,
  en_preparacion,
  listo,
}

// Prioridad del pedido
enum OrderPriority {
  alta,
  media,
  baja,
}

// Extensiones útiles
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.nuevo:
        return 'Nuevo';
      case OrderStatus.en_preparacion:
        return 'En Preparación';
      case OrderStatus.listo:
        return 'Listo';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.nuevo:
        return Colors.red;
      case OrderStatus.en_preparacion:
        return Colors.orange;
      case OrderStatus.listo:
        return Colors.green;
      case OrderStatus.entregado:
        return Colors.blue;
      case OrderStatus.cancelado:
        return Colors.grey;
    }
  }
}

extension OrderPriorityExtension on OrderPriority {
  String get displayName {
    switch (this) {
      case OrderPriority.alta:
        return 'Alta';
      case OrderPriority.media:
        return 'Media';
      case OrderPriority.baja:
        return 'Baja';
    }
  }

  Color get color {
    switch (this) {
      case OrderPriority.alta:
        return Colors.red;
      case OrderPriority.media:
        return Colors.orange;
      case OrderPriority.baja:
        return Colors.green;
    }
  }
}
