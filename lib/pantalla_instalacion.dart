// lib/pantalla_instalacion.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/app_header.dart';
import 'widgets/metric_tile.dart';
import 'widgets/needle_gauge.dart';
import 'widgets/thermometer.dart';
import 'widgets/gauge.dart';
import 'widgets/water_tank.dart';
import 'widgets/mini_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'pantalla_tareas.dart';
import 'pantalla_sensores_gestion.dart';

/// Pantalla de detalle de una instalación con vistas que imitan tus mockups.
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
    final nombre = (args?['nombre_instalacion'] as String?) ?? 'DEPURADORA 1';
    final online = ((args?['estado_operativo'] ?? 'activo') == 'activo');
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
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'sensores_fab',
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
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'tareas_fab',
                  icon: const Icon(Icons.schedule),
                  label: const Text('Tareas'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PantallaTareas(idInstalacion: idInstalacion),
                      ),
                    );
                  },
                ),
              ],
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
        const SizedBox(height: 16),

        // Métricas como en los tres primeros mockups
        MetricTile(
          leading: Icon(Icons.inventory_2, size: 34, color: Theme.of(context).colorScheme.onSurface),
          primary: '50 Kgs Ostion',
          secondary: 'Totem 1',
        ),
        MetricTile(
          leading: Icon(Icons.inventory_2_outlined, size: 34, color: Theme.of(context).colorScheme.onSurface),
          primary: '34 Kgs Ostion',
          secondary: 'Totem 2',
        ),
        MetricTile(
          leading: Icon(Icons.thermostat, size: 34, color: Theme.of(context).colorScheme.onSurface),
          primary: '20°C',
          secondary: 'Temperatura actual',
        ),
        MetricTile(
          leading: Icon(Icons.filter_alt, size: 34, color: Theme.of(context).colorScheme.onSurface),
          primary: '37 psi',
          secondary: 'Filtro 1 Cartucho',
        ),
        MetricTile(
          leading: Icon(Icons.filter_alt_outlined, size: 34, color: Theme.of(context).colorScheme.onSurface),
          primary: '2 psi',
          valueColor: Colors.redAccent,
          secondary: 'Filtro 2 Mecánico',
        ),
        MetricTile(
          leading: Icon(Icons.water, size: 34, color: Theme.of(context).colorScheme.onSurface),
          primary: '8 psi',
          secondary: 'Reservorio',
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
    final series = List.generate(20, (i) => FlSpot(i.toDouble(), [0,1,0,1,0,1][i%6].toDouble()));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppHeader(online: online, titulo: nombre, hora: now),
        const SizedBox(height: 12),
        const Center(child: NeedleGauge(value: 0.78, label: 'Rango de operación Ozono')),
        const SizedBox(height: 12),
        const Text('Concentración / Operación', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        MiniLineChart(series: series),
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
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Thermometer(value: 0.5, label: 'Totem 1'),
            Thermometer(value: 0.35, label: 'UV'),
            Thermometer(value: 0.6, label: 'Totem 2'),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Dial(label: 'Filtro'),
            _Dial(label: 'Descarga'),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Presiones', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Dial extends StatelessWidget {
  final String label;
  const _Dial({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gauge(value: 0.55, centerText: '80'),
        const SizedBox(height: 6),
        Text(label),
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
        const SizedBox(height: 12),
        const Center(child: NeedleGauge(value: 0.52, label: 'Presión')),
        const SizedBox(height: 8),
        const Text('Presión', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        const Center(child: WaterTank(value: 0.66, caption: '20 ltrs')),
        const SizedBox(height: 6),
        const Text('Gasto', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
