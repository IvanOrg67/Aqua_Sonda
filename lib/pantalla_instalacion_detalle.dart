// lib/pantalla_instalacion_detalle.dart
import 'package:flutter/material.dart';
import 'pantalla_instalacion.dart';

/// Wrapper de compatibilidad:
/// - Si en algún lugar se navega a '/instalacion_detalle' o se usa
///   PantallaInstalacionDetalle, se renderiza PantallaInstalacion.
/// - Los argumentos de la ruta se mantienen tal cual para que
///   PantallaInstalacion pueda leerlos con ModalRoute.of(context).
class PantallaInstalacionDetalle extends StatelessWidget {
  const PantallaInstalacionDetalle({super.key});

  @override
  Widget build(BuildContext context) {
    // Los argumentos permanecen en la misma ruta; PantallaInstalacion
    // podrá leerlos con ModalRoute.of(context)?.settings.arguments.
    return PantallaInstalacion(); // intencionalmente sin 'const'
  }
}
