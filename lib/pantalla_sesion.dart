import 'package:flutter/material.dart';
import 'services/api_user_service.dart';

class PantallaSesion extends StatefulWidget {
  const PantallaSesion({super.key});

  @override
  State<PantallaSesion> createState() => _PantallaSesionState();
}

class _PantallaSesionState extends State<PantallaSesion> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiUserService();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await _api.login(
        correo: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Mapea el idRol a un texto simple para mostrar en el AppBar
      String rolTxt;
      switch (user.idRol) {
        case 1:
          rolTxt = 'admin';
          break;
        default:
          rolTxt = 'operador';
      }

      // Navega al Home pasando nombre y rol
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'nombre': user.nombre.isEmpty ? 'Usuario' : user.nombre,
          'rol': rolTxt,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Correo",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Ingresa tu correo";
                  }
                  final value = v.trim();
                  if (!value.contains("@") || !value.contains(".")) {
                    return "Correo inválido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                obscureText: _obscure,
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Ingresa tu contraseña" : null,
                onFieldSubmitted: (_) {
                  if (!_loading) _iniciarSesion();
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _iniciarSesion,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Entrar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
