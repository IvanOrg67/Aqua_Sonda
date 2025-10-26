import 'api_client.dart';
import '../models/tarea_programada.dart';

class ApiTareasService {
  final _api = ApiClient.instance;

  Future<List<TareaProgramada>> listarPorInstalacion(int idInstalacion) async {
    final res = await _api.get('/api/tareas-programadas/$idInstalacion');
    final data = _api.decodeOrThrow(res) as List<dynamic>;
    return data.map((e) => TareaProgramada.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TareaProgramada> crear(TareaProgramada tarea) async {
    final res = await _api.post('/api/tareas-programadas', body: tarea.toJson());
    final data = _api.decodeOrThrow(res) as Map<String, dynamic>;
    return TareaProgramada.fromJson(data);
  }

  Future<TareaProgramada> editar(int id, Map<String, dynamic> fields) async {
    final res = await _api.put('/api/tareas-programadas/$id', body: fields);
    final data = _api.decodeOrThrow(res) as Map<String, dynamic>;
    return TareaProgramada.fromJson(data);
  }

  Future<void> eliminar(int id) async {
    final res = await _api.delete('/api/tareas-programadas/$id');
    _api.decodeOrThrow(res);
  }
}
