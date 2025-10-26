import 'package:flutter/material.dart';
import 'widgets/neumorphic.dart';
import 'widgets/gauge.dart';
import 'services/api_installaciones_service.dart';
import 'services/api_user_service.dart';
import 'theme/theme_controller.dart';
import 'widgets/settings_sheet.dart';
// Si tu modelo está en otra ruta, descomenta y ajusta:
// import 'models/instalacion.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  final _apiInst = ApiInstalacionesService();
  int _reload = 0; // para refrescar FutureBuilder tras crear instalación

  Future<void> _confirmEliminarInstalacion(Instalacion it) async {
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar instalación'),
        content: Text('¿Deseas eliminar "${it.nombre}"?'),
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
        await _apiInst.eliminar(it.id);
        if (!mounted) return;
        setState(() => _reload++);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Instalación "${it.nombre}" eliminada')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
      }
    }
  }

  Future<void> _crearInstalacionDialog() async {
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool loading = false;
    String? errorText;

    // IDs mínimos de ejemplo (ajusta con los tuyos reales /api/seed/min)
    int idEmpresaSucursal = 1;
  // int idProceso = 1; // no usado por ahora

    String fechaHoy() {
      final now = DateTime.now();
      return '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
    }

    await showDialog(
      context: context,
      barrierDismissible: !loading,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> crear() async {
              if (!formKey.currentState!.validate()) return;
              setLocal(() {
                loading = true;
                errorText = null;
              });
              try {
                await _apiInst.crear(
                  idEmpresa: idEmpresaSucursal,
                  nombre: nombreCtrl.text.trim(),
                  fechaInstalacion: fechaHoy(),
                  estado: 'activo',
                  uso: 'acuicultura',
                  descripcion: descCtrl.text.trim(),
                );
                if (!mounted) return;
                Navigator.of(ctx).pop();
                setState(() => _reload++);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Instalación creada')),
                );
              } catch (e) {
                setLocal(() {
                  errorText = e.toString();
                  loading = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Nueva instalación'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)'),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(errorText!,
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ],
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
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
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
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final nombre = args?['nombre'] ?? 'Usuario';
    final rol = args?['rol'] ?? 'Sin rol';
    final correoArg = args?['correo'] as String?;

    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;
    final isTablet = shortestSide >= 600;
    final isLandscape = media.orientation == Orientation.landscape;

    final maxContentWidth = isTablet ? (isLandscape ? 720.0 : 600.0) : 420.0;
    final gaugeSize = isTablet
        ? (isLandscape ? 260.0 : 240.0)
        : (shortestSide * 0.55).clamp(180.0, 240.0);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Seguro que quieres salir y cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        );
        if (shouldLogout == true) {
          try {
            await ApiUserService().logout();
            if (!mounted) return;
            await Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (_) => false);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AquaSense'),
          actions: [
            IconButton(
              tooltip: 'Alternar tema',
              onPressed: () => ThemeController.instance.toggle(),
              icon: Builder(
                builder: (ctx) {
                  final isDark = Theme.of(ctx).brightness == Brightness.dark;
                  return Icon(isDark ? Icons.light_mode : Icons.dark_mode);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: Neu.convex(
                radius: 20,
                base: Theme.of(context).colorScheme.surface,
                intensity: 0.1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.verified_user,
                      size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    rol,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => openSettingsSheet(context, correo: correoArg),
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Ajustes',
            ),
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Cabecera
                Text(
                  'Hola, $nombre',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ) ??
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                // 1) INSTALACIONES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Instalaciones',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ) ??
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: _crearInstalacionDialog,
                      tooltip: 'Nueva instalación',
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: isTablet ? 190 : 170,
                  child: FutureBuilder<List<Instalacion>>(
                    key: ValueKey(_reload),
                    future: _apiInst.listar(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Error: ${snap.error}',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        );
                      }
                      final items = snap.data ?? [];
                      if (items.isEmpty) {
                        return const Center(child: Text('Sin instalaciones'));
                      }

                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final it = items[i];
                          return _InstalacionCard(
                            instalacion: it,
                            onTap: () => Navigator.pushNamed(
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
                            ),
                            onLongPress: () => _confirmEliminarInstalacion(it),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 2) STATUS & GAUGE
                if (isTablet && isLandscape)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status
                      Expanded(
                        child: NeumorphicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _StatusSection(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Gauge
                      Expanded(
                        child: NeumorphicCard(
                          child: GaugeSection(gaugeSize: gaugeSize),
                        ),
                      ),
                    ],
                  )
                else ...[
                  const NeumorphicCard(child: _StatusSection()),
                  const SizedBox(height: 12),
                  NeumorphicCard(child: GaugeSection(gaugeSize: gaugeSize)),
                ],

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Ajustes y cambio de contraseña se factorizaron a widgets/settings_sheet.dart

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatusRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const _StatusRow(label: 'Oxígeno disuelto', value: '54%'),
        const _StatusRow(label: 'pH', value: '7'),
        const _StatusRow(label: 'Temperatura', value: '27°C'),
      ],
    );
  }
}

class GaugeSection extends StatelessWidget {
  final double gaugeSize;
  const GaugeSection({super.key, required this.gaugeSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Temperatura',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Gauge(
          value: 27 / 50,
          centerText: '27°C',
          size: gaugeSize,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0°C',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text('Temperatura correcta',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
            Text('50°C',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
class _InstalacionCard extends StatelessWidget {
  final Instalacion instalacion;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _InstalacionCard({
    required this.instalacion,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = (w * 0.72).clamp(260.0, 360.0);
    final h = (cardW * 0.56).clamp(150.0, 200.0); // proporción 16:9 aprox

  final estado =
    instalacion.estado.isEmpty ? '—' : instalacion.estado;
    // Como el modelo no trae 'sensores', mantenemos el diseño con 0:
    final sensores = 0;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: cardW,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x332196F3), Color(0x3300BCD4)],
          ),
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/image-1ZoixW91pByrJkUhBuYXIKBFXjMjOG.png',
            ),
            fit: BoxFit.cover,
            opacity: 0.18,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: Neu.concave(
                      radius: 12,
                      base: Theme.of(context).colorScheme.surface,
                    ),
                    child: Icon(
                      Icons.pool_rounded,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      instalacion.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
          color: (estado == 'activo'
            ? Theme.of(context).colorScheme.tertiaryContainer
            : Theme.of(context).colorScheme.errorContainer),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: estado == 'activo'
                        ? Theme.of(context).colorScheme.onTertiaryContainer
                        : Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Text(
                '$sensores sensores',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
