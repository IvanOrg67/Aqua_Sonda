class Proceso {
  final int idProceso;
  final int idEspecie;
  final DateTime fechaInicio;
  final DateTime fechaFinal;
  final String? nombreEspecie; // Desde JOIN

  Proceso({
    required this.idProceso,
    required this.idEspecie,
    required this.fechaInicio,
    required this.fechaFinal,
    this.nombreEspecie,
  });

  factory Proceso.fromJson(Map<String, dynamic> json) {
    // La BD devuelve fechas como 'YYYY-MM-DD' (solo fecha, sin hora)
    DateTime parseFecha(String? fechaStr) {
      if (fechaStr == null) return DateTime.now();
      if (fechaStr.length == 10) {
        return DateTime.parse('${fechaStr}T00:00:00');
      }
      return DateTime.parse(fechaStr);
    }

    return Proceso(
      idProceso: json['id_proceso'] as int,
      idEspecie: json['id_especie'] as int,
      fechaInicio: parseFecha(json['fecha_inicio'] as String?),
      fechaFinal: parseFecha(json['fecha_final'] as String?),
      nombreEspecie: json['especies']?['nombre'] ?? json['nombre_especie'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_proceso': idProceso,
      'id_especie': idEspecie,
      'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
      'fecha_final': fechaFinal.toIso8601String().split('T')[0],
    };
  }

  int get duracionDias => fechaFinal.difference(fechaInicio).inDays;
  bool get estaActivo => DateTime.now().isAfter(fechaInicio) && DateTime.now().isBefore(fechaFinal);
  bool get estaFinalizado => DateTime.now().isAfter(fechaFinal);
}

