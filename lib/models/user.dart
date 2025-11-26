class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final bool activo;
  final String contrasena; // ⚠️ Campo nuevo para Auth

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.activo,
    required this.contrasena,
  });

  // ✅ Para guardar en McDonalz/Usuarios
  Map<String, dynamic> toMapRestaurante() {
    return {
      'uid': id,
      'name': nombre,
      'email': correo,
      'role': rol,
      'activo': activo,
    };
  }

  // ✅ Para guardar en user_profiles
  Map<String, dynamic> toMapPerfil(String restaurantName) {
    return {
      'restaurantName': restaurantName,
      'role': rol,
    };
  }

  // ✅ Para leer desde Firebase
  factory Usuario.fromMap(String id, Map<String, dynamic> map) {
    return Usuario(
      id: id,
      nombre: map['name'] ?? '',
      correo: map['email'] ?? '',
      rol: map['role'] ?? '',
      activo: map['activo'] ?? true,
      contrasena: '', // ⚠️ Nunca se carga desde DB
    );
  }

  // ✅ Para modificar solo campos específicos
  Usuario copyWith({
    String? id,
    String? nombre,
    String? correo,
    String? rol,
    bool? activo,
    String? contrasena,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      contrasena: contrasena ?? this.contrasena,
    );
  }
}
