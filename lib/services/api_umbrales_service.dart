import 'api_client.dart';
import '../models/alerta.dart';

class ApiUmbralesService {
  final _api = ApiClient.instance;

  /// Obtener umbrales configurados para un sensor
  Future<UmbralSensor?> getBySensor(int idSensorInstalado) async {
    try {
      final res = await _api.get('/api/sensores/$idSensorInstalado/umbral');
      final data = _api.decodeOrThrow(res);
      if (data != null && data is Map) {
        return UmbralSensor.fromJson(data.cast());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Crear o actualizar umbrales para un sensor
  Future<UmbralSensor> guardar(UmbralSensor umbral) async {
    final res = await _api.post(
      '/api/sensores/${umbral.idSensorInstalado}/umbral',
      body: umbral.toJson(),
    );
    final data = _api.decodeOrThrow(res);
    return UmbralSensor.fromJson(data);
  }

  /// Actualizar umbrales existentes
  Future<UmbralSensor> actualizar(UmbralSensor umbral) async {
    if (umbral.id == null) {
      throw Exception('El umbral debe tener un ID para actualizar');
    }
    final res = await _api.put(
      '/api/umbrales/${umbral.id}',
      body: umbral.toJson(),
    );
    final data = _api.decodeOrThrow(res);
    return UmbralSensor.fromJson(data);
  }

  /// Eliminar umbrales de un sensor
  Future<void> eliminar(int idUmbral) async {
    await _api.delete('/api/umbrales/$idUmbral');
  }

  /// Activar/desactivar umbrales
  Future<void> cambiarEstado(int idUmbral, bool activo) async {
    await _api.put('/api/umbrales/$idUmbral/estado', body: {'activo': activo});
  }

  /// Obtener umbrales predeterminados por tipo de sensor
  Future<UmbralSensor> getPredeterminados(String tipoMedida) async {
    final res = await _api.get('/api/umbrales/predeterminados/$tipoMedida');
    final data = _api.decodeOrThrow(res);
    return UmbralSensor.fromJson(data);
  }

  /// Obtener todos los umbrales de una instalación
  Future<List<UmbralSensor>> getByInstalacion(int idInstalacion) async {
    try {
      final res = await _api.get('/api/instalaciones/$idInstalacion/umbrales');
      final data = _api.decodeOrThrow(res);
      if (data is List) {
        return data.map((e) => UmbralSensor.fromJson((e as Map).cast())).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
