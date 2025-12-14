// services/api_sensores_service.dart
import 'api_client.dart';
import '../models/sensor.dart';

class ApiSensoresService {
  final _api = ApiClient.instance;

  // Obtener sensores por instalación  
  Future<List<SensorInstalado>> getByInstalacion(int idInstalacion) async {
    final res = await _api.get('/api/instalaciones/$idInstalacion/sensores');
    final data = _api.decodeOrThrow(res);
    if (data is List) {
      return data
          .map((e) => SensorInstalado.fromJson((e as Map).cast()))
          .toList();
    }
    return [];
  }

  // Obtener catálogo de sensores disponibles
  Future<List<CatalogoSensor>> getCatalogo() async {
    try {
      final res = await _api.get('/api/sensores/catalogo');
      final data = _api.decodeOrThrow(res);
      if (data is List) {
        return data
            .map((e) => CatalogoSensor.fromJson((e as Map).cast()))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Crear nuevo tipo de sensor en catálogo
  Future<CatalogoSensor> crearCatalogoSensor(CatalogoSensor sensor) async {
    // ✅ CORRECCIÓN: Usar parámetro nombrado
    final res = await _api.post('/api/sensores/catalogo', body: sensor.toJson());
    final data = _api.decodeOrThrow(res);
    return CatalogoSensor.fromJson(data);
  }

  // Instalar sensor en instalación
  Future<SensorInstalado> instalarSensor({
    required int idInstalacion,
    required int idSensor,
    String? alias,
    String? descripcion,
  }) async {
    final Map<String, dynamic> bodyData = {
      'id_sensor': idSensor,
    };
    
    if (alias != null && alias.isNotEmpty) {
      bodyData['alias'] = alias;
    }
    if (descripcion != null && descripcion.isNotEmpty) {
      bodyData['descripcion'] = descripcion;
    }

    // ✅ CORRECCIÓN: Usar parámetro nombrado 'body:'
    final res = await _api.post('/api/instalaciones/$idInstalacion/sensores', body: bodyData);
    final data = _api.decodeOrThrow(res);
    return SensorInstalado.fromJson(data);
  }

  // Desinstalar sensor
  Future<void> desinstalarSensor(int idSensorInstalado) async {
    await _api.delete('/api/sensores/instalados/$idSensorInstalado');
  }

  // Obtener lecturas de un sensor
  Future<List<Map<String, dynamic>>> getLecturas({
    required int idSensorInstalado,
    int limite = 50,
  }) async {
    final res = await _api.get('/api/sensores/$idSensorInstalado/lecturas?limit=$limite');
    final data = _api.decodeOrThrow(res);
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  // Enviar lectura manual (para testing)
  Future<void> enviarLectura({
    required int idSensorInstalado,
    required double valor,
    DateTime? timestamp,
  }) async {
    final Map<String, dynamic> bodyData = {
      'valor': valor,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
    };

    // ✅ CORRECCIÓN: Usar parámetro nombrado 'body:'
    await _api.post('/api/sensores/$idSensorInstalado/lecturas', body: bodyData);
  }

  // Cambiar estado del sensor
  Future<void> cambiarEstado(int idSensorInstalado, String nuevoEstado) async {
    final Map<String, dynamic> bodyData = {
      'estado': nuevoEstado,
    };
    
    // ✅ CORRECCIÓN: Usar parámetro nombrado 'body:'
    await _api.put('/api/sensores/instalados/$idSensorInstalado/estado', body: bodyData);
  }
}
