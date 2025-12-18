import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/proceso.dart';
import 'services/api_service.dart';

class PantallaProcesos extends StatefulWidget {
  const PantallaProcesos({super.key});

  @override
  State<PantallaProcesos> createState() => _PantallaProcesosState();
}

class _PantallaProcesosState extends State<PantallaProcesos> {
  final _api = ApiService();
  late Future<List<Proceso>> _future;

  @override
  void initState() {
    super.initState();
    _cargarProcesos();
  }

  void _cargarProcesos() {
    setState(() {
      _future = _api.getProcesos().then((data) {
        return data.map((item) => Proceso.fromJson(item)).toList();
      });
    });
  }

  Future<void> _mostrarDialogoAgregar() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _DialogoAgregarProceso(
        onProcesoAgregado: _cargarProcesos,
      ),
    );
  }

  Future<void> _confirmarEliminar(Proceso proceso) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar proceso'),
        content: Text('¿Eliminar proceso de ${proceso.nombreEspecie ?? "especie"}?'),
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
        await _api.deleteProceso(proceso.idProceso);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proceso eliminado')),
        );
        _cargarProcesos();
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
        title: const Text('Procesos'),
      ),
      body: FutureBuilder<List<Proceso>>(
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
                  Text('Error al cargar procesos', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(snap.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _cargarProcesos,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final procesos = snap.data ?? [];

          if (procesos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timeline, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Sin procesos registrados',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primer proceso para comenzar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _mostrarDialogoAgregar,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar proceso'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _cargarProcesos(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: procesos.length,
              itemBuilder: (context, index) {
                final proceso = procesos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProcesoCard(
                    proceso: proceso,
                    onDelete: () => _confirmarEliminar(proceso),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoAgregar,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proceso'),
      ),
    );
  }
}

class _ProcesoCard extends StatelessWidget {
  final Proceso proceso;
  final VoidCallback onDelete;

  const _ProcesoCard({
    required this.proceso,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fechaFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: proceso.estaActivo
                        ? Colors.green.withOpacity(0.15)
                        : proceso.estaFinalizado
                            ? Colors.grey.withOpacity(0.15)
                            : Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    proceso.estaActivo
                        ? Icons.play_circle_outline
                        : proceso.estaFinalizado
                            ? Icons.check_circle_outline
                            : Icons.schedule,
                    color: proceso.estaActivo
                        ? Colors.green
                        : proceso.estaFinalizado
                            ? Colors.grey
                            : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proceso.nombreEspecie ?? 'Especie desconocida',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${proceso.duracionDias} días',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: proceso.estaActivo
                        ? Colors.green.withOpacity(0.15)
                        : proceso.estaFinalizado
                            ? Colors.grey.withOpacity(0.15)
                            : Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    proceso.estaActivo
                        ? 'Activo'
                        : proceso.estaFinalizado
                            ? 'Finalizado'
                            : 'Programado',
                    style: TextStyle(
                      color: proceso.estaActivo
                          ? Colors.green
                          : proceso.estaFinalizado
                              ? Colors.grey
                              : Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  onPressed: onDelete,
                  tooltip: 'Eliminar proceso',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inicio',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fechaFormat.format(proceso.fechaInicio),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Final',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fechaFormat.format(proceso.fechaFinal),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogoAgregarProceso extends StatefulWidget {
  final VoidCallback onProcesoAgregado;

  const _DialogoAgregarProceso({required this.onProcesoAgregado});

  @override
  State<_DialogoAgregarProceso> createState() => _DialogoAgregarProcesoState();
}

class _DialogoAgregarProcesoState extends State<_DialogoAgregarProceso> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  DateTime? _fechaInicio;
  DateTime? _fechaFinal;
  int? _especieSeleccionada;
  List<Map<String, dynamic>> _especies = [];
  bool _loading = false;
  bool _cargandoEspecies = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEspecies();
  }

  Future<void> _cargarEspecies() async {
    try {
      final especies = await _api.getEspecies();
      setState(() {
        _especies = especies;
        _cargandoEspecies = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar especies: $e';
        _cargandoEspecies = false;
      });
    }
  }

  Future<void> _agregarProceso() async {
    if (!_formKey.currentState!.validate()) return;
    if (_especieSeleccionada == null) {
      setState(() => _error = 'Selecciona una especie');
      return;
    }
    if (_fechaInicio == null || _fechaFinal == null) {
      setState(() => _error = 'Selecciona las fechas');
      return;
    }
    if (_fechaFinal!.isBefore(_fechaInicio!)) {
      setState(() => _error = 'La fecha final debe ser posterior a la inicial');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.createProceso({
        'id_especie': _especieSeleccionada,
        'fecha_inicio': _fechaInicio!.toIso8601String().split('T')[0],
        'fecha_final': _fechaFinal!.toIso8601String().split('T')[0],
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onProcesoAgregado();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proceso creado correctamente')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (fecha != null) {
      setState(() => _fechaInicio = fecha);
    }
  }

  Future<void> _seleccionarFechaFinal() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: _fechaInicio ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (fecha != null) {
      setState(() => _fechaFinal = fecha);
    }
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 8, 16),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nuevo proceso',
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
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Selecciona la especie',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_cargandoEspecies)
                        const Center(child: CircularProgressIndicator())
                      else if (_especies.isEmpty)
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
                                  'No hay especies disponibles. Crea una especie primero.',
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._especies.map((especie) {
                          final seleccionado = _especieSeleccionada == especie['id_especie'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => setState(() => _especieSeleccionada = especie['id_especie']),
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
                                    Icon(
                                      Icons.pets,
                                      color: seleccionado
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        especie['nombre'] ?? 'Especie',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _fechaInicio != null
                              ? DateFormat('dd/MM/yyyy').format(_fechaInicio!)
                              : '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Fecha de inicio *',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: _seleccionarFechaInicio,
                        validator: (v) => _fechaInicio == null ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _fechaFinal != null
                              ? DateFormat('dd/MM/yyyy').format(_fechaFinal!)
                              : '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Fecha de finalización *',
                          prefixIcon: const Icon(Icons.event),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: _seleccionarFechaFinal,
                        validator: (v) => _fechaFinal == null ? 'Requerido' : null,
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
                      FilledButton(
                        onPressed: _loading ? null : _agregarProceso,
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
                            : const Text('Crear proceso'),
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

