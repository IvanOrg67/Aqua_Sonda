import 'package:flutter/material.dart';
import 'models/tarea_programada.dart';
import 'services/api_tareas_service.dart';

class PantallaTareas extends StatefulWidget {
  final int idInstalacion;
  const PantallaTareas({super.key, required this.idInstalacion});

  @override
  State<PantallaTareas> createState() => _PantallaTareasState();
}

class _PantallaTareasState extends State<PantallaTareas> {
  final _api = ApiTareasService();
  late Future<List<TareaProgramada>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.listarPorInstalacion(widget.idInstalacion);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.listarPorInstalacion(widget.idInstalacion);
    });
  }

  Future<void> _crearTareaDialog() async {
    final nombreCtrl = TextEditingController();
    final tipo = ValueNotifier<String>('horario');
    final horaInicioCtrl = TextEditingController();
    final horaFinCtrl = TextEditingController();
    final oxigenoMinCtrl = TextEditingController();
    final oxigenoMaxCtrl = TextEditingController();
    final duracionCtrl = TextEditingController();
    final accion = ValueNotifier<String>('activar_aerador');
    final formKey = GlobalKey<FormState>();
    bool loading = false;
    String? errorText;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> crear() async {
              if (!formKey.currentState!.validate()) return;
              setLocal(() => loading = true);
              try {
                final tarea = TareaProgramada(
                  id: 0,
                  idInstalacion: widget.idInstalacion,
                  nombre: nombreCtrl.text.trim(),
                  tipo: tipo.value,
                  horaInicio: horaInicioCtrl.text.isEmpty ? null : horaInicioCtrl.text,
                  horaFin: horaFinCtrl.text.isEmpty ? null : horaFinCtrl.text,
                  oxigenoMin: oxigenoMinCtrl.text.isEmpty ? null : double.tryParse(oxigenoMinCtrl.text),
                  oxigenoMax: oxigenoMaxCtrl.text.isEmpty ? null : double.tryParse(oxigenoMaxCtrl.text),
                  duracionMinutos: duracionCtrl.text.isEmpty ? null : int.tryParse(duracionCtrl.text),
                  accion: accion.value,
                  activo: true,
                );
                await _api.crear(tarea);
                if (!mounted) return;
                Navigator.of(ctx).pop();
                await _refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarea creada')),
                );
              } catch (e) {
                setLocal(() {
                  errorText = e.toString();
                  loading = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Nueva tarea programada'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: tipo.value,
                        items: const [
                          DropdownMenuItem(value: 'horario', child: Text('Por horario')),
                          DropdownMenuItem(value: 'condicion', child: Text('Por condición (oxígeno)')),
                        ],
                        onChanged: (v) => setLocal(() => tipo.value = v ?? 'horario'),
                        decoration: const InputDecoration(labelText: 'Tipo de tarea'),
                      ),
                      if (tipo.value == 'horario') ...[
                        TextFormField(
                          controller: horaInicioCtrl,
                          decoration: const InputDecoration(labelText: 'Hora inicio (HH:mm)'),
                        ),
                        TextFormField(
                          controller: horaFinCtrl,
                          decoration: const InputDecoration(labelText: 'Hora fin (HH:mm)'),
                        ),
                      ],
                      if (tipo.value == 'condicion') ...[
                        TextFormField(
                          controller: oxigenoMinCtrl,
                          decoration: const InputDecoration(labelText: 'Oxígeno mínimo (mg/L)'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: oxigenoMaxCtrl,
                          decoration: const InputDecoration(labelText: 'Oxígeno máximo (mg/L)'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      TextFormField(
                        controller: duracionCtrl,
                        decoration: const InputDecoration(labelText: 'Duración (minutos)'),
                        keyboardType: TextInputType.number,
                      ),
                      DropdownButtonFormField<String>(
                        value: accion.value,
                        items: const [
                          DropdownMenuItem(value: 'activar_aerador', child: Text('Activar aerador')),
                          DropdownMenuItem(value: 'desactivar_aerador', child: Text('Desactivar aerador')),
                        ],
                        onChanged: (v) => setLocal(() => accion.value = v ?? 'activar_aerador'),
                        decoration: const InputDecoration(labelText: 'Acción'),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(errorText!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: loading ? null : crear,
                  child: loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas programadas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refrescar',
          ),
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: _crearTareaDialog,
            tooltip: 'Nueva tarea',
          ),
        ],
      ),
      body: FutureBuilder<List<TareaProgramada>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Sin tareas programadas'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final t = items[i];
              return ListTile(
                title: Text(t.nombre),
                subtitle: Text(t.tipo == 'horario'
                    ? 'Horario: ${t.horaInicio ?? '-'} a ${t.horaFin ?? '-'}'
                    : 'Oxígeno: ${t.oxigenoMin ?? '-'} a ${t.oxigenoMax ?? '-'} mg/L'),
                trailing: Icon(
                  t.activo ? Icons.check_circle : Icons.cancel,
                  color: t.activo ? Colors.green : Colors.red,
                ),
                onLongPress: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar tarea'),
                      content: Text('¿Eliminar "${t.nombre}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.errorContainer,
                            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await _api.eliminar(t.id);
                    await _refresh();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tarea eliminada')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
