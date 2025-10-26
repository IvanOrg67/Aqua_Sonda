import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/neumorphic.dart';
import 'services/api_installaciones_service.dart';
import 'theme/theme_controller.dart';
import 'widgets/settings_sheet.dart';

class PantallaInstalaciones extends StatefulWidget {
  const PantallaInstalaciones({super.key});

  @override
  State<PantallaInstalaciones> createState() => _PantallaInstalacionesState();
}


class _PantallaInstalacionesState extends State<PantallaInstalaciones> {
  final _api = ApiInstalacionesService();
  late Future<List<Instalacion>> _future;
  static const String _cardBg =
      'assets/images/image-aNvpXQcowFLBnfeDs2JfYaMI2hEiM5.png'; // fondo de cada tarjeta

  @override
  void initState() {
    super.initState();
    _future = _api.listar();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.listar();
    });
  }

  Future<void> _confirmEliminar(BuildContext context, Instalacion it) async {
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar instalación'),
        content: Text('¿Seguro que deseas eliminar "${it.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.errorContainer,
              foregroundColor: scheme.onErrorContainer,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _api.eliminar(it.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Instalación "${it.nombre}" eliminada')),
        );
        await _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    final isTablet = shortest >= 600;
    final gridCount = isTablet ? 2 : 1;
    final cardHeight = isTablet ? 220.0 : 200.0;

  // Future gestionado en estado para poder refrescar tras eliminar

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instalaciones'),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            onPressed: () => openSettingsSheet(context),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: () => ThemeController.instance.toggle(),
            icon: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Icon(isDark ? Icons.light_mode : Icons.dark_mode);
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Instalacion>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(color: AppColors.error)),
              ),
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Sin instalaciones registradas'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              childAspectRatio: (16 / 9), // tarjetas panorámicas
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final it = items[i];
              return _InstalacionCard(
                instalacion: it,
                height: cardHeight,
                backgroundAsset: _cardBg,
                onTap: () {
                  // 👉 tu modelo no tiene toJson(); armamos un Map con campos reales
                  Navigator.pushNamed(
                    context,
                    '/instalacion',
                    arguments: {
                      'id_instalacion': it.id,
                      'nombre_instalacion': it.nombre,
                      'estado_operativo': it.estado,
                      'id_empresa': it.idEmpresa,
                      'descripcion': it.descripcion,
                      'fecha_instalacion': it.fechaInstalacion,
                      'tipo_uso': it.uso,
                    },
                  );
                },
                onDelete: () => _confirmEliminar(context, it),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: crear instalación (formulario propio)
          // Si quieres crear aquí, usa:
          // await api.crear(
          //   idEmpresaSucursal: 1, // IDs reales de /api/seed/min
          //   idProceso: 1,
          //   nombreInstalacion: 'Estanque X',
          //   fechaInstalacion: '2025-09-07',
          //   estadoOperativo: 'activo',
          //   tipoUso: 'acuicultura',
          //   descripcion: 'Demo',
          // );
          // y luego setState/refresh (si cambias a Stateful).
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva instalación'),
      ),
    );
  }
}

class _InstalacionCard extends StatelessWidget {
  final Instalacion instalacion;
  final double height;
  final String backgroundAsset;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _InstalacionCard({
    required this.instalacion,
    required this.height,
    required this.backgroundAsset,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo imagen piscina
              Image.asset(
                backgroundAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.blueGrey),
              ),
              // Degradado para legibilidad (suave y dependiente de tema)
              Builder(builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.28 : 0.18),
                      ],
                    ),
                  ),
                );
              }),
              // Contenido
              Padding(
                padding: const EdgeInsets.all(14),
                child: Stack(
                  children: [
                    // Botón eliminar arriba-izquierda
                    if (onDelete != null)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                          ),
                          onPressed: onDelete,
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          tooltip: 'Eliminar',
                        ),
                      ),
                    // Estado arriba-derecha
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
              color: ((instalacion.estado.isEmpty ? '—' : instalacion.estado) == 'activo'
                ? Theme.of(context).colorScheme.tertiaryContainer
                : Theme.of(context).colorScheme.errorContainer),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          instalacion.estado.isEmpty ? '—' : instalacion.estado,
                          style: TextStyle(
                            color: instalacion.estado == 'activo'
                                ? Theme.of(context).colorScheme.onTertiaryContainer
                                : Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    // Nombre + info abajo
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: Neu.concave(radius: 12),
                            child: Icon(Icons.pool_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  instalacion.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  instalacion.descripcion.isNotEmpty ? instalacion.descripcion : '—',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '0 sensores',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
