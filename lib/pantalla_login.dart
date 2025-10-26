import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'services/api_user_service.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _apiUser = ApiUserService();
  bool _cargando = false;

  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscureText = true;

  Future<void> _hacerLogin(String correo, String password) async {
    setState(() => _cargando = true);
    try {
      final usuario =
          await _apiUser.login(correo: correo.trim(), password: password);
      if (!mounted) return;

      // Obtenemos el nombre del rol desde el ID
      String rol = 'Usuario';
      switch (usuario.idRol) {
        case 1:
          rol = 'Administrador';
          break;
        case 2:
          rol = 'Supervisor';
          break;
        case 3:
          rol = 'Operador';
          break;
      }

      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'nombre': usuario.nombre,
          'rol': rol,
          'correo': usuario.correo,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(); // loop continuo
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final isLandscape = mq.orientation == Orientation.landscape;
    final shortest = size.shortestSide;

    // Escala base por tamaño de dispositivo
    final scale = (shortest / 400).clamp(0.9, 1.6);

    // Ancho máximo para que el contenido central no “flote” en tablet
    final maxContentWidth = isLandscape ? 580.0 : 420.0;

    // Zona “limpia” central para evitar que los PNG tapen texto/botones
    final safeTop = isLandscape ? 24.0 : 48.0;
    final safeBottom = isLandscape ? 24.0 : 80.0;
    final safeHorizontal = 24.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // =======================
              // DECORACIONES ANIMADAS
              // =======================
              // Esquinas
              _cornerFishAnimated(
                asset:
                    'assets/images/image-OyC5XxX4C1kljpUjzBKrYjySGLjptr.png', // crustáceo verde
                width: (isLandscape ? 200 : 180) * scale,
                align: Alignment.topLeft,
                dx: -0.10,
                dy: -0.08,
                ampX: 10 * scale,
                ampY: 6 * scale,
                phase: 0.0,
              ),
              _cornerFishAnimated(
                asset:
                    'assets/images/image-MLydriTvlAs4FTjrB06WvnQWBE2Ykm.png', // pez azul
                width: (isLandscape ? 240 : 210) * scale,
                align: Alignment.topRight,
                dx: 0.10,
                dy: -0.06,
                ampX: 12 * scale,
                ampY: 7 * scale,
                phase: math.pi / 3,
              ),
              _cornerFishAnimated(
                asset:
                    'assets/images/image-1ZoixW91pByrJkUhBuYXIKBFXjMjOG.png', // pez blanco
                width: (isLandscape ? 220 : 200) * scale,
                align: Alignment.bottomLeft,
                dx: -0.10,
                dy: 0.10,
                ampX: 10 * scale,
                ampY: 8 * scale,
                phase: math.pi * 2 / 3,
              ),
              _cornerFishAnimated(
                asset:
                    'assets/images/image-Q2HqrMQ9tDGrL02AsUSfcjdt6CR3j4.png', // camarón beige
                width: (isLandscape ? 240 : 220) * scale,
                align: Alignment.bottomRight,
                dx: 0.12,
                dy: 0.10,
                ampX: 12 * scale,
                ampY: 10 * scale,
                phase: math.pi,
              ),

              // Laterales (alejados del centro)
              _sideFishAnimated(
                asset:
                    'assets/images/image-zic2IxV5JIcwZNDbfSGoqTQabspXOK.png', // bicho naranja
                width: (isLandscape ? 200 : 170) * scale,
                left: 0,
                top: size.height * (isLandscape ? 0.62 : 0.58),
                ampX: 14 * scale,
                ampY: 6 * scale,
                phase: math.pi / 4,
              ),
              _sideFishAnimated(
                asset:
                    'assets/images/image-uMEYLuXPNs6uobZLiISvXPlB6lf5xA.png', // pez pequeño
                width: (isLandscape ? 180 : 150) * scale,
                right: 0,
                top: size.height * (isLandscape ? 0.30 : 0.36),
                ampX: 12 * scale,
                ampY: 5 * scale,
                phase: 3 * math.pi / 4,
              ),

              // Superior centrado, pero fuera del eje de texto
              Positioned(
                top: safeTop - 28 * scale,
                left: safeHorizontal,
                right: safeHorizontal,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _floating(
                      ampX: 8 * scale,
                      ampY: 8 * scale,
                      phase: math.pi / 2,
                      child: Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/images/pulpo.png',
                          width: (isLandscape ? 220 : 180) * scale,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Velo sutil para mejorar contraste
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.06),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.08),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // =======================
              // CONTENIDO CENTRAL
              // =======================
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        safeHorizontal, safeTop, safeHorizontal, safeBottom),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'AquaSense',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Monitoreo de estanques en tiempo real',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 28 * (scale * 0.9)),
                          TextFormField(
                            controller: _correoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Por favor, ingrese su correo';
                              }
                              if (!val.contains('@')) {
                                return 'Correo no válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _obscureText = !_obscureText),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Por favor, ingrese su contraseña';
                              }
                              if (val.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: (54 * scale).clamp(48, 64),
                            child: ElevatedButton(
                              onPressed: _cargando
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        await _hacerLogin(
                                          _correoCtrl.text,
                                          _passwordCtrl.text,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: _cargando
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('INICIAR SESIÓN'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: (54 * scale).clamp(48, 64),
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/registro'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.white24, width: 1),
                                backgroundColor: Colors.white10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('REGISTRARSE'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers de animación =====

  // Aplica un “flotado” senoidal al child
  Widget _floating({
    required double ampX,
    required double ampY,
    required double phase,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value * 2 * math.pi + phase;
        final dx = math.sin(t) * ampX;
        final dy = math.cos(t) * ampY;
        return Transform.translate(offset: Offset(dx, dy), child: child);
      },
    );
  }

  Widget _cornerFishAnimated({
    required String asset,
    required double width,
    required Alignment align,
    double dx = 0.0,
    double dy = 0.0,
    double ampX = 8.0,
    double ampY = 6.0,
    double phase = 0.0,
  }) {
    return Align(
      alignment: align,
      child: FractionalTranslation(
        translation: Offset(dx, dy),
        child: IgnorePointer(
          child: _floating(
            ampX: ampX,
            ampY: ampY,
            phase: phase,
            child: Image.asset(
              asset,
              width: width,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sideFishAnimated({
    required String asset,
    required double width,
    double? left,
    double? right,
    required double top,
    double ampX = 10.0,
    double ampY = 6.0,
    double phase = 0.0,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: IgnorePointer(
        child: _floating(
          ampX: ampX,
          ampY: ampY,
          phase: phase,
          child: Image.asset(
            asset,
            width: width,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
