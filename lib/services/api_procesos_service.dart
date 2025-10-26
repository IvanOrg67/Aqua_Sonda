import 'api_client.dart';

class Proceso {
  final int id;
  final int idInstalacion;
  final int idEspecie;
  final String fechaInicio;
  final String? fechaFinal;
  final String estado;
  final String? notas;
  final String? especie;

  Proceso({
    required this.id,
    required this.idInstalacion,
    required this.idEspecie,
    required this.fechaInicio,
    this.fechaFinal,
    required this.estado,
    this.notas,
    this.especie,
  });

  factory Proceso.fromJson(Map<String, dynamic> j) => Proceso(
        id: j['id_proceso'] ?? j['id'] ?? 0,
        idInstalacion: j['id_instalacion'],
        idEspecie: j['id_especie'],
        fechaInicio: j['fecha_inicio'],
        fechaFinal: j['fecha_final'],
        estado: j['estado'],
        notas: j['notas'],
        especie: j['especie'],
      );
}

class ApiProcesosService {
  final _api = ApiClient.instance;

  Future<Proceso> crear({
    required int idInstalacion,
    required int idEspecie,
    required String fechaInicio, // 'YYYY-MM-DD'
    String? fechaFinal,
    String estado = 'activo',
    String? notas,
  }) async {
    final res = await _api.post('/api/procesos', body: {
      'id_instalacion': idInstalacion,
      'id_especie': idEspecie,
      'fecha_inicio': fechaInicio,
      'fecha_final': fechaFinal,
      'estado': estado,
      'notas': notas,
    });
    final data = _api.decodeOrThrow(res) as Map<String, dynamic>;
    return Proceso.fromJson(data);
  }

  Future<List<Proceso>> listarPorInstalacion(int idInstalacion) async {
    final res = await _api.get('/api/procesos/por-instalacion/$idInstalacion');
    final data = _api.decodeOrThrow(res) as List<dynamic>;
    return data
        .map((e) => Proceso.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
