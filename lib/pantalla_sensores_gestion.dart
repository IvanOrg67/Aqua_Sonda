import 'package:flutter/material.dart';
import 'models/sensor.dart';
import 'services/api_sensores_service.dart';

/// Pantalla completa para gestionar sensores de una instalación
class PantallaSensoresGestion extends StatefulWidget {
  final int idInstalacion;
  final String nombreInstalacion;

  const PantallaSensoresGestion({
    super.key,
    required this.idInstalacion,
    required this.nombreInstalacion,
  });

  @override
  State<PantallaSensoresGestion> createState() => _PantallaSensoresGestionState();
}

class _PantallaSensoresGestionState extends State<PantallaSensoresGestion> {
  final _api = ApiSensoresService();
  late Future<List<SensorInstalado>> _future;

  @override
  void initState() {
    super.initState();
    _cargarSensores();
  }

  void _cargarSensores() {
    setState(() {
      _future = _api.getByInstalacion(widget.idInstalacion);
    });
  }

  Future<void> _mostrarDialogoAgregarSensor() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _DialogoAgregarSensor(
        idInstalacion: widget.idInstalacion,
        onSensorAgregado: _cargarSensores,
      ),
    );
  }

  Future<void> _confirmarEliminar(SensorInstalado sensor) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar sensor'),
        content: Text('¿Eliminar "${sensor.nombre ?? 'Sensor'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await _api.desinstalarSensor(sensor.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sensor eliminado')),
        );
        _cargarSensores();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sensores'),
            Text(
              widget.nombreInstalacion,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<SensorInstalado>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error al cargar sensores', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(snap.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _cargarSensores,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final sensores = snap.data ?? [];

          if (sensores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors_off, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Sin sensores instalados',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primer sensor para comenzar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _mostrarDialogoAgregarSensor,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar sensor'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _cargarSensores(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sensores.length,
              itemBuilder: (context, index) {
                final sensor = sensores[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SensorCard(
                    sensor: sensor,
                    onTap: () {
                      // TODO: Navegar a detalle del sensor con gráficos
                    },
                    onDelete: () => _confirmarEliminar(sensor),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoAgregarSensor,
        icon: const Icon(Icons.add),
        label: const Text('Agregar sensor'),
      ),
    );
  }
}

/// Card individual para cada sensor
class _SensorCard extends StatelessWidget {
  final SensorInstalado sensor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SensorCard({
    required this.sensor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono del sensor
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: sensor.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(sensor.icono, color: sensor.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  
                  // Nombre y tipo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.nombre ?? 'Sensor sin nombre',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sensor.parametro ?? sensor.tipo ?? 'Sin tipo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: sensor.estadoColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: sensor.estadoColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sensor.estado ?? 'Inactivo',
                          style: TextStyle(
                            color: sensor.estadoColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón eliminar
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: onDelete,
                    tooltip: 'Eliminar sensor',
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Valor actual y última lectura
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor actual',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sensor.valor != null
                            ? '${sensor.valor!.toStringAsFixed(1)} ${sensor.unidad ?? ''}'
                            : 'Sin datos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: sensor.color,
                        ),
                      ),
                    ],
                  ),
                  if (sensor.ultimaLectura != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Última lectura',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sensor.ultimaLectura!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo para agregar un nuevo sensor
class _DialogoAgregarSensor extends StatefulWidget {
  final int idInstalacion;
  final VoidCallback onSensorAgregado;

  const _DialogoAgregarSensor({
    required this.idInstalacion,
    required this.onSensorAgregado,
  });

  @override
  State<_DialogoAgregarSensor> createState() => _DialogoAgregarSensorState();
}

class _DialogoAgregarSensorState extends State<_DialogoAgregarSensor> {
  final _api = ApiSensoresService();
  final _formKey = GlobalKey<FormState>();
  final _aliasCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  String? _tipoSeleccionado;
  bool _loading = false;
  String? _error;

  // Tipos de sensores disponibles para acuicultura
  final List<Map<String, dynamic>> _tiposSensores = [
    {
      'id': 'ph',
      'nombre': 'pH',
      'descripcion': 'Acidez/Alcalinidad del agua',
      'icono': Icons.science,
      'color': Colors.purple,
      'unidad': 'pH',
      'rango': '0-14',
    },
    {
      'id': 'oxigeno_disuelto',
      'nombre': 'Oxígeno Disuelto',
      'descripcion': 'Concentración de O₂ en el agua',
      'icono': Icons.air,
      'color': Colors.blue,
      'unidad': 'mg/L',
      'rango': '0-20',
    },
    {
      'id': 'temperatura',
      'nombre': 'Temperatura',
      'descripcion': 'Temperatura del agua',
      'icono': Icons.thermostat,
      'color': Colors.orange,
      'unidad': '°C',
      'rango': '0-50',
    },
    {
      'id': 'conductividad',
      'nombre': 'Conductividad',
      'descripcion': 'Conductividad eléctrica',
      'icono': Icons.electrical_services,
      'color': Colors.amber,
      'unidad': 'µS/cm',
      'rango': '0-2000',
    },
    {
      'id': 'turbidez',
      'nombre': 'Turbidez',
      'descripcion': 'Claridad del agua',
      'icono': Icons.visibility,
      'color': Colors.grey,
      'unidad': 'NTU',
      'rango': '0-100',
    },
    {
      'id': 'amonio',
      'nombre': 'Amonio (NH₄⁺)',
      'descripcion': 'Concentración de amonio',
      'icono': Icons.water_damage,
      'color': Colors.green,
      'unidad': 'mg/L',
      'rango': '0-10',
    },
    {
      'id': 'nitritos',
      'nombre': 'Nitritos (NO₂⁻)',
      'descripcion': 'Concentración de nitritos',
      'icono': Icons.bubble_chart,
      'color': Colors.teal,
      'unidad': 'mg/L',
      'rango': '0-5',
    },
    {
      'id': 'nitratos',
      'nombre': 'Nitratos (NO₃⁻)',
      'descripcion': 'Concentración de nitratos',
      'icono': Icons.water_drop,
      'color': Colors.cyan,
      'unidad': 'mg/L',
      'rango': '0-100',
    },
  ];

  Future<void> _agregarSensor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoSeleccionado == null) {
      setState(() => _error = 'Selecciona un tipo de sensor');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Por ahora usamos un ID fijo, pero idealmente deberías tener un catálogo en el backend
      // TODO: Primero crear/obtener el sensor del catálogo, luego instalarlo
      await _api.instalarSensor(
        idInstalacion: widget.idInstalacion,
        idSensor: 1, // ID temporal - debería venir del catálogo
        alias: _aliasCtrl.text.trim().isEmpty ? null : _aliasCtrl.text.trim(),
        descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSensorAgregado();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sensor agregado correctamente')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 8, 16),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Agregar nuevo sensor',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),
              
              // Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Tipo de sensor
                      Text(
                        'Selecciona el tipo de sensor',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      ..._tiposSensores.map((tipo) {
                        final seleccionado = _tipoSeleccionado == tipo['id'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => setState(() => _tipoSeleccionado = tipo['id']),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: seleccionado
                                    ? (tipo['color'] as Color).withOpacity(0.1)
                                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: seleccionado
                                      ? (tipo['color'] as Color)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: (tipo['color'] as Color).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      tipo['icono'] as IconData,
                                      color: tipo['color'] as Color,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tipo['nombre'],
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          tipo['descripcion'],
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        tipo['unidad'],
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: tipo['color'] as Color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        tipo['rango'],
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),
                      
                      // Nombre personalizado
                      TextFormField(
                        controller: _aliasCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre del sensor (opcional)',
                          hintText: 'Ej: Sensor pH - Estanque Norte',
                          prefixIcon: const Icon(Icons.label_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      
                      // Descripción
                      TextFormField(
                        controller: _descCtrl,
                        decoration: InputDecoration(
                          labelText: 'Descripción (opcional)',
                          hintText: 'Ubicación o notas adicionales',
                          prefixIcon: const Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: theme.colorScheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      
                      // Botón agregar
                      FilledButton(
                        onPressed: _loading ? null : _agregarSensor,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Agregar sensor'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
