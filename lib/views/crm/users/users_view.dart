import 'package:flutter/material.dart';

class UsersView extends StatelessWidget {
  final String restaurantName;

  const UsersView({
    super.key,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        title: Text('Gestión de Usuarios para $restaurantName'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF6F00), // Naranja KO
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Usuarios registrados",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  UserCard(
                    icon: Icons.person,
                    name: "Orlando Montes - Staff",
                    role: "Cocinero",
                    history: "120 pedidos",
                  ),
                  UserCard(
                    icon: Icons.person,
                    name: "Santiago Mendoza - Staff",
                    role: "Ayudante",
                    history: "120 pedidos",
                  ),
                  UserCard(
                    icon: Icons.delivery_dining,
                    name: "Clara López - Repartidor",
                    role: "Delivery",
                    history: "85 entregas",
                  ),
                  UserCard(
                    icon: Icons.delivery_dining,
                    name: "Leonardo Barajas - Repartidor",
                    role: "Delivery",
                    history: "85 entregas",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Agregar usuario"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00), // Naranja KO
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String role;
  final String history;

  const UserCard({
    super.key,
    required this.icon,
    required this.name,
    required this.role,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Icon(icon, color: Colors.deepOrange),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Rol: $role\nHistorial: $history"),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}
