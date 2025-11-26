import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> registrarUsuario(Usuario usuario) async {
    try {
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usuario.correo,
        password: usuario.contrasena,
      );
      final uid = cred.user!.uid;

      final refRestaurante = FirebaseDatabase.instance.ref("${widget.restaurantName}/Usuarios/$uid");
      await refRestaurante.set(usuario.copyWith(id: uid).toMapRestaurante());

      final refPerfil = FirebaseDatabase.instance.ref("user_profiles/$uid");
      await refPerfil.set(usuario.toMapPerfil(widget.restaurantName));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado correctamente"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> editarUsuario(Usuario usuario) async {
    final ref = FirebaseDatabase.instance.ref("${widget.restaurantName}/Usuarios/${usuario.id}");
    await ref.set(usuario.toMapRestaurante());

    final refPerfil = FirebaseDatabase.instance.ref("user_profiles/${usuario.id}");
    await refPerfil.set(usuario.toMapPerfil(widget.restaurantName));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Usuario actualizado correctamente"), backgroundColor: Colors.blue),
    );
  }

  Future<void> eliminarUsuario(String id) async {
    final refRestaurante = FirebaseDatabase.instance.ref("${widget.restaurantName}/Usuarios/$id");
    await refRestaurante.remove();

    final refPerfil = FirebaseDatabase.instance.ref("user_profiles/$id");
    await refPerfil.remove();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Usuario eliminado"), backgroundColor: Colors.red),
    );
  }

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
              Navigator.pop(context);
              if (usuario == null) {
                registrarUsuario(resultado);
              } else {
                editarUsuario(resultado);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 21, 21, 21),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: usuarios.isEmpty
                  ? const Center(child: Text("No hay usuarios"))
                  : ListView(
                      children: usuarios.map((u) => UserCard(
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
                backgroundColor: Colors.orangeAccent,
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
