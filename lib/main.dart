import 'package:flutter/material.dart';
import 'views/kitchen/kitchen_orders_panel.dart';
import 'views/kitchen/kitchen_order_detail.dart';
import 'views/kitchen/kitchen_order_history.dart';
import 'views/login/login_view.dart';
import 'views/crm/dashboard/dashboard_view.dart';
import 'views/crm/products/products_view.dart';
import 'views/crm/users/users_view.dart';
import 'views/signup/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Orchestrator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NavigationHome(),
    );
  }
}

class NavigationHome extends StatefulWidget {
  const NavigationHome({super.key});

  @override
  State<NavigationHome> createState() => _NavigationHomeState();
}

class _NavigationHomeState extends State<NavigationHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    KitchenOrdersPanel(),
    KitchenOrderDetail(orderId:"test123"),
    KitchenOrderHistory(),
    DashboardView(),
    ProductsView(),
    UsersView(),
    LoginPage(),
    RegisterPage(),
  ];

  final List<String> _titles = [
    'Panel de Órdenes',
    'Detalle de Orden',
    'Historial de Órdenes',
    'Dashboard',
    'Productos',
    'Usuarios',
    'Login',
    'Registro'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Órdenes'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Detalle'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: 'Register'),
        ],
      ),
    );
  }
}
