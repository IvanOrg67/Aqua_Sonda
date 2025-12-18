// models/sensor.dart
import 'package:flutter/material.dart';

/// CatalogoSensor representa un tipo de sensor del catálogo
class CatalogoSensor {
  final int idSensor;
  final String sensor;
  final String descripcion;
  final String? modelo;
  final String? marca;
  final String? rangoMedicion;
  final String? unidadMedida;

  CatalogoSensor({
    required this.idSensor,
    required this.sensor,
    required this.descripcion,
    this.modelo,
    this.marca,
    this.rangoMedicion,
    this.unidadMedida,
  });

  factory CatalogoSensor.fromJson(Map<String, dynamic> json) {
    return CatalogoSensor(
      idSensor: json['id_sensor'] ?? 0,
      sensor: json['sensor'] ?? '',
      descripcion: json['descripcion'] ?? '',
      modelo: json['modelo'],
      marca: json['marca'],
      rangoMedicion: json['rango_medicion'],
      unidadMedida: json['unidad_medida'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id_sensor': idSensor,
    'sensor': sensor,
    'descripcion': descripcion,
    if (modelo != null) 'modelo': modelo,
    if (marca != null) 'marca': marca,
    if (rangoMedicion != null) 'rango_medicion': rangoMedicion,
    if (unidadMedida != null) 'unidad_medida': unidadMedida,
  };

  // Getters de compatibilidad
  String get nombre => sensor;
  String? get unidad => unidadMedida;

  IconData get icono => Icons.sensors;
  Color get color => Colors.blue;
}

/// SensorInstalado representa una instancia de sensor instalado en una instalación
class SensorInstalado {
  final int idSensorInstalado;
  final int idInstalacion;
  final int idSensor;
  final DateTime fechaInstalada;
  final String descripcion;
  final int? idLectura;
  
  // Datos del catálogo (pueden venir en JOIN)
  final String? nombreSensor;
  final String? unidadMedida;

  SensorInstalado({
    required this.idSensorInstalado,
    required this.idInstalacion,
    required this.idSensor,
    required this.fechaInstalada,
    required this.descripcion,
    this.idLectura,
    this.nombreSensor,
    this.unidadMedida,
  });

  factory SensorInstalado.fromJson(Map<String, dynamic> json) {
    // La BD devuelve fecha_instalada como 'YYYY-MM-DD' (solo fecha)
    DateTime fechaInstalada;
    final fechaStr = json['fecha_instalada'] as String?;
    if (fechaStr != null) {
      if (fechaStr.length == 10) {
        fechaInstalada = DateTime.parse('${fechaStr}T00:00:00');
      } else {
        fechaInstalada = DateTime.parse(fechaStr);
      }
    } else {
      fechaInstalada = DateTime.now();
    }

    return SensorInstalado(
      idSensorInstalado: json['id_sensor_instalado'] ?? 0,
      idInstalacion: json['id_instalacion'] ?? 0,
      idSensor: json['id_sensor'] ?? 0,
      fechaInstalada: fechaInstalada,
      descripcion: json['descripcion'] ?? '',
      idLectura: json['id_lectura'],
      nombreSensor: json['catalogo_sensores']?['sensor'] ?? json['sensor'] ?? json['nombre_sensor'],
      unidadMedida: json['catalogo_sensores']?['unidad_medida'] ?? json['unidad_medida'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id_sensor_instalado': idSensorInstalado,
    'id_instalacion': idInstalacion,
    'id_sensor': idSensor,
    'fecha_instalada': fechaInstalada.toIso8601String().split('T')[0], // Solo fecha YYYY-MM-DD
    'descripcion': descripcion,
    if (idLectura != null) 'id_lectura': idLectura,
  };

  // Getters de compatibilidad
  int get id => idSensorInstalado;
  String? get nombre => nombreSensor ?? descripcion;
  String? get unidad => unidadMedida;
}

/// Sensor simple - alias para compatibilidad
class Sensor {
  final int idSensor;
  final int idInstalacion;
  final String nombre;
  final String? tipo;
  final String? unidadMedida;
  final String? estado;

  Sensor({
    required this.idSensor,
    required this.idInstalacion,
    required this.nombre,
    this.tipo,
    this.unidadMedida,
    this.estado,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      idSensor: json['id_sensor_instalado'] ?? json['id_sensor'] ?? json['id'] ?? 0,
      idInstalacion: json['id_instalacion'] ?? 0,
      nombre: json['sensor'] ?? json['nombre'] ?? json['descripcion'] ?? '',
      tipo: json['tipo'],
      unidadMedida: json['unidad_medida'] ?? json['unidad'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sensor': idSensor,
      'id_instalacion': idInstalacion,
      'nombre': nombre,
      if (tipo != null) 'tipo': tipo,
      if (unidadMedida != null) 'unidad_medida': unidadMedida,
      if (estado != null) 'estado': estado,
    };
  }

  IconData get icono {
    switch (tipo?.toLowerCase()) {
      case 'temperatura':
        return Icons.thermostat;
      case 'ph':
        return Icons.science;
      case 'oxigeno':
        return Icons.air;
      default:
        return Icons.sensors;
    }
  }

  Color get color {
    switch (tipo?.toLowerCase()) {
      case 'temperatura':
        return Colors.orange;
      case 'ph':
        return Colors.purple;
      case 'oxigeno':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  Color get estadoColor {
    switch (estado?.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}
