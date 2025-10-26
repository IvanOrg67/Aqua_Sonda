import 'api_client.dart';

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
    // Seguridad defensiva: si por alguna razón llega un id de rol no permitido,
    // lo forzamos a uno válido (2=admin_cuenta, 3=visor).
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

  Future<void> changePassword({
    required String correo,
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _api.post('/auth/change-password', body: {
      'correo': correo,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    _api.decodeOrThrow(res);
  }
}
