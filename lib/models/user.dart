class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final bool activo;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.activo,
  });

  Map<String, dynamic> toMapRestaurante() {
    return {
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
      'activo': activo,
    };
  }

  Map<String, dynamic> toMapPerfil() {
    return {
      'restaurantName': restaurantName,
      'role': rol,
    };
  }

  factory Usuario.fromMap(String id, Map<String, dynamic> map) {
    return Usuario(
      id: id,
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      rol: map['rol'] ?? '',
      activo: map['activo'] ?? true,
    );
  }

  String get restaurantName => 'McDonalz'; // Puedes hacerlo dinámico si lo necesitas
}
