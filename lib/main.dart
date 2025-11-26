import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Vistas
import 'views/kitchen/kitchen_orders_panel.dart';
import 'views/kitchen/kitchen_order_detail.dart';
import 'views/kitchen/kitchen_order_history.dart';
import 'views/login/login_view.dart';
import 'views/crm/dashboard/dashboard_view.dart';
import 'views/crm/products/products_view.dart';
import 'views/crm/users/users_view.dart';
import 'views/signup/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const NavigationHome(),
      },
      debugShowCheckedModeBanner: false,
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
  String? _restaurantName;
  String? _role;
  String? _userEmail;
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _performSignOut();
      return;
    }

    try {
      final ref = FirebaseDatabase.instance.ref('user_profiles').child(user.uid);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _restaurantName = data['restaurantName'];
          _role = data['role'];
          _userEmail = user.email;
          _isLoading = false;

          // ⚠️ Si el rol no es Gerente y el índice apunta a "Usuarios", lo corregimos
          if (_role != "Gerente" && _selectedIndex == 4) {
            _selectedIndex = 0;
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final bool? didConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Salir')),
        ],
      ),
    );

    if (didConfirm == true) {
      await _performSignOut();
    }
  }

  Future<void> _performSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _storage.delete(key: 'saved_email');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {}
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> pages = _role == "Gerente"
        ? [
            DashboardView(restaurantName: _restaurantName ?? 'Error', role: _role ?? 'Error'),
            KitchenOrdersPanel(restaurantName: _restaurantName ?? 'Error'),
            KitchenOrderHistory(restaurantName: _restaurantName ?? 'Error'),
            ProductsView(restaurantName: _restaurantName ?? 'Error'),
            UsersView(restaurantName: _restaurantName ?? 'Error'),
          ]
        : [
            DashboardView(restaurantName: _restaurantName ?? 'Error', role: _role ?? 'Error'),
            KitchenOrdersPanel(restaurantName: _restaurantName ?? 'Error'),
            KitchenOrderHistory(restaurantName: _restaurantName ?? 'Error'),
            ProductsView(restaurantName: _restaurantName ?? 'Error'),
          ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      const BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Órdenes'),
      const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Productos'),
      if (_role == "Gerente")
        const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(navItems[_selectedIndex].label ?? ''),
            Text(
              '${_restaurantName ?? 'Sin Restaurante'} (${_role ?? 'Sin Rol'})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _signOut,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: navItems,
      ),
    );
  }
}
