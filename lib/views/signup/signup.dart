import 'package:flutter/material.dart';

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
            '''
Aviso de Privacidad – Kitchen Orchestrator App
Última actualización: 20 de octubre de 2025

1. Datos personales que se recaban
La aplicación Kitchen Orchestrator recopila los siguientes datos personales de los empleados registrados:
- Nombre completo
- Correo electrónico institucional
- Contraseña (almacenada de forma cifrada)

2. Finalidad del tratamiento
Los datos personales son utilizados exclusivamente para:
- Autenticación y acceso seguro a la aplicación
- Identificación del usuario dentro del sistema
- Gestión de roles y permisos en el entorno laboral digital

3. Consentimiento informado
El usuario otorga su consentimiento explícito al registrarse en la aplicación y aceptar este aviso de privacidad.

4. Seguridad de los datos
Se implementan medidas técnicas y administrativas para proteger los datos personales, incluyendo:
- Cifrado de contraseñas mediante algoritmos seguros
- Comunicación cifrada mediante HTTPS
- Control de acceso basado en roles

5. Derechos ARCO
Los usuarios pueden ejercer en cualquier momento sus derechos de:
- Acceso
- Rectificación
- Cancelación
- Oposición

Para ejercer estos derechos, el usuario puede enviar una solicitud al correo: privacidad@kitchenorchestrator.dev

6. Retención de datos
Los datos personales se conservarán únicamente durante el tiempo necesario para cumplir con las finalidades descritas.

7. Transferencia de datos
No se realizan transferencias de datos personales a terceros sin el consentimiento previo del usuario.

8. Notificación de brechas de seguridad
En caso de una brecha de seguridad, se notificará al usuario indicando:
- Naturaleza de la brecha
- Datos comprometidos
- Medidas correctivas adoptadas

9. Acceso a la política
Este aviso de privacidad está disponible en la pantalla de registro y en el menú de configuración.
''',
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _acceptedPrivacy ? _submit : null,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}