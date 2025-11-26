import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 1. Importamos el secure storage que instalamos
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Paleta de colores (la misma de signup)
const Color kPrimaryColor = Color(0xFFE65100);
const Color kAccentColor = Color(0xFFFFA726);
const Color kFocusColor = Color(0xFFFF6D00);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  // 2. Añadimos la variable para "Recordar correo"
  bool _rememberEmail = false;

  // 3. Instancia de Secure Storage
  final _storage = const FlutterSecureStorage();

  // 4. Creamos controladores para poder poner texto en los campos
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 5. Al iniciar la pantalla, intentamos leer el correo guardado
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    // Leemos el email del Keystore/Keychain
    final email = await _storage.read(key: 'saved_email');
    if (email != null) {
      setState(() {
        _emailController.text = email;
        _rememberEmail = true; // Marcamos la casilla
      });
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    // ... (Esta función se queda igual) ...
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kPrimaryColor),
      labelStyle: const TextStyle(color: kPrimaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kFocusColor, width: 2),
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _formKey.currentState!.save();

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // 6. ¡LÓGICA DE GUARDADO SEGURO!
      // Si el usuario marcó "Recordar", guardamos el email en el Keystore.
      if (_rememberEmail) {
        await _storage.write(key: 'saved_email', value: _email);
      } else {
        // Si no, nos aseguramos de borrarlo
        await _storage.delete(key: 'saved_email');
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }

    } on FirebaseAuthException catch (e) {
      // ... (El manejo de errores se queda igual) ...
       String message = 'Ocurrió un error. Revisa tus credenciales.';
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta. Intenta de nuevo.';
      } else if (e.code == 'invalid-credential' || e.code == 'invalid-email') {
         message = 'Credenciales inválidas o correo mal formado.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // ... (El manejo de errores se queda igual) ...
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToRegister() {
    Navigator.of(context).pushNamed('/register');
  }
  
  // 7. Nos aseguramos de limpiar el controlador al salir
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ... (El fondo degradado se queda igual) ...
        color: Color.fromARGB(255, 21, 21, 21),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tu logo (se queda igual)
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:  Color(0xFFE65100),
                          backgroundImage: AssetImage('assets/ko-logo.png'),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Inicia sesión',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          // 8. Asignamos el controlador al campo de email
                          controller: _emailController,
                          decoration: _buildInputDecoration('Correo electrónico', Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                          // Guardamos el valor (importante)
                          onSaved: (value) => _email = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _buildInputDecoration('Contraseña', Icons.lock),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                          onSaved: (value) => _password = value ?? '',
                        ),
                        
                        // 9. ¡NUEVO WIDGET! El Checkbox para recordar email
                        CheckboxListTile(
                          title: const Text('Recordar correo'),
                          value: _rememberEmail,
                          onChanged: (value) {
                            setState(() {
                              _rememberEmail = value ?? false;
                            });
                          },
                          activeColor: kFocusColor,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        
                        const SizedBox(height: 16), // Espacio
                        
                        ElevatedButton.icon(
                          // ... (Tu botón de Ingresar se queda igual) ...
                           style: ElevatedButton.styleFrom(
                            backgroundColor: kFocusColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isLoading
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: Text(
                            _isLoading ? 'Ingresando...' : 'Ingresar',
                            style: const TextStyle(fontSize: 16),
                          ),
                          onPressed: _isLoading ? null : _submitLogin,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          // ... (Tu botón de Registrarse se queda igual) ...
                           mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("¿No tienes una cuenta?"),
                            TextButton(
                              onPressed: _goToRegister,
                              style: TextButton.styleFrom(
                                foregroundColor: kPrimaryColor,
                              ),
                              child: const Text(
                                'Regístrate aquí',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}