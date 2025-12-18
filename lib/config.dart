import 'dart:io' show Platform;

class AppConfig {
  // Para iPhone físico: flutter run --dart-define=API_HOST=TU_IP_LOCAL --dart-define=API_PORT=3300
  // Ejemplo: flutter run --dart-define=API_HOST=192.168.1.100 --dart-define=API_PORT=3300
  // Para obtener tu IP: ipconfig getifaddr en0 (en Terminal)
  static const String _apiHost =
      String.fromEnvironment('API_HOST', defaultValue: '');
  static const int _apiPort =
      int.fromEnvironment('API_PORT', defaultValue: 3300);

  static const bool _useHttps =
      bool.fromEnvironment('USE_HTTPS', defaultValue: false);

  static String get _resolvedHost {
    if (_apiHost.isNotEmpty) return _apiHost;

    // Defaults inteligentes para DEV
    if (Platform.isAndroid) return '10.0.2.2'; // Android emulator -> PC localhost
    if (Platform.isIOS) return '127.0.0.1'; // iOS simulator -> usar 127.0.0.1
    // NOTA: Para iPhone físico, DEBES pasar API_HOST con --dart-define
    return 'localhost'; // desktop
  }

  static String get apiBase {
    final scheme = _useHttps ? 'https' : 'http';
    return '$scheme://$_resolvedHost:$_apiPort';
  }

  static String get wsBase {
    final scheme = _useHttps ? 'wss' : 'ws';
    return '$scheme://$_resolvedHost:$_apiPort';
  }

  // Helpers (evita typos)
  static String _api(String path) => '$apiBase/api/$path';

  // Endpoints principales
  static String get apiOrganizaciones => _api('organizaciones');
  static String get apiSucursales => _api('sucursales');
  static String get apiInstalaciones => _api('instalaciones');
  static String get apiSensores => _api('catalogo-sensores');
  static String get apiSensoresInstalados => _api('sensores-instalados');
  static String get apiLecturas => _api('lecturas');
  static String get apiResumenHorario => _api('resumen-horario');
  static String get apiPromedios => _api('promedios');
  static String get apiReportes => _api('reportes/xml');
  static String get apiUsuarios => _api('usuarios');
  static String get apiTiposRol => _api('tipos-rol');
  static String get apiAlertas => _api('alertas');
  static String get apiParametros => _api('parametros');
  static String get apiEspecies => _api('catalogo-especies');
  static String get apiProcesos => _api('procesos');

  // WebSocket para lecturas
  static String get wsLecturas => '$wsBase/ws/lecturas';
}
