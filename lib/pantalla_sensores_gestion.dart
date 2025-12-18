import 'package:flutter/material.dart';
import 'models/sensor.dart';
import 'services/api_service.dart';
import 'pantalla_lecturas_sensor.dart';

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
  final _api = ApiService();
  
  late Future<List<Sensor>> _future;

  @override
  void initState() {
    super.initState();
    _cargarSensores();
  }

  void _cargarSensores() {
    setState(() {
      _future = _api.getSensores(widget.idInstalacion).then((data) {
        return data.map((item) {
          // Convertir SensorInstalado a Sensor para compatibilidad
          return Sensor.fromJson({
            'id_sensor_instalado': item['id_sensor_instalado'],
            'id_instalacion': item['id_instalacion'],
            'sensor': item['catalogo_sensores']?['sensor'] ?? item['descripcion'] ?? 'Sensor',
            'tipo': item['catalogo_sensores']?['sensor'],
            'unidad_medida': item['catalogo_sensores']?['unidad_medida'],
          });
        }).toList();
      });
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

  Future<void> _confirmarEliminar(Sensor sensor) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar sensor'),
        content: Text('¿Eliminar "${sensor.nombre}"?'),
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
        await _api.deleteSensor(sensor.idSensor);
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
      body: FutureBuilder<List<Sensor>>(
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => PantallaLecturasSensor(
                            idSensor: sensor.idSensor,
                            nombreSensor: sensor.nombre,
                          ),
                        ),
                      );
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
  final Sensor sensor;
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
                          sensor.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sensor.tipo ?? 'Sin tipo',
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
              const SizedBox(height: 8),
              
              // Unidad de medida si existe
              if (sensor.unidadMedida != null)
                Text(
                  'Unidad: ${sensor.unidadMedida}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
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
  final _api = ApiService();
  
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  
  int? _sensorCatalogoId;
  List<Map<String, dynamic>> _catalogoSensores = [];
  bool _loading = false;
  bool _cargandoCatalogo = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    try {
      final sensores = await _api.getCatalogoSensores();
      setState(() {
        _catalogoSensores = sensores;
        _cargandoCatalogo = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar catálogo: $e';
        _cargandoCatalogo = false;
      });
    }
  }


  Future<void> _agregarSensor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sensorCatalogoId == null) {
      setState(() => _error = 'Selecciona un sensor del catálogo');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.createSensor(
        idSensor: _sensorCatalogoId!,
        idInstalacion: widget.idInstalacion,
        descripcion: _descCtrl.text.trim().isEmpty 
            ? 'Sensor instalado' 
            : _descCtrl.text.trim(),
        fechaInstalada: DateTime.now(),
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
                      // Catálogo de sensores
                      Text(
                        'Selecciona un sensor del catálogo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (_cargandoCatalogo)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_catalogoSensores.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber, color: theme.colorScheme.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No hay sensores disponibles en el catálogo. Contacta al administrador.',
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._catalogoSensores.map((sensor) {
                          final seleccionado = _sensorCatalogoId == sensor['id_sensor'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => setState(() => _sensorCatalogoId = sensor['id_sensor']),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: seleccionado
                                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: seleccionado
                                        ? theme.colorScheme.primary
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
                                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.sensors,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sensor['sensor'] ?? 'Sensor',
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            sensor['descripcion'] ?? '',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (sensor['unidad_medida'] != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            sensor['unidad_medida'],
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (sensor['rango_medicion'] != null)
                                            Text(
                                              sensor['rango_medicion'],
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
                      
                      // Descripción
                      TextFormField(
                        controller: _descCtrl,
                        decoration: InputDecoration(
                          labelText: 'Descripción del sensor instalado',
                          hintText: 'Ej: Sensor principal de temperatura - Estanque Norte',
                          prefixIcon: const Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
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
