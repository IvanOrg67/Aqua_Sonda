import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;

  // ❌ ELIMINAR este getter que causa problemas
  // ValueNotifier<ThemeMode> get mode => ValueNotifier<ThemeMode>(_themeMode);

  // ✅ NUEVO: Getter para verificar si está en modo oscuro
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Inicializar el controlador cargando preferencia guardada
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = prefs.getInt('theme_mode') ?? 0;
      
      switch (savedThemeIndex) {
        case 0:
          _themeMode = ThemeMode.light;
          break;
        case 1:
          _themeMode = ThemeMode.dark;
          break;
        case 2:
          _themeMode = ThemeMode.system;
          break;
        default:
          _themeMode = ThemeMode.light;
      }
      
      notifyListeners();
    } catch (e) {
      // Si falla, usar tema claro por defecto
      _themeMode = ThemeMode.light;
    }
  }

  // Cambiar entre claro y oscuro
  Future<void> toggle() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _savePreference();
    notifyListeners();
  }

  // Establecer tema específico
  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    await _savePreference();
    notifyListeners();
  }

  // Guardar preferencia en SharedPreferences
  Future<void> _savePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int themeIndex;
      
      switch (_themeMode) {
        case ThemeMode.light:
          themeIndex = 0;
          break;
        case ThemeMode.dark:
          themeIndex = 1;
          break;
        case ThemeMode.system:
          themeIndex = 2;
          break;
      }
      
      await prefs.setInt('theme_mode', themeIndex);
    } catch (e) {
      // Error guardando - continuar sin guardar
      debugPrint('Error guardando tema: $e');
    }
  }

  // Método para obtener el color de fondo actual (útil para widgets)
  Color getCurrentBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? const Color(0xFF0F141A) // AppColorsDark.bg
        : const Color(0xFFF7F9FC); // AppColors.bg
  }

  // Método para obtener el color de superficie actual
  Color getCurrentSurfaceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? const Color(0xFF1B222B) // AppColorsDark.surface
        : const Color(0xFFFFFFFF); // AppColors.surface
  }
}
