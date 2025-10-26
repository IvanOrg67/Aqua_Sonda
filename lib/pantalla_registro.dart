// lib/pantalla_registro.dart
import 'package:flutter/material.dart';
import 'services/api_user_service.dart';
import 'theme/theme_controller.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiUserService();

  String nombre = '';
  String correo = '';
  String password = '';
  String telefono = '';
  bool cargando = false;
  int? idRol = 2;
  // Removemos 'super_admin' del listado de roles disponibles
  final roles = const [
    {'id': 2, 'nombre': 'admin_cuenta'},
    {'id': 3, 'nombre': 'visor'},
  ];

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => cargando = true);
    if (idRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de rol')),
      );
      setState(() => cargando = false);
      return;
    }
    try {
      await _api.register(
        nombreCompleto: nombre.trim(),
        correo: correo.trim(),
        password: password,
        idRol: idRol!,
        telefono: telefono.trim().isEmpty ? null : telefono.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrarse: $e')),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final isDark = base.brightness == Brightness.dark;
    final formTheme = base.copyWith(
      // No forzamos fondo claro; dejamos que el tema global maneje el fondo
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        foregroundColor: base.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
    fillColor: isDark
      ? base.colorScheme.surfaceContainerHighest.withValues(alpha: 0.24)
      : const Color(0xFFF3F4F6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.primary),
        ),
      ),
    );

    return Theme(
      data: formTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registro'),
          actions: [
            IconButton(
              tooltip: 'Alternar tema',
              onPressed: () => ThemeController.instance.toggle(),
              icon: Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Icon(isDark ? Icons.light_mode : Icons.dark_mode);
                },
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: "Tipo de rol",
                      border: OutlineInputBorder(),
                    ),
                    initialValue: idRol,
                    items: roles
                        .map((r) => DropdownMenuItem<int>(
                              value: r['id'] as int,
                              child: Text(r['nombre'] as String),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => idRol = v),
                    validator: (v) => v == null ? "Selecciona un rol" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => nombre = v,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Ingresa tu nombre"
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Correo",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => correo = v,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? "Correo inválido"
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Teléfono (opcional)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => telefono = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Contraseña",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: (v) => password = v,
                    validator: (v) => (v == null || v.length < 4)
                        ? "Mínimo 4 caracteres"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cargando ? null : _registrar,
                      child: Text(cargando ? 'Creando...' : 'Crear cuenta'),
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
