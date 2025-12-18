import 'package:flutter/material.dart';
import 'models/especie.dart';
import 'services/api_service.dart';

class PantallaEspecies extends StatefulWidget {
  const PantallaEspecies({super.key});

  @override
  State<PantallaEspecies> createState() => _PantallaEspeciesState();
}

class _PantallaEspeciesState extends State<PantallaEspecies> {
  final _api = ApiService();
  late Future<List<Especie>> _future;

  @override
  void initState() {
    super.initState();
    _cargarEspecies();
  }

  void _cargarEspecies() {
    setState(() {
      _future = _api.getEspecies().then((data) {
        return data.map((item) => Especie.fromJson(item)).toList();
      });
    });
  }

  Future<void> _mostrarDialogoAgregar() async {
    await showDialog(
      context: context,
      builder: (ctx) => _DialogoAgregarEspecie(
        onEspecieAgregada: _cargarEspecies,
      ),
    );
  }

  Future<void> _confirmarEliminar(Especie especie) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar especie'),
        content: Text('¿Eliminar "${especie.nombre}"?'),
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
        await _api.deleteEspecie(especie.idEspecie);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Especie eliminada')),
        );
        _cargarEspecies();
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
        title: const Text('Especies'),
      ),
      body: FutureBuilder<List<Especie>>(
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
                  Text('Error al cargar especies', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(snap.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _cargarEspecies,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final especies = snap.data ?? [];

          if (especies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Sin especies registradas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primera especie para comenzar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _mostrarDialogoAgregar,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar especie'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _cargarEspecies(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: especies.length,
              itemBuilder: (context, index) {
                final especie = especies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EspecieCard(
                    especie: especie,
                    onDelete: () => _confirmarEliminar(especie),
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
        label: const Text('Nueva especie'),
      ),
    );
  }
}

class _EspecieCard extends StatelessWidget {
  final Especie especie;
  final VoidCallback onDelete;

  const _EspecieCard({
    required this.especie,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.pets,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    especie.nombre,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${especie.idEspecie}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Eliminar especie',
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogoAgregarEspecie extends StatefulWidget {
  final VoidCallback onEspecieAgregada;

  const _DialogoAgregarEspecie({required this.onEspecieAgregada});

  @override
  State<_DialogoAgregarEspecie> createState() => _DialogoAgregarEspecieState();
}

class _DialogoAgregarEspecieState extends State<_DialogoAgregarEspecie> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _agregarEspecie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.createEspecie({
        'nombre': _nombreCtrl.text.trim(),
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onEspecieAgregada();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Especie creada correctamente')),
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
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Nueva especie'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre de la especie *',
                hintText: 'Ej: Tilapia nilótica',
                prefixIcon: const Icon(Icons.pets),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              autofocus: true,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _loading ? null : _agregarEspecie,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}

