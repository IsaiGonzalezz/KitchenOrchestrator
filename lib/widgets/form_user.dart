import 'package:flutter/material.dart';
import '../models/user.dart';

class FormularioUsuario extends StatefulWidget {
  final void Function(Usuario) onSubmit;
  final Usuario? usuarioExistente;

  const FormularioUsuario({
    super.key,
    required this.onSubmit,
    this.usuarioExistente,
  });

  @override
  State<FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<FormularioUsuario> {
  late TextEditingController nombreCtrl;
  late TextEditingController correoCtrl;
  late TextEditingController contrasenaCtrl;
  String rolSeleccionado = "Chef";
  bool activo = true;

  @override
  void initState() {
    super.initState();
    final u = widget.usuarioExistente;
    nombreCtrl = TextEditingController(text: u?.nombre ?? '');
    correoCtrl = TextEditingController(text: u?.correo ?? '');
    contrasenaCtrl = TextEditingController();
    rolSeleccionado = u?.rol ?? "Chef";
    activo = u?.activo ?? true;
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    correoCtrl.dispose();
    contrasenaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.usuarioExistente == null ? "Nuevo usuario" : "Editar usuario",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: nombreCtrl,
          decoration: InputDecoration(
            labelText: "Nombre",
            prefixIcon: const Icon(Icons.person, color: Colors.deepOrange),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 15),

        TextFormField(
          controller: correoCtrl,
          decoration: InputDecoration(
            labelText: "Correo",
            prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),

        if (widget.usuarioExistente == null)
          TextFormField(
            controller: contrasenaCtrl,
            decoration: InputDecoration(
              labelText: "Contraseña",
              prefixIcon: const Icon(Icons.lock, color: Colors.redAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            obscureText: true,
          ),
        const SizedBox(height: 15),

        DropdownButtonFormField<String>(
          value: rolSeleccionado,
          items: const [
            DropdownMenuItem(value: "Gerente", child: Text("Gerente")),
            DropdownMenuItem(value: "Chef", child: Text("Chef")),
          ],
          onChanged: (val) => setState(() => rolSeleccionado = val ?? "Chef"),
          decoration: InputDecoration(
            labelText: "Rol",
            prefixIcon: const Icon(Icons.work, color: Colors.green),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 15),

        SwitchListTile(
          title: const Text("¿Activo?"),
          value: activo,
          activeColor: Colors.deepOrange,
          onChanged: (val) => setState(() => activo = val),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final nombre = nombreCtrl.text.trim();
              final correo = correoCtrl.text.trim();
              final contrasena = contrasenaCtrl.text.trim();

              if (nombre.isNotEmpty && correo.isNotEmpty) {
                final nuevo = Usuario(
                  id: widget.usuarioExistente?.id ?? '',
                  nombre: nombre,
                  correo: correo,
                  rol: rolSeleccionado,
                  activo: activo,
                  contrasena: contrasena,
                );
                widget.onSubmit(nuevo);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Completa todos los campos")),
                );
              }
            },
            icon: const Icon(Icons.save),
            label: const Text("Guardar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
