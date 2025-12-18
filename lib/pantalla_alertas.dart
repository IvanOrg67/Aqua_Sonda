import 'package:flutter/material.dart';
import 'models/alerta.dart';
import 'services/api_service.dart';

/// Pantalla para visualizar alertas de una instalación
class PantallaAlertas extends StatefulWidget {
  final int idInstalacion;
  final String nombreInstalacion;

  const PantallaAlertas({
    super.key,
    required this.idInstalacion,
    required this.nombreInstalacion,
  });

  @override
  State<PantallaAlertas> createState() => _PantallaAlertasState();
}

class _PantallaAlertasState extends State<PantallaAlertas> {
  final _api = ApiService();
  
  late Future<List<Alerta>> _futureAlertas;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  void _cargarAlertas() {
    setState(() {
      _futureAlertas = _api.getAlertas(widget.idInstalacion).then((data) {
        return data.map((json) => Alerta.fromJson(json)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alertas'),
            Text(
              widget.nombreInstalacion,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Alerta>>(
        future: _futureAlertas,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error al cargar alertas', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(snap.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _cargarAlertas,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final todasAlertas = snap.data ?? [];

          if (todasAlertas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Sin alertas', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'No hay alertas en este momento',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _cargarAlertas();
            },
            child: _ListaAlertas(alertas: todasAlertas),
          );
        },
      ),
    );
  }
}

class _ListaAlertas extends StatelessWidget {
  final List<Alerta> alertas;

  const _ListaAlertas({
    required this.alertas,
  });

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin alertas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alertas.length,
      itemBuilder: (context, index) {
        final alerta = alertas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AlertaCard(alerta: alerta),
        );
      },
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final Alerta alerta;

  const _AlertaCard({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alerta',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alerta.descripcion,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Valor: ${alerta.datoPuntual.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
