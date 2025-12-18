class Especie {
  final int idEspecie;
  final String nombre;

  Especie({
    required this.idEspecie,
    required this.nombre,
  });

  factory Especie.fromJson(Map<String, dynamic> json) {
    return Especie(
      idEspecie: json['id_especie'] as int,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_especie': idEspecie,
      'nombre': nombre,
    };
  }
}

class EspecieParametro {
  final int idEspecieParametro;
  final int idEspecie;
  final int idParametro;
  final double rmax;
  final double rmin;
  final String? nombreEspecie;
  final String? nombreParametro;
  final String? unidadMedida;

  EspecieParametro({
    required this.idEspecieParametro,
    required this.idEspecie,
    required this.idParametro,
    required this.rmax,
    required this.rmin,
    this.nombreEspecie,
    this.nombreParametro,
    this.unidadMedida,
  });

  factory EspecieParametro.fromJson(Map<String, dynamic> json) {
    return EspecieParametro(
      idEspecieParametro: json['id_especie_parametro'] as int,
      idEspecie: json['id_especie'] as int,
      idParametro: json['id_parametro'] as int,
      rmax: (json['Rmax'] as num).toDouble(),
      rmin: (json['Rmin'] as num).toDouble(),
      nombreEspecie: json['especies']?['nombre'] ?? json['nombre_especie'],
      nombreParametro: json['parametros']?['nombre_parametro'] ?? json['nombre_parametro'],
      unidadMedida: json['parametros']?['unidad_medida'] ?? json['unidad_medida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_especie_parametro': idEspecieParametro,
      'id_especie': idEspecie,
      'id_parametro': idParametro,
      'Rmax': rmax,
      'Rmin': rmin,
    };
  }
}

