// pantalla_sensores.dart
import 'package:flutter/material.dart';
import 'services/api_sensores_service.dart';
import 'models/sensor.dart';
import 'widgets/app_card.dart';
import 'widgets/neumorphic.dart';

class PantallaSensores extends StatefulWidget {
  final int idInstalacion;
  final String nombreInstalacion;

  const PantallaSensores({
    super.key,
    required this.idInstalacion,
    required this.nombreInstalacion,
  });

  @override
  State<PantallaSensores> createState() => _PantallaSensoresState();
}

class _PantallaSensoresState extends State<PantallaSensores> {
  final ApiSensoresService _sensoresService = ApiSensoresService();
  
  List<SensorInstalado> _sensores = [];
  List<CatalogoSensor> _catalogo = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final sensores = await _sensoresService.getByInstalacion(widget.idInstalacion);
      // Opcional: cargar catálogo si es necesario
      // final catalogo = await _sensoresService.getCatalogo();

      setState(() {
        _sensores = sensores;
        // _catalogo = catalogo;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _mostrarDialogoInstalar,
            tooltip: 'Instalar Sensor',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando sensores...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _construirError();
    }

    if (_sensores.isEmpty) {
      return _construirEstadoVacio();
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: _construirListaSensores(),
    );
  }

  Widget _construirError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar sensores',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _cargarDatos,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _construirEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sensors_off,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            'No hay sensores instalados',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Instala sensores para comenzar el monitoreo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _mostrarDialogoInstalar,
            icon: const Icon(Icons.add),
            label: const Text('Instalar Primer Sensor'),
          ),
        ],
      ),
    );
  }

  Widget _construirListaSensores() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sensores.length,
      itemBuilder: (context, index) {
        final sensor = _sensores[index];
        return _construirTarjetaSensor(sensor);
      },
    );
  }

  Widget _construirTarjetaSensor(SensorInstalado sensor) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: sensor.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            sensor.icono,
            color: sensor.color,
            size: 24,
          ),
        ),
        title: Text(
          sensor.nombre ?? 'Sensor Sin Nombre',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sensor.parametro ?? 'Sin parámetro'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: sensor.estadoColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sensor.estado ?? 'N/A',
                  style: TextStyle(
                    color: sensor.estadoColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'lecturas',
              child: Row(
                children: [
                  Icon(Icons.timeline),
                  SizedBox(width: 8),
                  Text('Ver Lecturas'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'test',
              child: Row(
                children: [
                  Icon(Icons.science),
                  SizedBox(width: 8),
                  Text('Enviar Test'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'desinstalar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Desinstalar',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (String value) => _manejarAccionSensor(value, sensor),
        ),
      ),
    );
  }

  void _manejarAccionSensor(String accion, SensorInstalado sensor) {
    switch (accion) {
      case 'lecturas':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ver lecturas de ${sensor.nombre}')),
        );
        break;
      case 'test':
        _enviarLecturaTest(sensor);
        break;
      case 'desinstalar':
        _confirmarDesinstalacion(sensor);
        break;
    }
  }

  void _enviarLecturaTest(SensorInstalado sensor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enviando lectura test para ${sensor.nombre}')),
    );
  }

  void _confirmarDesinstalacion(SensorInstalado sensor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desinstalación'),
        content: Text('¿Estás seguro que deseas desinstalar ${sensor.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${sensor.nombre} desinstalado')),
              );
            },
            child: const Text('Desinstalar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoInstalar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instalar Sensor'),
        content: const Text('Función en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
