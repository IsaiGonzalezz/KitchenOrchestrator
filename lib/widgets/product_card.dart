import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.producto,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (producto.disponible && producto.stock > 0) ? Colors.white : Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: const Icon(Icons.fastfood, color: Colors.deepOrange),
        ),
        title: Text(
          producto.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Precio: \$${producto.precio.toStringAsFixed(2)}\nStock: ${producto.stock} - ${(producto.disponible && producto.stock > 0) ? 'Disponible' : 'Agotado'}",
          style: TextStyle(
            color: (producto.disponible && producto.stock > 0) ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: onEdit,
              tooltip: "Editar",
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("¿Eliminar producto?"),
                    content: const Text("Esta acción no se puede deshacer."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text("Eliminar"),
                      ),
                    ],
                  ),
                );
              },
              tooltip: "Eliminar",
            ),
          ],
        ),
      ),
    );
  }
}
