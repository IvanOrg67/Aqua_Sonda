import 'api_client.dart';

class Instalacion {
  final int id;
  final int? idUsuarioCreador;
  final int? idEmpresa;
  final String nombre;
  final String fechaInstalacion;
  final String estado;
  final String uso;
  final String descripcion;

  Instalacion({
    required this.id,
    this.idUsuarioCreador,
    this.idEmpresa,
    required this.nombre,
    required this.fechaInstalacion,
    required this.estado,
    required this.uso,
    required this.descripcion,
  });

  factory Instalacion.fromJson(Map<String, dynamic> j) => Instalacion(
        id: j['id'] ?? j['id_instalacion'],
        idUsuarioCreador: j['id_usuario_creador'],
        idEmpresa: j['id_empresa'] ?? j['id_empresa_sucursal'],
        nombre: j['nombre'] ?? j['nombre_instalacion'] ?? '–',
        fechaInstalacion: j['fecha_instalacion'] ?? '',
        estado: j['estado'] ?? j['estado_operativo'] ?? 'activo',
        uso: j['uso'] ?? j['tipo_uso'] ?? 'acuicultura',
        descripcion: j['descripcion'] ?? '',
      );
}

class ApiInstalacionesService {
  final _api = ApiClient.instance;

  Future<List<Instalacion>> listar() async {
    final res = await _api.get('/api/instalaciones');
    final data = _api.decodeOrThrow(res);
    if (data is List) {
      return data.map((e) => Instalacion.fromJson((e as Map).cast())).toList();
    }
    return [];
  }

  Future<Instalacion> crear({
    int? idEmpresa,
    required String nombre,
    required String fechaInstalacion, // yyyy-MM-dd
    String estado = 'activo',
    String uso = 'acuicultura',
    String descripcion = '',
  }) async {
    final body = {
      'id_empresa': idEmpresa,
      'nombre': nombre,
      'fecha_instalacion': fechaInstalacion,
      'estado': estado,
      'uso': uso,
      'descripcion': descripcion,
    };
    final res = await _api.post('/api/instalaciones', body: body);
    final data = _api.decodeOrThrow(res) as Map<String, dynamic>;
    return Instalacion.fromJson(data);
  }

  Future<void> eliminar(int id) async {
    final res = await _api.delete('/api/instalaciones/$id');
    _api.decodeOrThrow(res);
  }
}
