import 'package:flutter/material.dart';

/// Configuración de umbrales para un sensor
class UmbralSensor {
  final int? id;
  final int idSensorInstalado;
  final double? valorMinimo;
  final double? valorMaximo;
  final double? valorOptimo;
  final String? nivelAlerta; // 'info', 'warning', 'critical'
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UmbralSensor({
    this.id,
    required this.idSensorInstalado,
    this.valorMinimo,
    this.valorMaximo,
    this.valorOptimo,
    this.nivelAlerta,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  factory UmbralSensor.fromJson(Map<String, dynamic> json) {
    return UmbralSensor(
      id: json['id_umbral'] ?? json['id'],
      idSensorInstalado: json['id_sensor_instalado'] ?? 0,
      valorMinimo: json['valor_minimo']?.toDouble(),
      valorMaximo: json['valor_maximo']?.toDouble(),
      valorOptimo: json['valor_optimo']?.toDouble(),
      nivelAlerta: json['nivel_alerta'],
      activo: json['activo'] == 1 || json['activo'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id_umbral': id,
        'id_sensor_instalado': idSensorInstalado,
        if (valorMinimo != null) 'valor_minimo': valorMinimo,
        if (valorMaximo != null) 'valor_maximo': valorMaximo,
        if (valorOptimo != null) 'valor_optimo': valorOptimo,
        if (nivelAlerta != null) 'nivel_alerta': nivelAlerta,
        'activo': activo,
      };

  /// Verifica si un valor está dentro del rango aceptable
  bool estaEnRango(double valor) {
    if (valorMinimo != null && valor < valorMinimo!) return false;
    if (valorMaximo != null && valor > valorMaximo!) return false;
    return true;
  }

  /// Calcula el nivel de alerta basado en el valor
  NivelAlerta calcularNivelAlerta(double valor) {
    if (valorMinimo != null && valor < valorMinimo!) {
      return NivelAlerta.critico;
    }
    if (valorMaximo != null && valor > valorMaximo!) {
      return NivelAlerta.critico;
    }
    if (valorOptimo != null) {
      final diferencia = (valor - valorOptimo!).abs();
      final rango = valorMaximo != null && valorMinimo != null
          ? (valorMaximo! - valorMinimo!) * 0.2
          : 1.0;
      if (diferencia < rango) {
        return NivelAlerta.normal;
      } else {
        return NivelAlerta.advertencia;
      }
    }
    return NivelAlerta.normal;
  }
}

/// Registro de alerta generada
class Alerta {
  final int? id;
  final int idSensorInstalado;
  final int? idInstalacion;
  final String? tipoAlerta; // 'umbral_excedido', 'sensor_offline', 'tarea_fallida'
  final String? nivel; // 'info', 'warning', 'critical'
  final String mensaje;
  final double? valorRegistrado;
  final bool leida;
  final bool resuelta;
  final DateTime? fechaGenerada;
  final DateTime? fechaResuelta;
  final Map<String, dynamic>? metadata;

  Alerta({
    this.id,
    required this.idSensorInstalado,
    this.idInstalacion,
    this.tipoAlerta,
    this.nivel,
    required this.mensaje,
    this.valorRegistrado,
    this.leida = false,
    this.resuelta = false,
    this.fechaGenerada,
    this.fechaResuelta,
    this.metadata,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id_alerta'] ?? json['id'],
      idSensorInstalado: json['id_sensor_instalado'] ?? 0,
      idInstalacion: json['id_instalacion'],
      tipoAlerta: json['tipo_alerta'],
      nivel: json['nivel'],
      mensaje: json['mensaje'] ?? '',
      valorRegistrado: json['valor_registrado']?.toDouble(),
      leida: json['leida'] == 1 || json['leida'] == true,
      resuelta: json['resuelta'] == 1 || json['resuelta'] == true,
      fechaGenerada: json['fecha_generada'] != null
          ? DateTime.tryParse(json['fecha_generada'].toString())
          : null,
      fechaResuelta: json['fecha_resuelta'] != null
          ? DateTime.tryParse(json['fecha_resuelta'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id_alerta': id,
        'id_sensor_instalado': idSensorInstalado,
        if (idInstalacion != null) 'id_instalacion': idInstalacion,
        if (tipoAlerta != null) 'tipo_alerta': tipoAlerta,
        if (nivel != null) 'nivel': nivel,
        'mensaje': mensaje,
        if (valorRegistrado != null) 'valor_registrado': valorRegistrado,
        'leida': leida,
        'resuelta': resuelta,
        if (metadata != null) 'metadata': metadata,
      };

  NivelAlerta get nivelAlerta {
    switch (nivel?.toLowerCase()) {
      case 'critical':
      case 'critico':
        return NivelAlerta.critico;
      case 'warning':
      case 'advertencia':
        return NivelAlerta.advertencia;
      case 'info':
        return NivelAlerta.info;
      default:
        return NivelAlerta.normal;
    }
  }

  IconData get icono {
    switch (nivelAlerta) {
      case NivelAlerta.critico:
        return Icons.error;
      case NivelAlerta.advertencia:
        return Icons.warning;
      case NivelAlerta.info:
        return Icons.info;
      case NivelAlerta.normal:
        return Icons.check_circle;
    }
  }

  Color get color {
    switch (nivelAlerta) {
      case NivelAlerta.critico:
        return Colors.red;
      case NivelAlerta.advertencia:
        return Colors.orange;
      case NivelAlerta.info:
        return Colors.blue;
      case NivelAlerta.normal:
        return Colors.green;
    }
  }
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
