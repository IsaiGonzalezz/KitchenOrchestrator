class Producto {
  final String id;
  final String nombre;
  final double precio;
  final bool disponible;
  final int stock;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.disponible,
    required this.stock,
  });

  factory Producto.fromMap(String id, Map data) {
    return Producto(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
      disponible: data['estado'] == 'Disponible',
      stock: data['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'precio': precio,
        'estado': disponible ? 'Disponible' : 'Agotado',
        'stock': stock,
      };
}
