import 'api_client.dart';
import '../models/alerta.dart';

class ApiAlertasService {
  final _api = ApiClient.instance;

  /// Obtener alertas por instalación
  Future<List<Alerta>> getByInstalacion({
    required int idInstalacion,
    bool? soloNoLeidas,
    bool? soloNoResueltas,
    int limite = 50,
  }) async {
    final params = <String, String>{
      'limit': limite.toString(),
    };
    if (soloNoLeidas != null) params['no_leidas'] = soloNoLeidas.toString();
    if (soloNoResueltas != null) params['no_resueltas'] = soloNoResueltas.toString();

    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await _api.get('/api/instalaciones/$idInstalacion/alertas?$queryString');
    final data = _api.decodeOrThrow(res);
    
    if (data is List) {
      return data.map((e) => Alerta.fromJson((e as Map).cast())).toList();
    }
    return [];
  }

  /// Obtener alertas por sensor
  Future<List<Alerta>> getBySensor({
    required int idSensorInstalado,
    int limite = 50,
  }) async {
    final res = await _api.get('/api/sensores/$idSensorInstalado/alertas?limit=$limite');
    final data = _api.decodeOrThrow(res);
    
    if (data is List) {
      return data.map((e) => Alerta.fromJson((e as Map).cast())).toList();
    }
    return [];
  }

  /// Marcar alerta como leída
  Future<void> marcarComoLeida(int idAlerta) async {
    await _api.put('/api/alertas/$idAlerta/leer', body: {'leida': true});
  }

  /// Marcar alerta como resuelta
  Future<void> marcarComoResuelta(int idAlerta) async {
    await _api.put('/api/alertas/$idAlerta/resolver', body: {'resuelta': true});
  }

  /// Marcar todas las alertas de una instalación como leídas
  Future<void> marcarTodasComoLeidas(int idInstalacion) async {
    await _api.put('/api/instalaciones/$idInstalacion/alertas/leer-todas', body: {});
  }

  /// Obtener conteo de alertas no leídas por instalación
  Future<int> contarNoLeidas(int idInstalacion) async {
    try {
      final res = await _api.get('/api/instalaciones/$idInstalacion/alertas/count');
      final data = _api.decodeOrThrow(res);
      return data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Crear alerta manualmente (para testing o sistemas externos)
  Future<Alerta> crear(Alerta alerta) async {
    final res = await _api.post('/api/alertas', body: alerta.toJson());
    final data = _api.decodeOrThrow(res);
    return Alerta.fromJson(data);
  }

  /// Eliminar alerta
  Future<void> eliminar(int idAlerta) async {
    await _api.delete('/api/alertas/$idAlerta');
  }

  /// Obtener estadísticas de alertas
  Future<Map<String, dynamic>> getEstadisticas(int idInstalacion) async {
    final res = await _api.get('/api/instalaciones/$idInstalacion/alertas/estadisticas');
    return _api.decodeOrThrow(res) as Map<String, dynamic>;
  }
}
