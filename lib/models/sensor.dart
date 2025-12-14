// models/sensor.dart
import 'package:flutter/material.dart';

class CatalogoSensor {
  final int idSensor;
  final String nombre;
  final String? unidad;
  final String? tipoMedida;
  final double? rangoMin;
  final double? rangoMax;

  CatalogoSensor({
    required this.idSensor,
    required this.nombre,
    this.unidad,
    this.tipoMedida,
    this.rangoMin,
    this.rangoMax,
  });

  factory CatalogoSensor.fromJson(Map<String, dynamic> json) {
    return CatalogoSensor(
      idSensor: json['id_sensor'] ?? 0,
      nombre: json['nombre'] ?? '',
      unidad: json['unidad'],
      tipoMedida: json['tipo_medida'],
      rangoMin: json['rango_min']?.toDouble(),
      rangoMax: json['rango_max']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id_sensor': idSensor,
    'nombre': nombre,
    'unidad': unidad,
    'tipo_medida': tipoMedida,
    'rango_min': rangoMin,
    'rango_max': rangoMax,
  };

  // Helper para iconos por tipo
  IconData get icono {
    switch (tipoMedida?.toLowerCase()) {
      case 'temperatura':
        return Icons.thermostat;
      case 'ph':
        return Icons.science;
      case 'oxigeno_disuelto':
      case 'oxigeno':
        return Icons.air;
      case 'conductividad':
        return Icons.electrical_services;
      case 'turbidez':
        return Icons.visibility;
      case 'salinidad':
        return Icons.water_drop;
      case 'presion':
        return Icons.compress;
      default:
        return Icons.sensors;
    }
  }

  // Helper para colores por tipo
  Color get color {
    switch (tipoMedida?.toLowerCase()) {
      case 'temperatura':
        return Colors.orange;
      case 'ph':
        return Colors.purple;
      case 'oxigeno_disuelto':
      case 'oxigeno':
        return Colors.blue;
      case 'conductividad':
        return Colors.yellow.shade700;
      case 'turbidez':
        return Colors.grey;
      case 'salinidad':
        return Colors.cyan;
      case 'presion':
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}

class SensorInstalado {
  final int id;
  final String? nombre;
  final String? tipo;
  final String? parametro;
  final String? unidad;
  final String? estado;
  final String? ultimaLectura;
  final DateTime? fechaInstalacion;
  final double? valor;

  SensorInstalado({
    required this.id,
    this.nombre,
    this.tipo,
    this.parametro,
    this.unidad,
    this.estado,
    this.ultimaLectura,
    this.fechaInstalacion,
    this.valor,
  });

  factory SensorInstalado.fromJson(Map<String, dynamic> j) => SensorInstalado(
        id: j['id_sensor_instalado'] ?? j['id'] ?? 0,
        nombre: j['nombre_sensor'] ?? j['alias'] ?? j['nombre'],
        tipo: j['tipo_sensor'] ?? j['tipo'],
        parametro: j['parametro'],
        unidad: j['unidad'],
        estado: j['estado'],
        ultimaLectura: j['ultima_lectura'],
        fechaInstalacion: j['fecha_instalacion'] != null
            ? DateTime.tryParse(j['fecha_instalacion'].toString())
            : null,
        valor: j['valor']?.toDouble(),
      );

  // Helper para iconos por tipo de sensor
  IconData get icono {
    switch (parametro?.toLowerCase()) {
      case 'temperatura':
        return Icons.thermostat;
      case 'ph':
        return Icons.science;
      case 'oxigeno_disuelto':
      case 'oxigeno':
        return Icons.air;
      case 'conductividad':
        return Icons.electrical_services;
      case 'turbidez':
        return Icons.visibility;
      case 'salinidad':
        return Icons.water_drop;
      case 'presion':
        return Icons.compress;
      default:
        return Icons.sensors;
    }
  }

  // Helper para colores por tipo
  Color get color {
    switch (parametro?.toLowerCase()) {
      case 'temperatura':
        return Colors.orange;
      case 'ph':
        return Colors.purple;
      case 'oxigeno_disuelto':
      case 'oxigeno':
        return Colors.blue;
      case 'conductividad':
        return Colors.yellow.shade700;
      case 'turbidez':
        return Colors.grey;
      case 'salinidad':
        return Colors.cyan;
      case 'presion':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // Estado con colores
  Color get estadoColor {
    switch (estado?.toLowerCase()) {
      case 'activo':
      case 'online':
        return Colors.green;
      case 'inactivo':
      case 'offline':
        return Colors.red;
      case 'mantenimiento':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  bool get estaActivo => estado?.toLowerCase() == 'activo' || estado?.toLowerCase() == 'online';
}
