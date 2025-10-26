class TareaProgramada {
  final int id;
  final int idInstalacion;
  final String nombre;
  final String tipo; // 'horario', 'condicion', etc.
  final String? horaInicio; // 'HH:mm', si aplica
  final String? horaFin; // 'HH:mm', si aplica
  final double? oxigenoMin;
  final double? oxigenoMax;
  final int? duracionMinutos; // duración de la acción
  final String accion; // 'activar_aerador', 'desactivar_aerador', etc.
  final bool activo;

  TareaProgramada({
    required this.id,
    required this.idInstalacion,
    required this.nombre,
    required this.tipo,
    this.horaInicio,
    this.horaFin,
    this.oxigenoMin,
    this.oxigenoMax,
    this.duracionMinutos,
    required this.accion,
    required this.activo,
  });

  factory TareaProgramada.fromJson(Map<String, dynamic> j) => TareaProgramada(
        id: j['id'] ?? j['id_tarea'],
        idInstalacion: j['id_instalacion'],
        nombre: j['nombre'] ?? '',
        tipo: j['tipo'] ?? 'horario',
        horaInicio: j['hora_inicio'],
        horaFin: j['hora_fin'],
        oxigenoMin: (j['oxigeno_min'] as num?)?.toDouble(),
        oxigenoMax: (j['oxigeno_max'] as num?)?.toDouble(),
        duracionMinutos: j['duracion_minutos'],
        accion: j['accion'] ?? 'activar_aerador',
        activo: j['activo'] == true || j['activo'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_instalacion': idInstalacion,
        'nombre': nombre,
        'tipo': tipo,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'oxigeno_min': oxigenoMin,
        'oxigeno_max': oxigenoMax,
        'duracion_minutos': duracionMinutos,
        'accion': accion,
        'activo': activo ? 1 : 0,
      };
}
