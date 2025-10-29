import 'package:flutter/material.dart';
// Importa Firebase Auth (para el login seguro)
import 'package:firebase_auth/firebase_auth.dart';
// ¡Importa Realtime Database!
import 'package:firebase_database/firebase_database.dart'; 

import 'personal_data_protected.dart'; 
import 'privacy_notice.dart';

// Definimos nuestra paleta de colores
const Color kPrimaryColor = Color(0xFFE65100); // Naranja oscuro (Ej. AppBar)
const Color kAccentColor = Color(0xFFFFA726); // Naranja claro (Ej. Botones)
const Color kFocusColor = Color(0xFFFF6D00); // Naranja intenso (Ej. Borde de input)

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  // 1. Añadimos la variable para el nombre del restaurante
  String _restaurantName = ''; 

  bool _acceptedPrivacy = false;
  bool _acceptedPersonalData = false;
  bool _isLoading = false;

  // 2. Definimos la decoración de los inputs para un look consistente
  InputDecoration _buildInputDecoration(String label, IconData icon) {
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


  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _formKey.currentState!.save();
    
    // 3. ¡Importante! Limpiamos el nombre del restaurante
    // Las claves de RTDB no pueden contener: . # $ [ ]
    final String restaurantKey = _restaurantName.replaceAll(RegExp(r'[.#$\[\]]'), '');

    try {
      // 4. Creamos el usuario en FirebaseAuth (¡La forma segura!)
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      User? newUser = userCredential.user;

      if (newUser != null) {
        // 5. Guardamos los datos extra en REALTIME DATABASE
        
        // Nombre del Restaurante -> Usuarios -> UID_del_Usuario -> {datos}
        DatabaseReference userRef = FirebaseDatabase.instance.ref()
            .child(restaurantKey) // Nodo raíz: "Nombre del restaurante"
            .child('Usuarios')      // Sub-nodo "Usuarios"
            .child(newUser.uid);  // ID único del usuario

        // Guardamos los datos del usuario
        await userRef.set({
          'uid': newUser.uid,
          'name': _name,
          'email': _email,
          'role': 'Gerente', 
          'createdAt': ServerValue.timestamp, 
        });

        DatabaseReference profileRef = FirebaseDatabase.instance.ref()
            .child('user_profiles')
            .child(newUser.uid);

        await profileRef.set({
          'restaurantName': restaurantKey, // Guardamos el nombre del restaurante
          'role': 'Gerente', // Guardamos el rol
        });

        //Creamos otros nodos base para el restaurante
        await FirebaseDatabase.instance.ref()
            .child(restaurantKey)
            .child('Pedidos')
            .set(''); // Crea un nodo 'Pedidos' vacío
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Restaurante y Gerente registrados!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }

    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error. Intenta de nuevo.';
      if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil (mínimo 6 caracteres).';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo electrónico ya está en uso.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
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

  
  void _showPrivacyModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Borde redondeado para combinar con el diseño
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Título en color naranja
          title: const Text(
            'Aviso de Privacidad',
            style: TextStyle(color: kPrimaryColor), 
          ),
          content: const SingleChildScrollView(
            // Esta variable 'privacyNotice' viene de tu import
            child: Text(privacyNotice),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              // Botón en color naranja
              style: TextButton.styleFrom(foregroundColor: kFocusColor),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
  void _showPersonalDataModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Borde redondeado
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Título en color naranja
          title: const Text(
            'Aviso de protección de datos',
            style: TextStyle(color: kPrimaryColor),
          ),
          content: const SingleChildScrollView(
            // Esta variable 'personalDataProtected' viene de tu import
            child: Text(personalDataProtected),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              // Botón en color naranja
              style: TextButton.styleFrom(foregroundColor: kFocusColor),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 6. Aplicamos el color naranja a la AppBar
      appBar: AppBar(
        title: const Text('Registrar mi Restaurante'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 7. Nuevo campo para "Nombre del Restaurante"
              TextFormField(
                decoration: _buildInputDecoration('Nombre del Restaurante', Icons.store),
                validator: (value) {
                   if (value == null || value.isEmpty) {
                    return 'Campo requerido';
                   }
                   if (value.contains(RegExp(r'[.#$\[\]]'))) {
                     return 'No uses caracteres especiales (. # \$ [ ])';
                   }
                   return null;
                },
                onSaved: (value) => _restaurantName = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _buildInputDecoration('Nombre completo (Gerente)', Icons.person),
                validator: (value) =>
                    value != null && value.isNotEmpty ? null : 'Campo requerido',
                onSaved: (value) => _name = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _buildInputDecoration('Correo (Gerente)', Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Correo inválido';
                  }
                  _email = value;
                  return null;
                },
                onSaved: (value) => _email = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _buildInputDecoration('Confirmar correo', Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == _email ? null : 'Los correos no coinciden',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _buildInputDecoration('Contraseña', Icons.lock),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  _password = value;
                  return null;
                },
                onSaved: (value) => _password = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _buildInputDecoration('Confirmar contraseña', Icons.lock_outline),
                obscureText: true,
                validator: (value) =>
                    value == _password ? null : 'Las contraseñas no coinciden',
              ),
              
              // 8. Quitamos el Dropdown de Rol
              
              const SizedBox(height: 16),
              // 9. Aplicamos estilos a Checkbox y TextButton
              CheckboxListTile(
                title: const Text('Acepto el aviso de privacidad'),
                value: _acceptedPrivacy,
                onChanged: (value) => setState(() => _acceptedPrivacy = value ?? false),
                activeColor: kFocusColor,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              Center(
                child: TextButton(
                  onPressed: _showPrivacyModal,
                  style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                  child: const Text('Ver aviso de privacidad'),
                ),
              ),
              CheckboxListTile(
                title: const Text('Acepto el aviso de protección de datos personales'),
                value: _acceptedPersonalData,
                onChanged: (value) => setState(() => _acceptedPersonalData = value ?? false),
                activeColor: kFocusColor,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              Center(
                child: TextButton(
                  onPressed: _showPersonalDataModal,
                  style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                  child: const Text('Ver aviso de protección de datos personales'),
                ),
              ),
              const SizedBox(height: 20),
              
              // 10. Aplicamos estilo al botón principal
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    (_acceptedPrivacy && _acceptedPersonalData && !_isLoading)
                        ? _submit
                        : null,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Registrar Restaurante', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}