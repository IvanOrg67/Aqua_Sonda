import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

import 'pantalla_login.dart';
import 'pantalla_registro.dart';
import 'pantalla_home.dart';
import 'pantalla_parametro_detalle.dart';
import 'pantalla_procesos.dart';
import 'pantalla_especies.dart';
import 'services/database_auth_service.dart';

// DA ALIAS A CADA LIBRERÍA PARA EVITAR CHOQUE DE NOMBRES
import 'pantalla_instalacion.dart' as det; // detalle (singular)
import 'pantalla_instalaciones.dart' as lista; // listado (plural)

void main() async {
  // ✅ CRÍTICO: Inicializar bindings antes de usar async
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Inicializar el controlador de tema
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
            '/registro': (context) => const PantallaRegistro(),
            '/register': (context) => const PantallaRegistro(),
            '/home': (context) => const PantallaHome(),

            // Instalaciones
            '/instalaciones': (context) => const lista.PantallaInstalaciones(),
            '/instalacion': (context) => det.PantallaInstalacion(),
            
            // Gestión de datos
            '/procesos': (context) => const PantallaProcesos(),
            '/especies': (context) => const PantallaEspecies(),
            
            // Parámetros
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
      
      final authService = DatabaseAuthService();
      
      // Cargar sesión guardada de SharedPreferences
      await authService.loadSession();
      
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        if (!mounted) return;
        _navigateToLogin();
        return;
      }

      // Usuario autenticado, obtener datos actualizados
      final userData = await authService.getUserData(authService.currentUserId!);
      
      if (!mounted) return;
      
      if (userData != null) {
        _navigateToHome(userData);
      } else {
        authService.logout();
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint('Error en verificación de sesión: $e');
      if (!mounted) return;
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToHome([Map<String, dynamic>? userData]) {
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'nombre': userData?['nombre_completo'] ?? 'Usuario',
      'rol': userData?['roles']?['nombre_rol'] ?? 'Usuario',
      'correo': userData?['correo'] ?? '',
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