import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';

class DatabaseAuthService {
  static const String _userIdKey = 'current_user_id';
  static const String _userDataKey = 'current_user_data';

  // ID del usuario actual (guardado en memoria y SharedPreferences)
  int? _currentUserId;
  Map<String, dynamic>? _currentUserData;

  int? get currentUserId => _currentUserId;
  Map<String, dynamic>? get currentUser => _currentUserData;
  bool get isLoggedIn => _currentUserId != null;

  // Cargar sesión desde SharedPreferences
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    final userDataJson = prefs.getString(_userDataKey);
    
    if (userId != null && userDataJson != null) {
      _currentUserId = userId;
      _currentUserData = jsonDecode(userDataJson) as Map<String, dynamic>;
    }
  }

  // Guardar sesión en SharedPreferences
  Future<void> _saveSession(int userId, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userDataKey, jsonEncode(userData));
    _currentUserId = userId;
    _currentUserData = userData;
  }

  // Limpiar sesión de SharedPreferences
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userDataKey);
    _currentUserId = null;
    _currentUserData = null;
  }

  // Login usando el endpoint de autenticación
  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    try {
      print('🔐 Intentando login con: $correo');

      // Usar el endpoint POST /api/auth/login
      final response = await http.post(
        Uri.parse('${AppConfig.apiBase}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo.trim(),
          'password': password,
        }),
      );

      print('📡 Respuesta status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al iniciar sesión');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>;
      
      // Guardar sesión persistente
      await _saveSession(userData['id_usuario'], userData);

      print('✅ Login exitoso: ${userData['nombre_completo']}');
      return {
        'success': true,
        'id_usuario': userData['id_usuario'],
        'nombre_completo': userData['nombre_completo'],
        'correo': userData['correo'],
        'telefono': userData['telefono'],
        'id_rol': userData['id_rol'],
        'rol_nombre': userData['rol_nombre'],
      };
    } catch (e) {
      print('❌ Error en login: $e');
      if (e is Exception) rethrow;
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  // Registro usando el endpoint de autenticación
  Future<Map<String, dynamic>> register({
    required String nombreCompleto,
    required String correo,
    required String password,
    String? telefono,
  }) async {
    try {
      print('📝 Intentando registrar: $correo');

      // POST /api/auth/register
      final response = await http.post(
        Uri.parse('${AppConfig.apiBase}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_completo': nombreCompleto.trim(),
          'correo': correo.trim().toLowerCase(),
          'password': password,
          'telefono': telefono?.trim(),
          'id_rol': 2, // Rol usuario por default
        }),
      );

      print('📡 Respuesta status: ${response.statusCode}');

      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al registrar');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>;

      // Guardar sesión persistente
      await _saveSession(userData['id_usuario'], userData);
      
      print('✅ Registro exitoso: ${userData['nombre_completo']}');
      return {
        'success': true,
        'id_usuario': userData['id_usuario'],
        'nombre_completo': userData['nombre_completo'],
        'correo': userData['correo'],
        'telefono': userData['telefono'],
        'id_rol': userData['id_rol'],
        'rol_nombre': userData['rol_nombre'],
      };
    } catch (e) {
      print('❌ Error en registro: $e');
      if (e is Exception) rethrow;
      throw Exception('Error al registrar: ${e.toString()}');
    }
  }

  // Obtener datos del usuario
  Future<Map<String, dynamic>?> getUserData(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUsuarios}/$idUsuario'),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _currentUserData = data;
      return data;
    } catch (e) {
      print('❌ Error al obtener datos: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _clearSession();
    _currentUserId = null;
    _currentUserData = null;
  }

  // Obtener usuario actual
  Future<Map<String, dynamic>?> getUsuarioActual() async {
    if (_currentUserId != null && _currentUserData != null) {
      return _currentUserData;
    }
    return null;
  }
}
