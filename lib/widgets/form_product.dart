import 'package:flutter/material.dart';
import '../models/product.dart';

class FormularioProducto extends StatefulWidget {
  final void Function(Producto) onSubmit;
  final Producto? productoExistente;

  const FormularioProducto({
    super.key,
    required this.onSubmit,
    this.productoExistente,
  });

  @override
  State<FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<FormularioProducto> {
  late TextEditingController nombreCtrl;
  late TextEditingController precioCtrl;
  late TextEditingController stockCtrl;
  bool disponible = true;

  @override
  void initState() {
    super.initState();
    final p = widget.productoExistente;
    nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    precioCtrl = TextEditingController(text: p != null ? p.precio.toString() : '');
    stockCtrl = TextEditingController(text: p != null ? p.stock.toString() : '');
    disponible = p?.disponible ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.productoExistente == null ? "Nuevo producto" : "Editar producto",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
        ),
        const SizedBox(height: 12),
        TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
        TextField(controller: precioCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Precio")),
        TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Stock")),
        SwitchListTile(title: const Text("¿Disponible?"), value: disponible, onChanged: (val) => setState(() => disponible = val)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            final nombre = nombreCtrl.text.trim();
            final precio = double.tryParse(precioCtrl.text.trim()) ?? 0;
            final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;

            if (nombre.isNotEmpty && precio > 0) {
              final nuevo = Producto(
                id: widget.productoExistente?.id ?? '',
                nombre: nombre,
                precio: precio,
                disponible: disponible,
                stock: stock,
              );
              widget.onSubmit(nuevo);
            }
          },
          child: const Text("Guardar"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
        )
      ],
    );
  }
}
