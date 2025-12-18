import 'package:flutter/material.dart';
import 'models/lectura.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';

class PantallaLecturasSensor extends StatefulWidget {
  final int idSensor; // ID del sensor instalado (id_sensor_instalado)
  final String nombreSensor;

  const PantallaLecturasSensor({
    super.key,
    required this.idSensor,
    required this.nombreSensor,
  });

  @override
  State<PantallaLecturasSensor> createState() => _PantallaLecturasSensorState();
}

class _PantallaLecturasSensorState extends State<PantallaLecturasSensor> {
  final _api = ApiService();

  List<Lectura> _lecturas = [];
  bool _cargando = true;
  String? _error;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

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
      final lecturas = await _api.getLecturas(widget.idSensor, limit: 100);

      setState(() {
        _lecturas = lecturas;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _mostrarFormularioLectura() async {
    final valorCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Registrar Lectura'),
          content: TextField(
            controller: valorCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor',
              hintText: 'Ej: 25.5',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final valor = double.tryParse(valorCtrl.text.trim());
                if (valor == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Valor inválido')),
                  );
                  return;
                }

                try {
                  await _api.createLectura(
                    idSensorInstalado: widget.idSensor,
                    valor: valor,
                  );


                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lectura registrada')),
                  );
                  _cargarDatos();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreSensor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarDatos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Listado de lecturas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lecturas recientes',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${_lecturas.length} registros',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_lecturas.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No hay lecturas registradas'),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _lecturas.length,
                            itemBuilder: (context, index) {
                              final lectura = _lecturas[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: const Icon(
                                      Icons.sensors,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    '${lectura.valor.toStringAsFixed(2)}${lectura.unidad != null ? ' ${lectura.unidad}' : ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _dateFormat.format(lectura.fechaLectura),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioLectura,
        child: const Icon(Icons.add),
      ),
    );
  }
}
