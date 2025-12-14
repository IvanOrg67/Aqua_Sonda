import 'api_client.dart';
import 'api_installaciones_service.dart'; // Para validar sesión

class UsuarioDto {
  final int idUsuario;
  final String nombre;
  final String correo;
  final int idRol;
  final String? token;

  UsuarioDto({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.idRol,
    this.token,
  });

  factory UsuarioDto.fromLogin(Map<String, dynamic> j) {
    final u = (j['user'] ?? j) as Map<String, dynamic>;
    return UsuarioDto(
      idUsuario: u['id_usuario'] ?? u['id'] ?? 0,
      nombre: u['nombre_completo'] ?? u['nombre'] ?? '',
      correo: u['correo'] ?? '',
      idRol: u['id_rol'] ?? 0,
      token: j['token'],
    );
  }
}

class ApiUserService {
  final _api = ApiClient.instance;

  Future<UsuarioDto> register({
    required String nombreCompleto,
    required String correo,
    required String password,
    String? telefono,
    int idRol = 2,
  }) async {
    if (idRol == 1) {
      idRol = 2;
    }
    final res = await _api.post('/auth/register', body: {
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'password': password,
      'telefono': telefono,
      'id_rol': idRol,
    });
    final data = _api.decodeOrThrow(res) as Map<String, dynamic>;
    final user = UsuarioDto.fromLogin(data);
    final token = data['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await _api.saveToken(token);
    }
    return user;
  }

  Future<UsuarioDto> login({
    required String correo,
    required String password,
  }) async {
    final res = await _api.post('/auth/login', body: {
      'correo': correo,
      'password': password,
    });
    final data = _api.decodeOrThrow(res) as Map<String, dynamic>;
    final user = UsuarioDto.fromLogin(data);
    final token = data['token'] as String?;
    if (token != null && token.isNotEmpty) await _api.saveToken(token);
    return user;
  }

  Future<void> logout() => _api.clearToken();
  
  Future<String?> currentToken() => _api.getToken();

  // NUEVO: Método para validar si la sesión actual es válida
  Future<bool> validateCurrentSession() async {
    try {
      final token = await currentToken();
      if (token == null || token.isEmpty) return false;

      // Hacer una petición autenticada simple para probar el token
      final installacionService = ApiInstalacionesService();
      await installacionService.listar();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _api.post('/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    _api.decodeOrThrow(res);
  }
}
