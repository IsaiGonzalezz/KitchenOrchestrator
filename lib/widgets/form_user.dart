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
  late TextEditingController rolCtrl;
  bool activo = true;

  @override
  void initState() {
    super.initState();
    final u = widget.usuarioExistente;
    nombreCtrl = TextEditingController(text: u?.nombre ?? '');
    correoCtrl = TextEditingController(text: u?.correo ?? '');
    rolCtrl = TextEditingController(text: u?.rol ?? '');
    activo = u?.activo ?? true;
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
        ),
        const SizedBox(height: 15),

        TextFormField(
          controller: rolCtrl,
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
              final rol = rolCtrl.text.trim();

              if (nombre.isNotEmpty && correo.isNotEmpty && rol.isNotEmpty) {
                final nuevo = Usuario(
                  id: widget.usuarioExistente?.id ?? '',
                  nombre: nombre,
                  correo: correo,
                  rol: rol,
                  activo: activo,
                );
                widget.onSubmit(nuevo);
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
