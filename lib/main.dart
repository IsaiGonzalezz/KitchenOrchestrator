import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Vistas
import 'views/kitchen/kitchen_orders_panel.dart';
import 'views/kitchen/kitchen_order_history.dart';
import 'views/kitchen/kitchen_order_detail.dart';
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

      // Localización (versión 2)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],

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

      //Ruta dinámica
      onGenerateRoute: (settings) {
        if (settings.name == '/kitchen/order-detail') {
          // Extraemos los argumentos que enviamos desde kitchen_orders_panel.dart
          final args = settings.arguments as Map<String, dynamic>;
          final orderId = args['orderId'] as String;
          final restaurantName = args['restaurantName'] as String;

          //PageRouteBuilder  animación de deslizamiento
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  //Ancho 500 píxeles de ancho.
                  width: 500,
                  child: KitchenOrderDetail(
                    orderId: orderId,
                    restaurantName: restaurantName,
                  ),
                ),
              );
            },

            // El tiempo de la animación
            transitionDuration: const Duration(milliseconds: 300),
            // La función que define la animación
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin =
                  Offset(1.0, 0.0); // Inicia fuera de la pantalla (derecha)
              const end = Offset.zero; // Termina en posición normal
              const curve = Curves.easeOut; // Animación suave

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              // Retorna un SlideTransition que aplica la animación al 'child'
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            // Fondo oscuro (Overlay oscuro)
            opaque: false, // Permite que el contenido subyacente se vea
            barrierDismissible: true, // Permite cerrar al hacer clic fuera
            barrierColor: Colors.black54, // Color del overlay oscuro
          );
        }
        // Si no es la ruta de detalle, volvemos a null para usar el ruteo normal.
        return null;
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
      final ref =
          FirebaseDatabase.instance.ref('user_profiles').child(user.uid);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          _restaurantName = data['restaurantName'];
          _role = data['role'];
          _userEmail = user.email;
          _isLoading = false;
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
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salir')),
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
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
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

    final List<Widget> pages;
    final List<String> titles;
    final List<BottomNavigationBarItem> navBarItems;

    if (_role == 'Gerente') {
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
      pages = [
        KitchenOrdersPanel(restaurantName: _restaurantName!),
        KitchenOrderHistory(restaurantName: _restaurantName!),
        ProductsView(restaurantName: _restaurantName!)
      ];

      titles = [
        'Panel de Órdenes',
        'Historial',
        'Productos',
      ];

      navBarItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Órdenes'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: 'Productos'),
      ];
    } else {
      pages = [
        const Center(child: Text('No tienes vistas asignadas.')),
      ];
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
        backgroundColor: const Color.fromARGB(255, 21, 21, 21),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: titles[_selectedIndex],
                    style: const TextStyle(color: Colors.white),
                  ),
                  const TextSpan(
                      text: ' ', style: TextStyle(color: Colors.white)),
                  TextSpan(
                    text: _restaurantName!,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 248, 161, 69)),
                  ),
                ],
              ),
            ),
            Text(
              '($_role)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
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
        backgroundColor: const Color.fromARGB(255, 21, 21, 21),
        selectedItemColor: const Color.fromARGB(255, 248, 161, 69),
        unselectedItemColor: Colors.grey,
        items: navBarItems,
      ),
    );
  }
}
