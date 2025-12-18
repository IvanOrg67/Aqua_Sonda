class Lectura {
  final int? idLectura;
  final int idSensorInstalado; // Corregido: la BD usa id_sensor_instalado
  final double valor;
  final DateTime fechaLectura;
  final String? unidad;

  Lectura({
    this.idLectura,
    required this.idSensorInstalado,
    required this.valor,
    required this.fechaLectura,
    this.unidad,
  });

  factory Lectura.fromJson(Map<String, dynamic> json) {
    // El backend devuelve: tomada_en (ISO), fecha (YYYY-MM-DD), hora (HH:MM:SS)
    DateTime fechaLectura;
    if (json['tomada_en'] != null) {
      fechaLectura = DateTime.parse(json['tomada_en']);
    } else if (json['fecha'] != null && json['hora'] != null) {
      // Combinar fecha y hora si vienen separados
      fechaLectura = DateTime.parse('${json['fecha']}T${json['hora']}');
    } else if (json['fecha_lectura'] != null) {
      fechaLectura = DateTime.parse(json['fecha_lectura']);
    } else {
      fechaLectura = DateTime.now();
    }

    return Lectura(
      idLectura: json['id_lectura'] as int?,
      idSensorInstalado: json['id_sensor_instalado'] as int? ?? json['id_sensor'] as int? ?? 0,
      valor: (json['valor'] as num).toDouble(),
      fechaLectura: fechaLectura,
      unidad: json['unidad_medida'] ?? json['unidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idLectura != null) 'id_lectura': idLectura,
      'id_sensor_instalado': idSensorInstalado,
      'valor': valor,
      'fecha_lectura': fechaLectura.toIso8601String(),
      if (unidad != null) 'unidad_medida': unidad,
    };
  }

  // Getter de compatibilidad
  int get idSensor => idSensorInstalado;
}
