import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/lectura.dart';

class ApiService {
  // Lecturas
  // idSensorInstalado: ID del sensor instalado (id_sensor_instalado en BD)
  Future<List<Lectura>> getLecturas(int idSensorInstalado, {int limit = 100}) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiLecturas}?sensorInstaladoId=$idSensorInstalado&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Lectura.fromJson(item)).toList();
    }
    throw Exception('Error al cargar lecturas');
  }

  Future<void> createLectura({
    required int idSensorInstalado, // ID del sensor instalado
    required double valor,
  }) async {
    final response = await http.post(
      Uri.parse(AppConfig.apiLecturas),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_sensor_instalado': idSensorInstalado,
        'valor': valor,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear lectura');
    }
  }

  // Sensores del catálogo
  Future<List<Map<String, dynamic>>> getCatalogoSensores() async {
    final response = await http.get(Uri.parse(AppConfig.apiSensores));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Sensores instalados
  Future<List<Map<String, dynamic>>> getSensores(int idInstalacion) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiSensoresInstalados}?id_instalacion=$idInstalacion'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> deleteSensor(int idSensorInstalado) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.apiSensoresInstalados}/$idSensorInstalado'),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar sensor');
    }
  }

  Future<void> createSensor({
    required int idSensor, // ID del sensor del catálogo
    required int idInstalacion,
    required String descripcion,
    DateTime? fechaInstalada,
  }) async {
    final response = await http.post(
      Uri.parse(AppConfig.apiSensoresInstalados),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_instalacion': idInstalacion,
        'id_sensor': idSensor,
        'fecha_instalada': (fechaInstalada ?? DateTime.now()).toIso8601String().split('T')[0],
        'descripcion': descripcion,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear sensor instalado');
    }
  }

  // Instalaciones
  Future<List<Map<String, dynamic>>> getInstalaciones([int? idUsuario]) async {
    final response = await http.get(Uri.parse(AppConfig.apiInstalaciones));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> getEstadisticas(int idUsuario) async {
    // Obtener estadísticas básicas desde instalaciones y sensores
    final instalaciones = await getInstalaciones(idUsuario);
    int totalSensores = 0;
    
    for (var inst in instalaciones) {
      final sensores = await getSensores(inst['id_instalacion'] as int);
      totalSensores += sensores.length;
    }
    
    final alertas = await getAlertas(0, soloNoResueltas: true);
    
    return {
      'totalInstalaciones': instalaciones.length,
      'totalSensores': totalSensores,
      'alertasActivas': alertas.length,
    };
  }

  Future<void> deleteInstalacion(int idInstalacion) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.apiInstalaciones}/$idInstalacion'),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar instalación');
    }
  }

  Future<void> createInstalacion(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse(AppConfig.apiInstalaciones),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al crear instalación');
    }
  }

  // Alertas
  Future<List<Map<String, dynamic>>> getAlertas(int idInstalacion, {bool soloNoResueltas = false}) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiAlertas}?id_instalacion=$idInstalacion'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<int> countAlertasNoVistas(int idInstalacion) async {
    final alertas = await getAlertas(idInstalacion);
    return alertas.length;
  }

  Future<void> marcarAlertasComoVistas(int idInstalacion) async {
    // No hay campo de "visto" en la BD, no hacer nada
  }

  Future<void> deleteAlerta(int idAlerta) async {
    await http.delete(
      Uri.parse('${AppConfig.apiAlertas}/$idAlerta'),
    );
  }

  Future<void> marcarAlertaVista(int idAlerta) async {
    // No hay campo de "vista" en la BD
  }

  Future<void> marcarAlertaResuelta(int idAlerta) async {
    // No hay campo de "resuelta" en la BD
  }

  Future<void> eliminarAlerta(int idAlerta) async {
    await deleteAlerta(idAlerta);
  }

  // Procesos
  Future<List<Map<String, dynamic>>> getProcesos() async {
    final response = await http.get(Uri.parse(AppConfig.apiProcesos));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> createProceso(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse(AppConfig.apiProcesos),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear proceso');
    }
  }

  Future<void> deleteProceso(int idProceso) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.apiProcesos}/$idProceso'),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar proceso');
    }
  }

  // Especies
  Future<List<Map<String, dynamic>>> getEspecies() async {
    final response = await http.get(Uri.parse(AppConfig.apiEspecies));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> createEspecie(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse(AppConfig.apiEspecies),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear especie');
    }
  }

  Future<void> deleteEspecie(int idEspecie) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.apiEspecies}/$idEspecie'),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar especie');
    }
  }

  // Especie-Parámetro
  Future<List<Map<String, dynamic>>> getEspeciesParametros() async {
    final response = await http.get(Uri.parse('${AppConfig.apiEspecies}/parametros'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> createEspecieParametro(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiEspecies}/parametros'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear relación especie-parámetro');
    }
  }
}
