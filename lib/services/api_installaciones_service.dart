import 'api_client.dart';

class EmpresaSucursal {
  final int id;
  final String nombreSucursal;
  final String empresaNombre;

  EmpresaSucursal({
    required this.id,
    required this.nombreSucursal,
    required this.empresaNombre,
  });

  factory EmpresaSucursal.fromJson(Map<String, dynamic> j) => EmpresaSucursal(
        id: j['id_empresa_sucursal'],
        nombreSucursal: j['nombre_sucursal'] ?? '',
        empresaNombre: j['empresa_nombre'] ?? '',
      );
}

class Instalacion {
  final int id;
  final int idEmpresaSucursal;
  final String nombre;
  final String descripcion;
  final String fechaCreacion;
  final String? nombreSucursal;
  final String? empresaNombre;

  Instalacion({
    required this.id,
    required this.idEmpresaSucursal,
    required this.nombre,
    required this.descripcion,
    required this.fechaCreacion,
    this.nombreSucursal,
    this.empresaNombre,
  });

  factory Instalacion.fromJson(Map<String, dynamic> j) => Instalacion(
        id: j['id_instalacion'] ?? j['id'] ?? 0,
        idEmpresaSucursal: j['id_empresa_sucursal'] ?? 1,
        nombre: j['nombre'] ?? j['nombre_instalacion'] ?? '–',
        descripcion: j['descripcion'] ?? '',
        fechaCreacion: j['fecha_creacion'] ?? '',
        nombreSucursal: j['nombre_sucursal'],
        empresaNombre: j['empresa_nombre'],
      );

  // Para mostrar en la UI
  String get displayName => nombre;
  String get displayLocation => nombreSucursal != null && empresaNombre != null 
      ? '$empresaNombre - $nombreSucursal' 
      : 'Sin ubicación';
}

class ApiInstalacionesService {
  final _api = ApiClient.instance;

  /// Lista todas las instalaciones con información de sucursal y empresa
  Future<List<Instalacion>> listar() async {
    final res = await _api.get('/api/instalaciones');
    final data = _api.decodeOrThrow(res);
    if (data is List) {
      return data.map((e) => Instalacion.fromJson((e as Map).cast())).toList();
    }
    return [];
  }

  /// Lista sucursales disponibles para selector
  Future<List<EmpresaSucursal>> listarSucursales() async {
    final res = await _api.get('/api/instalaciones/sucursales');
    final data = _api.decodeOrThrow(res);
    if (data is List) {
      return data.map((e) => EmpresaSucursal.fromJson((e as Map).cast())).toList();
    }
    return [];
  }

  /// Crea nueva instalación con el esquema actualizado
  Future<Instalacion> crear({
    int idEmpresaSucursal = 1, // Por defecto primera sucursal
    required String nombre,
    String descripcion = '',
  }) async {
    final body = {
      'id_empresa_sucursal': idEmpresaSucursal,
      'nombre_instalacion': nombre, // CAMBIO: usar nombre_instalacion
      'descripcion': descripcion,
    };
    
    final res = await _api.post('/api/instalaciones', body: body);
    final data = _api.decodeOrThrow(res) as Map<String, dynamic>;
    return Instalacion.fromJson(data);
  }

  /// Eliminar instalación (si implementas DELETE en backend)
  Future<void> eliminar(int id) async {
    final res = await _api.delete('/api/instalaciones/$id');
    _api.decodeOrThrow(res);
  }
}
