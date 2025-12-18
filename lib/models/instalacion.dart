class Instalacion {
  final int idInstalacion;
  final int idOrganizacionSucursal;
  final String nombreInstalacion;
  final DateTime fechaInstalacion;
  final String estadoOperativo; // 'activo' o 'inactivo'
  final String descripcion;
  final String tipoUso; // 'acuicultura', 'tratamiento', 'otros'
  final int idProceso;

  Instalacion({
    required this.idInstalacion,
    required this.idOrganizacionSucursal,
    required this.nombreInstalacion,
    required this.fechaInstalacion,
    required this.estadoOperativo,
    required this.descripcion,
    required this.tipoUso,
    required this.idProceso,
  });

  factory Instalacion.fromJson(Map<String, dynamic> json) {
    // La BD devuelve fecha_instalacion como 'YYYY-MM-DD' (solo fecha, sin hora)
    DateTime fechaInstalacion;
    final fechaStr = json['fecha_instalacion'] as String?;
    if (fechaStr != null) {
      // Si viene solo la fecha (YYYY-MM-DD), agregar hora 00:00:00
      if (fechaStr.length == 10) {
        fechaInstalacion = DateTime.parse('${fechaStr}T00:00:00');
      } else {
        fechaInstalacion = DateTime.parse(fechaStr);
      }
    } else {
      fechaInstalacion = DateTime.now();
    }

    return Instalacion(
      idInstalacion: json['id_instalacion'] as int,
      idOrganizacionSucursal: json['id_organizacion_sucursal'] as int,
      nombreInstalacion: json['nombre_instalacion'] as String,
      fechaInstalacion: fechaInstalacion,
      estadoOperativo: json['estado_operativo'] as String,
      descripcion: json['descripcion'] as String,
      tipoUso: json['tipo_uso'] as String,
      idProceso: json['id_proceso'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    // La BD espera solo la fecha en formato YYYY-MM-DD (sin hora)
    return {
      'id_instalacion': idInstalacion,
      'id_organizacion_sucursal': idOrganizacionSucursal,
      'nombre_instalacion': nombreInstalacion,
      'fecha_instalacion': fechaInstalacion.toIso8601String().split('T')[0], // Solo fecha
      'estado_operativo': estadoOperativo,
      'descripcion': descripcion,
      'tipo_uso': tipoUso,
      'id_proceso': idProceso,
    };
  }

  // Getters de compatibilidad
  String get nombre => nombreInstalacion;
  bool get estaActivo => estadoOperativo == 'activo';
  String get estado => estadoOperativo; // Compatibilidad con código existente
}
