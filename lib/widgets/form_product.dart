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
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: nombreCtrl,
          decoration: InputDecoration(
            labelText: "Nombre",
            prefixIcon: const Icon(Icons.fastfood, color: Colors.deepOrange),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 15),

        TextFormField(
          controller: precioCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Precio",
            prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 15),

        TextFormField(
          controller: stockCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Stock",
            prefixIcon: const Icon(Icons.inventory, color: Colors.blueAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 15),

        SwitchListTile(
          title: const Text("¿Disponible?"),
          value: disponible,
          activeColor: Colors.deepOrange,
          onChanged: (val) => setState(() => disponible = val),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
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
            icon: const Icon(Icons.save),
            label: const Text("Guardar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
