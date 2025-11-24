import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../models/product.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/form_product.dart';

class ProductsView extends StatefulWidget {
  final String restaurantName;
  const ProductsView({super.key, required this.restaurantName});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  List<Producto> productos = [];

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  void cargarProductos() {
    final ref = FirebaseDatabase.instance.ref("${widget.restaurantName}/Productos");
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final lista = data.entries.map((e) {
          return Producto.fromMap(e.key, Map<String, dynamic>.from(e.value));
        }).toList();
        setState(() => productos = lista);
      }
    });
  }

  Future<void> agregarProducto(Producto producto) async {
    final ref = FirebaseDatabase.instance.ref("${widget.restaurantName}/Productos");
    final nuevoRef = ref.push(); // genera ID automático
    final productoConID = Producto(
      id: nuevoRef.key ?? '',
      nombre: producto.nombre,
      precio: producto.precio,
      disponible: producto.disponible,
      stock: producto.stock,
    );
    await nuevoRef.set(productoConID.toMap());
  }

  Future<void> editarProducto(Producto producto) async {
    final ref = FirebaseDatabase.instance.ref("${widget.restaurantName}/Productos/${producto.id}");
    await ref.set(producto.toMap());
  }

  Future<void> eliminarProducto(String id) async {
  final ref = FirebaseDatabase.instance.ref("${widget.restaurantName}/Productos/$id");
  await ref.remove();
}

  void mostrarFormulario({Producto? producto}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FormularioProducto(
            productoExistente: producto,
            onSubmit: (resultado) {
              if (producto == null) {
                agregarProducto(resultado);
              } else {
                editarProducto(resultado);
              }
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        title: Text('Gestión de Productos: ${widget.restaurantName}'),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Listado de productos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: productos.map((p) => ProductCard(
                  producto: p,
                  onEdit: () => mostrarFormulario(producto: p),
                  onDelete: () => eliminarProducto(p.id),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => mostrarFormulario(),
              icon: const Icon(Icons.add),
              label: const Text("Agregar producto"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}
