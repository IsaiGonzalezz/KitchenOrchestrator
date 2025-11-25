import 'package:flutter/material.dart';

// Imports de Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Imports vistas
import 'views/kitchen/kitchen_orders_panel.dart';
import 'views/kitchen/kitchen_order_detail.dart';
import 'views/kitchen/kitchen_order_history.dart';
import 'views/login/login_view.dart';
import 'views/crm/dashboard/dashboard_view.dart';
import 'views/crm/products/products_view.dart';
import 'views/crm/users/users_view.dart';
import 'views/signup/signup.dart';

void main() async {
  // inicialización de Firebase
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

      //  Ruta inicial: /login
      initialRoute: '/login',

      // Mapa de rutas
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const NavigationHome(), // Tu barra de navegación
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
  // 1. Variables de estado
  int _selectedIndex = 0;
  String? _restaurantName;
  String? _role;
  String? _userEmail;
  bool _isLoading = true; // Empezamos en modo "cargando"
  final _storage = const FlutterSecureStorage();

  // initState: Se ejecuta una vez cuando se crea la pantalla
  @override
  void initState() {
    super.initState();
    // En cuanto la pantalla inicie, buscamos los datos del usuario
    _fetchUserData();
  }

  // 3. Función para buscar los datos del usuario en Firebase
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si no hay usuario, lo mandamos al login
      _performSignOut();
      return;
    }

    try {
      // Buscamos user_profiles
      final ref =
          FirebaseDatabase.instance.ref('user_profiles').child(user.uid);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        // Guardamos los datos en el estado
        setState(() {
          _restaurantName = data['restaurantName'];
          _role = data['role'];
          _userEmail = user.email;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Manejo de error
      setState(() {
        _isLoading = false;
      });
      // Mostrar SnackBar de error
    }
  }

  // 4. Funciones de Cerrar Sesión (Logout)
  Future<void> _signOut() async {
    final bool? didConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas salir?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salir')),
          ]),
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
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      // Manejo de error
    }
  }

  // 5. Función de la barra de navegación
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 6. Método Build: Dibuja la pantalla
  @override
  Widget build(BuildContext context) {
    // Si está cargando, mostramos un spinner
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_role == null || _restaurantName == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error de Permisos')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No pudimos cargar tu perfil de restaurante.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _performSignOut,
                child: const Text('Volver a Iniciar Sesión'),
              )
            ],
          ),
        ),
      );
    }

    // 6. Declaramos las listas de Vistas, Títulos e Ítems
    final List<Widget> pages;
    final List<String> titles;
    final List<BottomNavigationBarItem> navBarItems;

    // 7. Llenamos las listas según el rol
    if (_role == 'Gerente') {
      // El Gerente ve TODO
      pages = [
        DashboardView(restaurantName: _restaurantName!, role: _role!),
        KitchenOrdersPanel(restaurantName: _restaurantName!),
        KitchenOrderHistory(restaurantName: _restaurantName!),
        ProductsView(restaurantName: _restaurantName!),
        UsersView(restaurantName: _restaurantName!),
      ];
      titles = [
        'Dashboard',
        'Panel de Órdenes',
        'Historial',
        'Productos',
        'Usuarios',
      ];
      navBarItems = const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Órdenes'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: 'Productos'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
      ];
    } else if (_role == 'Chef') {
      // El Chef SÓLO ve Órdenes y Productos
      pages = [
        KitchenOrdersPanel(restaurantName: _restaurantName!),
        KitchenOrderHistory(restaurantName: _restaurantName!),
      ];
      titles = [
        'Panel de Órdenes',
        'Historial',
      ];
      navBarItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Órdenes'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
      ];
    } else {
      // Otro rol (ej. Repartidor o un error)
      pages = [const Center(child: Text('No tienes vistas asignadas.'))];
      titles = ['Inicio'];
      navBarItems = const [
        BottomNavigationBarItem(
            icon: Icon(Icons.do_not_disturb), label: 'Error'),
      ];
    }
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${titles[_selectedIndex]} (${_restaurantName!})',
            ),
            Text(
              '(${_role!})',
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
      body: pages[_selectedIndex], // <-- Página dinámica
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromARGB(255, 248, 161, 69),
        unselectedItemColor: Colors.grey,
        items: navBarItems, // <-- Ítems dinámicos
      ),
    );
  }
}
// LA CLASE _NavigationHomeState TERMINA AQUÍ
