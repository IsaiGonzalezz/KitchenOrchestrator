import 'package:flutter/material.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Listado de productos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.fastfood),
                      title: Text("Hamburguesa Clásica"),
                      subtitle: Text("Precio: \$80 - Disponible"),
                      trailing: Icon(Icons.edit),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.local_pizza),
                      title: Text("Pizza Pepperoni"),
                      subtitle: Text("Precio: \$150 - Agotada"),
                      trailing: Icon(Icons.edit),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.local_cafe),
                      title: Text("Café expreso"),
                      subtitle: Text("Precio: \$45 - Disponible"),
                      trailing: Icon(Icons.edit),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.local_drink),
                      title: Text("Refresco"),
                      subtitle: Text("Precio: \$30 - Disponible"),
                      trailing: Icon(Icons.edit),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.local_pizza),
                      title: Text("Pizza Italiana"),
                      subtitle: Text("Precio: \$130 - Disponible"),
                      trailing: Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Agregar producto"),
            ),
          ],
        ),
      ),
    );
  }
}
