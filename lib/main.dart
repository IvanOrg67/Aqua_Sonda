import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

import 'pantalla_login.dart';
import 'pantalla_sesion.dart';
import 'pantalla_registro.dart';
import 'pantalla_home.dart';
import 'pantalla_tareas.dart';
import 'pantalla_parametro_detalle.dart';
import 'pantalla_sensores.dart';

// DA ALIAS A CADA LIBRERÍA PARA EVITAR CHOQUE DE NOMBRES
import 'pantalla_instalacion.dart' as det; // detalle (singular)
import 'pantalla_instalaciones.dart' as lista; // listado (plural)
import 'pantalla_instalacion_detalle.dart'; // wrapper opcional

// Importar servicios necesarios para persistencia de sesión
import 'services/api_user_service.dart';
import 'services/api_installaciones_service.dart';

void main() async {
  // ✅ CRÍTICO: Inicializar bindings antes de usar async
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ NUEVO: Inicializar el controlador de tema
  await ThemeController.instance.init();
  
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AquaSense',
          theme: buildAppTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: ThemeController.instance.themeMode,
          home: const SplashScreen(),
          routes: {
            '/': (context) => const PantallaLogin(),
            '/login': (context) => const PantallaLogin(),
            '/sesion': (context) => const PantallaSesion(),
            '/registro': (context) => const PantallaRegistro(),
            '/register': (context) => const PantallaRegistro(),
            '/home': (context) => const PantallaHome(),

            // usa el alias 'lista' para la pantalla de LISTADO
            '/instalaciones': (context) => const lista.PantallaInstalaciones(),

            // usa el alias 'det' para la pantalla de DETALLE (sin const)
            '/instalacion': (context) => det.PantallaInstalacion(),

            // Wrapper opcional
            '/instalacion_detalle': (context) => const PantallaInstalacionDetalle(),
            '/instalacion-detalle': (context) => const PantallaInstalacionDetalle(),
            
            // Ruta tareas con parámetros
            '/tareas': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              final idInstalacion = args?['idInstalacion'] ?? args?['id_instalacion'] ?? 0;
              return PantallaTareas(idInstalacion: idInstalacion);
            },

            // ✅ NUEVO: Ruta de sensores con parámetros
            '/sensores': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              final idInstalacion = args?['idInstalacion'] ?? args?['id_instalacion'] ?? 0;
              final nombreInstalacion = args?['nombreInstalacion'] ?? args?['nombre_instalacion'] ?? 'Instalación';
              return PantallaSensores(
                idInstalacion: idInstalacion,
                nombreInstalacion: nombreInstalacion,
              );
            },
            
            '/parametro-detalle': (context) => const PantallaParametroDetalle(),
          },
        );
      },
    );
  }
}

// Pantalla de verificación de sesión mejorada
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkSession();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _checkSession() async {
    try {
      // Esperar que termine la animación inicial
      await Future.delayed(const Duration(milliseconds: 2000));
      
      final token = await ApiUserService().currentToken();
      
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        _navigateToLogin();
        return;
      }

      // Validar token haciendo una petición
      final isValid = await _validateToken();
      
      if (!mounted) return;
      
      if (isValid) {
        _navigateToHome();
      } else {
        await ApiUserService().logout();
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint('Error en verificación de sesión: $e');
      if (!mounted) return;
      _navigateToLogin();
    }
  }

  Future<bool> _validateToken() async {
    try {
      final installacionService = ApiInstalacionesService();
      await installacionService.listar();
      return true;
    } catch (e) {
      debugPrint('Error validando token: $e');
      return false;
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'nombre': 'Usuario',
      'rol': 'Usuario',
      'correo': null,
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? ThemeController.instance.getCurrentBackgroundColor(context)
          : Theme.of(context).colorScheme.primary,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animado
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                            : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water_drop,
                        size: 60,
                        color: isDark 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Título
                    Text(
                      'AquaSense',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: isDark 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtítulo
                    Text(
                      'Sistema de Monitoreo Acuícola',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark 
                            ? Theme.of(context).colorScheme.onBackground.withOpacity(0.7)
                            : Colors.white.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Indicador de carga
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Texto de estado
                    Text(
                      'Verificando sesión...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark 
                            ? Theme.of(context).colorScheme.onBackground.withOpacity(0.6)
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
