import 'package:flutter/material.dart';

/// Registro de alerta generada
class Alerta {
  final int? id;
  final int idInstalacion;
  final int idSensorInstalado;
  final String descripcion;
  final double datoPuntual;

  Alerta({
    this.id,
    required this.idInstalacion,
    required this.idSensorInstalado,
    required this.descripcion,
    required this.datoPuntual,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id_alertas'] ?? json['id'],
      idInstalacion: json['id_instalacion'] ?? 0,
      idSensorInstalado: json['id_sensor_instalado'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      datoPuntual: (json['dato_puntual'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id_alertas': id,
        'id_instalacion': idInstalacion,
        'id_sensor_instalado': idSensorInstalado,
        'descripcion': descripcion,
        'dato_puntual': datoPuntual,
      };
}

/// Enum para niveles de alerta
enum NivelAlerta {
  normal,
  info,
  advertencia,
  critico;

  String get nombre {
    switch (this) {
      case NivelAlerta.normal:
        return 'Normal';
      case NivelAlerta.info:
        return 'Información';
      case NivelAlerta.advertencia:
        return 'Advertencia';
      case NivelAlerta.critico:
        return 'Crítico';
    }
  }

  Color get color {
    switch (this) {
      case NivelAlerta.normal:
        return Colors.green;
      case NivelAlerta.info:
        return Colors.blue;
      case NivelAlerta.advertencia:
        return Colors.orange;
      case NivelAlerta.critico:
        return Colors.red;
    }
  }

  IconData get icono {
    switch (this) {
      case NivelAlerta.normal:
        return Icons.check_circle;
      case NivelAlerta.info:
        return Icons.info;
      case NivelAlerta.advertencia:
        return Icons.warning;
      case NivelAlerta.critico:
        return Icons.error;
    }
  }
}
