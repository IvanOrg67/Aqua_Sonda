import 'api_client.dart';

class SensorInstalado {
  final int id;
  final String? nombre;
  final String? tipo;
  final String? parametro;
  final String? unidad;
  final String? estado;
  final String? ultimaLectura;

  SensorInstalado({
    required this.id,
    this.nombre,
    this.tipo,
    this.parametro,
    this.unidad,
    this.estado,
    this.ultimaLectura,
  });

  factory SensorInstalado.fromJson(Map<String, dynamic> j) => SensorInstalado(
        id: j['id_sensor_instalado'] ?? j['id'] ?? 0,
        nombre: j['nombre_sensor'] ?? j['alias'] ?? j['nombre'],
        tipo: j['tipo_sensor'] ?? j['tipo'],
        parametro: j['parametro'],
        unidad: j['unidad'],
        estado: j['estado'],
        ultimaLectura: j['ultima_lectura'],
      );
}

class ApiSensoresService {
  final _api = ApiClient.instance;

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
}
