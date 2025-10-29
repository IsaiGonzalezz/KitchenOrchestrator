import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {

  final String restaurantName;
  final String role;

  const DashboardView({
    super.key,
    required this.restaurantName,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard CRM'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido a',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              restaurantName, // <-- DATO USADO
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Tu rol es: $role', // <-- DATO USADO
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Text(
              "KPIs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text("Pedidos por hora", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text("120"),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text("Tiempo promedio", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text("18 min"),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text("Entregas completadas", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text("95%"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Alertas",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text("Retraso en cocina"),
                subtitle: const Text("2 pedidos llevan más de 30 minutos"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
