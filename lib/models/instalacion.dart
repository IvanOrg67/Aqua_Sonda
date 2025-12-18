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
    return Instalacion(
      idInstalacion: json['id_instalacion'] as int,
      idOrganizacionSucursal: json['id_organizacion_sucursal'] as int,
      nombreInstalacion: json['nombre_instalacion'] as String,
      fechaInstalacion: DateTime.parse(json['fecha_instalacion']),
      estadoOperativo: json['estado_operativo'] as String,
      descripcion: json['descripcion'] as String,
      tipoUso: json['tipo_uso'] as String,
      idProceso: json['id_proceso'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_instalacion': idInstalacion,
      'id_organizacion_sucursal': idOrganizacionSucursal,
      'nombre_instalacion': nombreInstalacion,
      'fecha_instalacion': fechaInstalacion.toIso8601String(),
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
