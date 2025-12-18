import 'package:flutter/material.dart';
import 'widgets/neumorphic.dart';
import 'widgets/gauge.dart';
import 'services/database_auth_service.dart';
import 'services/api_service.dart';
import 'theme/theme_controller.dart';
import 'widgets/settings_sheet.dart';
import 'models/instalacion.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  final _api = ApiService();
  final _authService = DatabaseAuthService();
  List<Instalacion> _instalaciones = [];
  Map<String, dynamic> _estadisticas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final usuario = await _authService.getUsuarioActual();
      if (usuario != null) {
        final instalacionesData = await _api.getInstalaciones(usuario['id_usuario']);
        final estadisticas = await _api.getEstadisticas(usuario['id_usuario']);
        setState(() {
          // Convertir List<Map> a List<Instalacion>
          _instalaciones = instalacionesData
              .map((item) => Instalacion.fromJson(item))
              .toList();
          _estadisticas = estadisticas;
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

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
        await _api.deleteInstalacion(it.idInstalacion);
        if (!mounted) return;
        _cargarDatos();
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
    final descripcionCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String tipoUsoSeleccionado = 'acuicultura';
    bool loading = false;
    String? errorText;

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
                final usuario = await _authService.getUsuarioActual();
                if (usuario == null) throw Exception('Usuario no autenticado');
                
                // Nota: Se requiere id_organizacion_sucursal e id_proceso
                // Por ahora mostramos error si no están disponibles
                await _api.createInstalacion({
                  'id_organizacion_sucursal': 1, // TODO: Obtener de usuario/contexto
                  'nombre_instalacion': nombreCtrl.text.trim(),
                  'fecha_instalacion': DateTime.now().toIso8601String().split('T')[0],
                  'estado_operativo': 'activo',
                  'descripcion': descripcionCtrl.text.trim().isEmpty 
                      ? 'Instalación creada desde la app' 
                      : descripcionCtrl.text.trim(),
                  'tipo_uso': tipoUsoSeleccionado,
                  'id_proceso': 1, // TODO: Obtener proceso activo o crear uno
                });
                if (!mounted) return;
                Navigator.of(ctx).pop();
                _cargarDatos();
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre de la instalación'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descripcionCtrl,
                        decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: tipoUsoSeleccionado,
                        decoration: const InputDecoration(labelText: 'Tipo de uso'),
                        items: const [
                          DropdownMenuItem(value: 'acuicultura', child: Text('Acuicultura')),
                          DropdownMenuItem(value: 'tratamiento', child: Text('Tratamiento')),
                          DropdownMenuItem(value: 'otros', child: Text('Otros')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setLocal(() => tipoUsoSeleccionado = value);
                          }
                        },
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(errorText!,
                            style: const TextStyle(color: Colors.red)),
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
            _authService.logout();
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
              tooltip: 'Procesos',
              onPressed: () => Navigator.pushNamed(context, '/procesos'),
              icon: const Icon(Icons.timeline),
            ),
            IconButton(
              tooltip: 'Especies',
              onPressed: () => Navigator.pushNamed(context, '/especies'),
              icon: const Icon(Icons.pets),
            ),
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
                  child: _cargando
                      ? const Center(child: CircularProgressIndicator())
                      : _instalaciones.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.water_drop_outlined, size: 48, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No tienes instalaciones',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Presiona + para crear una',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _instalaciones.length,
                              itemBuilder: (context, index) {
                                final instalacion = _instalaciones[index];
                                return Container(
                                  width: isTablet ? 280 : 260,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: NeumorphicCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                instalacion.nombre,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            PopupMenuButton(
                                              itemBuilder: (ctx) => [
                                                PopupMenuItem(
                                                  value: 'ver',
                                                  child: Row(
                                                    children: const [
                                                      Icon(Icons.visibility, size: 20),
                                                      SizedBox(width: 8),
                                                      Text('Ver detalles'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'eliminar',
                                                  child: Row(
                                                    children: const [
                                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                                      SizedBox(width: 8),
                                                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              onSelected: (value) {
                                                if (value == 'ver') {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/instalacion-detalle',
                                                    arguments: instalacion.idInstalacion,
                                                  );
                                                } else if (value == 'eliminar') {
                                                  _confirmEliminarInstalacion(instalacion);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                instalacion.descripcion.isNotEmpty 
                                                    ? instalacion.descripcion 
                                                    : 'Sin descripción',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Text(
                                              'Tipo: ${instalacion.tipoUso}',
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Estado: ${instalacion.estadoOperativo}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: instalacion.estadoOperativo == 'activo'
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
                            children: [
                              _StatusSection(estadisticas: _estadisticas),
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
                  NeumorphicCard(child: _StatusSection(estadisticas: _estadisticas)),
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
  final Map<String, dynamic> estadisticas;
  const _StatusSection({required this.estadisticas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _StatusRow(
          label: 'Instalaciones',
          value: '${estadisticas['totalInstalaciones'] ?? 0}',
        ),
        _StatusRow(
          label: 'Sensores',
          value: '${estadisticas['totalSensores'] ?? 0}',
        ),
        _StatusRow(
          label: 'Alertas activas',
          value: '${estadisticas['alertasActivas'] ?? 0}',
        ),
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
