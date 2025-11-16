import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;

  const ProductCard({
    super.key,
    required this.producto,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: producto.disponible ? Colors.white : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: const Icon(Icons.fastfood, color: Colors.deepOrange),
        ),
        title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "Precio: \$${producto.precio.toStringAsFixed(2)}\nStock: ${producto.stock} - ${producto.disponible ? 'Disponible' : 'Agotado'}",
          style: TextStyle(
            color: producto.disponible ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueAccent),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
