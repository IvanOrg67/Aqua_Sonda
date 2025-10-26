import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

import 'pantalla_login.dart';
import 'pantalla_sesion.dart';
import 'pantalla_registro.dart';
import 'pantalla_home.dart';

// DA ALIAS A CADA LIBRERÍA PARA EVITAR CHOQUES DE NOMBRES
import 'pantalla_instalacion.dart' as det; // detalle (singular)
import 'pantalla_instalaciones.dart' as lista; // listado (plural)
import 'pantalla_instalacion_detalle.dart'; // wrapper opcional

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AquaSense',
          theme: buildAppTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const PantallaLogin(),
            '/login': (context) => const PantallaLogin(),
            '/sesion': (context) => const PantallaSesion(),
            '/registro': (context) => const PantallaRegistro(),
            '/home': (context) => const PantallaHome(),

            // usa el alias 'lista' para la pantalla de LISTADO
            '/instalaciones': (context) => const lista.PantallaInstalaciones(),

            // usa el alias 'det' para la pantalla de DETALLE (sin const)
            '/instalacion': (context) => det.PantallaInstalacion(),

            // Wrapper opcional
            '/instalacion_detalle': (context) => const PantallaInstalacionDetalle(),
          },
        );
      },
    );
  }
}
