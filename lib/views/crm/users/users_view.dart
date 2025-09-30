import 'package:flutter/material.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Usuarios registrados",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Orlando Montes - Staff"),
                      subtitle: Text("Rol: Cocinero\nHistorial: 120 pedidos"),
                      trailing: Icon(Icons.more_vert),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Santiago Mendoza - Staff"),
                      subtitle: Text("Rol: Ayudante\nHistorial: 120 pedidos"),
                      trailing: Icon(Icons.more_vert),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.delivery_dining),
                      title: Text("Clara López - Repartidor"),
                      subtitle: Text("Rol: Delivery\nHistorial: 85 entregas"),
                      trailing: Icon(Icons.more_vert),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.delivery_dining),
                      title: Text("Leonardo Barajas - Repartidor"),
                      subtitle: Text("Rol: Delivery\nHistorial: 85 entregas"),
                      trailing: Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text("Agregar usuario"),
            ),
          ],
        ),
      ),
    );
  }
}
