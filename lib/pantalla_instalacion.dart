// lib/pantalla_instalacion.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/app_header.dart';
import 'pantalla_sensores_gestion.dart';

/// Pantalla de detalle de una instalación
class PantallaInstalacion extends StatefulWidget {
  const PantallaInstalacion({super.key});

  @override
  State<PantallaInstalacion> createState() => _PantallaInstalacionState();
}

class _PantallaInstalacionState extends State<PantallaInstalacion>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final nombre = (args?['nombre_instalacion'] as String?) ?? 'Instalación';
    final online = true;
    final idInstalacion = args?['id_instalacion'] as int?;

    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Ozono'),
            Tab(text: 'Presión'),
            Tab(text: 'Gasto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ResumenTab(online: online, nombre: nombre, now: _now),
          _OzonoTab(online: online, nombre: nombre, now: _now),
          _PresionTab(online: online, nombre: nombre, now: _now),
          _GastoTab(online: online, nombre: nombre, now: _now),
        ],
      ),
      floatingActionButton: idInstalacion != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PantallaSensoresGestion(
                      idInstalacion: idInstalacion,
                      nombreInstalacion: nombre,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.sensors),
              tooltip: 'Gestionar sensores',
            )
          : null,
    );
  }
}

class _ResumenTab extends StatelessWidget {
  final bool online;
  final String nombre;
  final DateTime now;
  const _ResumenTab({required this.online, required this.nombre, required this.now});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppHeader(online: online, titulo: nombre, hora: now),
        const SizedBox(height: 32),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.analytics_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'Datos de sensores',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aquí se mostrarán las lecturas de los sensores instalados',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OzonoTab extends StatelessWidget {
  final bool online;
  final String nombre;
  final DateTime now;
  const _OzonoTab({required this.online, required this.nombre, required this.now});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppHeader(online: online, titulo: nombre, hora: now),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Icon(Icons.bubble_chart_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'Monitoreo de Ozono',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Conectar sensor de ozono para ver datos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PresionTab extends StatelessWidget {
  final bool online;
  final String nombre;
  final DateTime now;
  const _PresionTab({required this.online, required this.nombre, required this.now});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppHeader(online: online, titulo: nombre, hora: now),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Icon(Icons.speed_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'Monitoreo de Presión',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Conectar sensor de presión para ver datos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GastoTab extends StatelessWidget {
  final bool online;
  final String nombre;
  final DateTime now;
  const _GastoTab({required this.online, required this.nombre, required this.now});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppHeader(online: online, titulo: nombre, hora: now),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Icon(Icons.water_drop_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'Monitoreo de Gasto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Conectar sensor de flujo para ver datos',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
