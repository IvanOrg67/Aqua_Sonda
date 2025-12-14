import 'package:flutter/material.dart';
import 'models/alerta.dart';
import 'services/api_alertas_service.dart';
import 'package:intl/intl.dart';

/// Pantalla para visualizar y gestionar alertas de una instalación
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

class _PantallaAlertasState extends State<PantallaAlertas>
    with SingleTickerProviderStateMixin {
  final _api = ApiAlertasService();
  late TabController _tabController;
  late Future<List<Alerta>> _futureAlertas;
  
  int _conteoNoLeidas = 0;
  bool _soloNoLeidas = false;
  bool _soloNoResueltas = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarAlertas();
    _cargarConteo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cargarAlertas() {
    setState(() {
      _futureAlertas = _api.getByInstalacion(
        idInstalacion: widget.idInstalacion,
        soloNoLeidas: _soloNoLeidas ? true : null,
        soloNoResueltas: _soloNoResueltas ? true : null,
      );
    });
  }

  Future<void> _cargarConteo() async {
    final conteo = await _api.contarNoLeidas(widget.idInstalacion);
    if (mounted) {
      setState(() => _conteoNoLeidas = conteo);
    }
  }

  Future<void> _marcarTodasComoLeidas() async {
    try {
      await _api.marcarTodasComoLeidas(widget.idInstalacion);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas las alertas marcadas como leídas')),
      );
      _cargarAlertas();
      _cargarConteo();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  List<Alerta> _filtrarPorNivel(List<Alerta> alertas, NivelAlerta nivel) {
    return alertas.where((a) => a.nivelAlerta == nivel).toList();
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
        actions: [
          if (_conteoNoLeidas > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _marcarTodasComoLeidas,
              tooltip: 'Marcar todas como leídas',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (value == 'no_leidas') {
                  _soloNoLeidas = !_soloNoLeidas;
                } else if (value == 'no_resueltas') {
                  _soloNoResueltas = !_soloNoResueltas;
                }
                _cargarAlertas();
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'no_leidas',
                checked: _soloNoLeidas,
                child: const Text('Solo no leídas'),
              ),
              CheckedPopupMenuItem(
                value: 'no_resueltas',
                checked: _soloNoResueltas,
                child: const Text('Solo no resueltas'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Críticas'),
            Tab(text: 'Advertencias'),
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

          final criticas = _filtrarPorNivel(todasAlertas, NivelAlerta.critico);
          final advertencias = _filtrarPorNivel(todasAlertas, NivelAlerta.advertencia);

          return RefreshIndicator(
            onRefresh: () async {
              _cargarAlertas();
              await _cargarConteo();
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                _ListaAlertas(alertas: todasAlertas, onUpdate: _cargarAlertas),
                _ListaAlertas(alertas: criticas, onUpdate: _cargarAlertas),
                _ListaAlertas(alertas: advertencias, onUpdate: _cargarAlertas),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ListaAlertas extends StatelessWidget {
  final List<Alerta> alertas;
  final VoidCallback onUpdate;

  const _ListaAlertas({
    required this.alertas,
    required this.onUpdate,
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
          child: _AlertaCard(
            alerta: alerta,
            onUpdate: onUpdate,
          ),
        );
      },
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final Alerta alerta;
  final VoidCallback onUpdate;

  const _AlertaCard({
    required this.alerta,
    required this.onUpdate,
  });

  Future<void> _marcarLeida(BuildContext context) async {
    try {
      await ApiAlertasService().marcarComoLeida(alerta.id!);
      onUpdate();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _marcarResuelta(BuildContext context) async {
    try {
      await ApiAlertasService().marcarComoResuelta(alerta.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta resuelta')),
        );
      }
      onUpdate();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _eliminar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar alerta'),
        content: const Text('¿Eliminar esta alerta permanentemente?'),
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
        await ApiAlertasService().eliminar(alerta.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alerta eliminada')),
          );
        }
        onUpdate();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      elevation: alerta.leida ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: alerta.leida
              ? theme.colorScheme.outline.withOpacity(0.2)
              : alerta.color.withOpacity(0.5),
          width: alerta.leida ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: alerta.leida ? null : () => _marcarLeida(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono de nivel
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: alerta.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(alerta.icono, color: alerta.color, size: 24),
                  ),
                  const SizedBox(width: 12),

                  // Tipo y nivel
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: alerta.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                alerta.nivelAlerta.nombre,
                                style: TextStyle(
                                  color: alerta.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (!alerta.leida) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (alerta.tipoAlerta != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            alerta.tipoAlerta!.replaceAll('_', ' ').toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Menú de acciones
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'leer') {
                        _marcarLeida(context);
                      } else if (value == 'resolver') {
                        _marcarResuelta(context);
                      } else if (value == 'eliminar') {
                        _eliminar(context);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!alerta.leida)
                        const PopupMenuItem(
                          value: 'leer',
                          child: Row(
                            children: [
                              Icon(Icons.done),
                              SizedBox(width: 8),
                              Text('Marcar como leída'),
                            ],
                          ),
                        ),
                      if (!alerta.resuelta)
                        const PopupMenuItem(
                          value: 'resolver',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8),
                              Text('Marcar como resuelta'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Mensaje
              Text(
                alerta.mensaje,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: alerta.leida ? FontWeight.normal : FontWeight.w600,
                ),
              ),

              if (alerta.valorRegistrado != null) ...[
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
                        'Valor: ${alerta.valorRegistrado!.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Footer con fecha y estados
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alerta.fechaGenerada != null
                            ? dateFormat.format(alerta.fechaGenerada!)
                            : 'Sin fecha',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  if (alerta.resuelta)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Resuelta',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
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
      ),
    );
  }
}
