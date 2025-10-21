import 'package:flutter/material.dart';
import 'personal_data_protected.dart';
import 'privacy_notice.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _confirmEmail = '';
  String _password = '';
  String _confirmPassword = '';
  String _role = 'Gerente';
  bool _acceptedPrivacy = false;
  bool _acceptedPersonalData = false;

  void _submit() {
    if (_formKey.currentState!.validate() && _acceptedPrivacy) {
      _formKey.currentState!.save();
      print('Nombre: $_name');
      print('Correo: $_email');
      print('Rol: $_role');
      // Aquí iría tu lógica de registro
    }
  }

  void _showPrivacyModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aviso de Privacidad'),
        content: SingleChildScrollView(
          child: Text(
            privacyNotice
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPersonalDataModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aviso de protección de datos personales'),
        content: SingleChildScrollView(
          child: Text(
            personalDataProtected
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) =>
                    value != null && value.isNotEmpty ? null : 'Campo requerido',
                onSaved: (value) => _name = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value != null && value.contains('@') ? null : 'Correo inválido',
                onSaved: (value) => _email = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Confirmar correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == _email ? null : 'Los correos no coinciden',
                onSaved: (value) => _confirmEmail = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Mínimo 6 caracteres',
                onSaved: (value) => _password = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                obscureText: true,
                validator: (value) =>
                    value == _password ? null : 'Las contraseñas no coinciden',
                onSaved: (value) => _confirmPassword = value ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'Gerente', child: Text('Gerente')),
                  DropdownMenuItem(value: 'Chef', child: Text('Chef')),
                  DropdownMenuItem(value: 'Repartidor', child: Text('Repartidor')),
                ],
                onChanged: (value) => setState(() => _role = value ?? 'Gerente'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Acepto el aviso de privacidad'),
                value: _acceptedPrivacy,
                onChanged: (value) => setState(() => _acceptedPrivacy = value ?? false),
              ),
              TextButton(
                onPressed: _showPrivacyModal,
                child: const Text('Ver aviso de privacidad'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Acepto el aviso de protección de datos personales'),
                value: _acceptedPersonalData,
                onChanged: (value) => setState(() => _acceptedPersonalData = value ?? false),
              ),
              TextButton(
                onPressed: _showPersonalDataModal,
                child: const Text('Ver aviso de protección de datos personales'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: 
                  (_acceptedPrivacy && _acceptedPersonalData ) ? _submit : null,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}