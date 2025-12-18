import 'package:flutter/material.dart';
import 'services/database_auth_service.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _authService = DatabaseAuthService();
  bool _loading = false;
  String? _error;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      print('📝 Iniciando registro...');
      print('Correo: ${_correoCtrl.text.trim()}');
      print('Nombre: ${_nombreCtrl.text.trim()}');
      
      final userData = await _authService.register(
        nombreCompleto: _nombreCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        password: _passCtrl.text,
        telefono: _telCtrl.text.isEmpty ? null : _telCtrl.text.trim(),
      );
      
      if (!mounted) return;
      
      print('✅ Usuario registrado: ${userData['id_usuario']}');
      print('📊 Datos obtenidos: $userData');
      
      // Ir directamente al home
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'nombre': userData['nombre_completo'] ?? 'Usuario',
          'rol': userData['nombre_rol'] ?? 'Usuario',
          'correo': userData['correo'] ?? '',
        },
      );
    } catch (e) {
      print('❌ Error en registro: $e');
      setState(() { 
        _error = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AuthException: ', ''); 
      });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Regístrate',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      hintText: 'tucorreo@dominio.com',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      // Validación mejorada de email
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                      );
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (v) =>
                      (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono (opcional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!,
                      style: TextStyle(color: cs.error),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading ? null : _registrar,
                    child: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Crear cuenta'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading ? null : () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Ya tengo cuenta, iniciar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
