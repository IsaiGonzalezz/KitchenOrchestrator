import 'package:flutter/material.dart';

// Imports de Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // <-- ¡IMPORTANTE! Faltaba este
import 'firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Imports de tus Vistas
import 'views/kitchen/kitchen_orders_panel.dart';
import 'views/kitchen/kitchen_order_detail.dart';
import 'views/kitchen/kitchen_order_history.dart';
import 'views/login/login_view.dart';
import 'views/crm/dashboard/dashboard_view.dart';
import 'views/crm/products/products_view.dart';
import 'views/crm/users/users_view.dart';
import 'views/signup/signup.dart';


void main() async {
  // Tu inicialización de Firebase (¡perfecta!)
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
      
      // 1. Ruta inicial: /login
      initialRoute: '/login',

      // 2. Mapa de rutas
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const NavigationHome(), // Tu barra de navegación
      },

      debugShowCheckedModeBanner: false,
    );
  }
}

// -----------------------------------------------------------------
// ESTA ES AHORA LA PANTALLA PRINCIPAL (POST-LOGIN)
// -----------------------------------------------------------------
class NavigationHome extends StatefulWidget {
  const NavigationHome({super.key});

  @override
  State<NavigationHome> createState() => _NavigationHomeState();
}

// 
// ¡AQUÍ ES DONDE DEBE IR TODA LA LÓGICA!
// Todo va DENTRO de las llaves { } de _NavigationHomeState
//
class _NavigationHomeState extends State<NavigationHome> {
  
  // 1. Variables de estado
  int _selectedIndex = 0;
  String? _restaurantName;
  String? _role;
  String? _userEmail;
  bool _isLoading = true; // Empezamos en modo "cargando"
  final _storage = const FlutterSecureStorage();
  
  // Lista de títulos (esta puede ser fija)
  final List<String> _titles = [
    'Dashboard',
    'Panel de Órdenes',
    'Historial',
    'Productos',
    'Usuarios',
  ];

  // 2. initState: Se ejecuta una vez cuando se crea la pantalla
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
      // Buscamos en nuestro "mapa" de user_profiles
      final ref = FirebaseDatabase.instance.ref('user_profiles').child(user.uid);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        // Guardamos los datos en el estado
        setState(() {
          _restaurantName = data['restaurantName'];
          _role = data['role'];
          _userEmail = user.email; // Guardamos el email
          _isLoading = false; // ¡Terminamos de cargar!
        });
      } else {
        // El usuario está logeado pero no tiene perfil (raro, pero posible)
        setState(() {
          _isLoading = false;
        });
        // Aquí podrías mostrar un error
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

    // Si ya cargó, creamos la lista de páginas 
    // para pasarles los datos del restaurante
    final List<Widget> pages = [
      DashboardView(
        restaurantName: _restaurantName ?? 'Error',
        role: _role ?? 'Error',
      ),
      KitchenOrdersPanel(
        restaurantName: _restaurantName ?? 'Error',
      ),
      KitchenOrderHistory(
        restaurantName: _restaurantName ?? 'Error',
      ),
      ProductsView(
        restaurantName: _restaurantName ?? 'Error',
      ),
      UsersView(
        restaurantName: _restaurantName ?? 'Error',
      ),
    ];
    
    // Y ahora sí, construimos el Scaffold
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostramos el título de la página
            Text(_titles[_selectedIndex]),
            // Mostramos el restaurante y el rol del usuario
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
      // Mostramos la página seleccionada
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Órdenes'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
        ],
      ),
    );
  }
}
// LA CLASE _NavigationHomeState TERMINA AQUÍ