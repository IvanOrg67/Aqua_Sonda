import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/neumorphic.dart';
import 'widgets/gauge.dart';

class PantallaParametroDetalle extends StatefulWidget {
  const PantallaParametroDetalle({super.key});

  @override
  State<PantallaParametroDetalle> createState() =>
      _PantallaParametroDetalleState();
}

class _PantallaParametroDetalleState extends State<PantallaParametroDetalle> {
  late String _nombre;
  late String _unidad;
  late double _valor; // valor actual
  late int _sensorId;

  // Rango objetivo (editable por el usuario)
  late RangeValues _rango;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    _nombre = (args?['nombre'] ?? 'Temperatura') as String;
    _unidad = (args?['unidad'] ?? '°C') as String;
    _valor = (args?['valor'] ?? 27.0).toDouble();
    _sensorId = int.tryParse('${args?['sensorId'] ?? 0}') ?? 0;

    // rango sugerido (si no viene, definimos uno razonable)
    final rmin = (args?['min'] ?? 20.0).toDouble();
    final rmax = (args?['max'] ?? 30.0).toDouble();
    _rango = RangeValues(rmin, rmax);
  }

  @override
  Widget build(BuildContext context) {
    final progreso = _progresoNormalizado(
        _valor, 0, _unidad == '°C' ? 50 : 100); // normaliza para el gauge

    return Scaffold(
      appBar: AppBar(
        title: Text("$_nombre • Sensor $_sensorId"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta principal con gauge + valor
          NeumorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_nombre,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Gauge(
                    value: progreso,
                    centerText: "${_valor.toStringAsFixed(1)} $_unidad",
                    size: 220),
                const SizedBox(height: 12),

                // Chips rápidos (ejemplo de presets)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _chipPreset("Bajo", onTap: () => _setPreset(22, 26)),
                    _chipPreset("Normal", onTap: () => _setPreset(24, 28)),
                    _chipPreset("Alto", onTap: () => _setPreset(26, 30)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Rango objetivo
          NeumorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rango objetivo",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _miniBadge(
                        "Mín", "${_rango.start.toStringAsFixed(1)} $_unidad"),
                    _miniBadge(
                        "Máx", "${_rango.end.toStringAsFixed(1)} $_unidad"),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    inactiveTrackColor: AppColors.border,
                    activeTrackColor: AppColors.primary,
                    thumbColor: AppColors.primary,
                    rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 10),
                  ),
                  child: RangeSlider(
                    values: _rango,
                    min: _unidad == '°C' ? 0 : 0,
                    max: _unidad == '°C' ? 50 : 100,
                    divisions: _unidad == '°C' ? 50 : 100,
                    labels: RangeLabels(
                      _rango.start.toStringAsFixed(1),
                      _rango.end.toStringAsFixed(1),
                    ),
                    onChanged: (v) => setState(() => _rango = v),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Acciones
          Row(
            children: [
              Expanded(
                child: NeumorphicButton(
                  onPressed: _guardarRango,
                  child: const Text("Guardar rango"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeumorphicButton(
                  onPressed: () {
                    // aquí podrías abrir una pantalla de historial del parámetro
                  },
                  child: const Text("Ver historial"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _setPreset(double min, double max) {
    setState(() => _rango = RangeValues(min, max));
  }

  double _progresoNormalizado(double v, double min, double max) {
    final clamped = v.clamp(min, max);
    final range = (max - min);
    if (range <= 0) return 0;
    return (clamped - min) / range;
  }

  Widget _miniBadge(String label, String value) {
    return Container(
      decoration: Neu.convex(radius: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label: ",
              style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _chipPreset(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: Neu.convex(radius: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(text),
      ),
    );
  }

  void _guardarRango() {
    // Aquí podrías llamar a tu backend para guardar el rango objetivo del parámetro/sensor
    // Ej: await ApiParametrosService.setRango(sensorId: _sensorId, min: _rango.start, max: _rango.end);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              "Rango guardado: ${_rango.start.toStringAsFixed(1)}–${_rango.end.toStringAsFixed(1)} $_unidad")),
    );
  }
}
