import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../models/user.dart';
import '../../../widgets/user_card.dart';
import '../../../widgets/form_user.dart';

class UsersView extends StatefulWidget {
  final String restaurantName;

  const UsersView({
    super.key,
    required this.restaurantName,
  });

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  List<Usuario> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  /// Escucha en tiempo real los usuarios del restaurante
  void cargarUsuarios() {
    final ref = FirebaseDatabase.instance.ref("${widget.restaurantName}/Usuarios");
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final lista = data.entries.map((e) {
          return Usuario.fromMap(e.key, Map<String, dynamic>.from(e.value));
        }).toList();
        setState(() => usuarios = lista);
      } else {
        setState(() => usuarios = []);
      }
    });
  }

  /// Registrar un nuevo usuario en la rama Usuarios
  Future<void> registrarUsuario(Usuario usuario) async {
    final id = FirebaseDatabase.instance.ref().push().key ?? '';

    final refRestaurante = FirebaseDatabase.instance.ref("${widget.restaurantName}/Usuarios/$id");
    await refRestaurante.set({
      'uid': id,
      'name': usuario.nombre,
      'email': usuario.correo,
      'role': usuario.rol,
    });
  }

  /// Editar un usuario existente
  Future<void> editarUsuario(Usuario usuario) async {
    final ref = FirebaseDatabase.instance.ref("${widget.restaurantName}/Usuarios/${usuario.id}");
    await ref.set({
      'uid': usuario.id,
      'name': usuario.nombre,
      'email': usuario.correo,
      'role': usuario.rol,
    });
  }

  /// Eliminar un usuario
  Future<void> eliminarUsuario(String id) async {
    final refRestaurante = FirebaseDatabase.instance.ref("${widget.restaurantName}/Usuarios/$id");
    await refRestaurante.remove();
  }

  /// Mostrar formulario para agregar/editar
  void mostrarFormulario({Usuario? usuario}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FormularioUsuario(
            usuarioExistente: usuario,
            onSubmit: (resultado) {
              if (usuario == null) {
                registrarUsuario(resultado);
              } else {
                editarUsuario(resultado);
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
        title: Text('Gestión de Usuarios para ${widget.restaurantName}'),
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
              child: usuarios.isEmpty
                  ? const Center(child: Text("No hay usuarios"))
                  : ListView(
                      children: usuarios.map<Widget>((u) => UserCard(
                        usuario: u,
                        onEdit: () => mostrarFormulario(usuario: u),
                        onDelete: () => eliminarUsuario(u.id),
                      )).toList(),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => mostrarFormulario(),
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
