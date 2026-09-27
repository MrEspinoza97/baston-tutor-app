import 'dart:async';
import 'package:flutter/material.dart';
import '../mapa/mapa_repository.dart';
import '../mapa/telemetria_model.dart';

class EstadoScreen extends StatefulWidget {
  const EstadoScreen({super.key});

  @override
  State<EstadoScreen> createState() => _EstadoScreenState();
}

class _EstadoScreenState extends State<EstadoScreen> {
  final MapaRepository _repository = MapaRepository();
  StreamSubscription<Telemetria>? _subscription;
  Telemetria? _telemetria;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _subscription = _repository.watchTelemetria().listen((data) {
      setState(() => _telemetria = data);
    });
    _tickTimer = Timer.periodic(const Duration(seconds: 5), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _telemetria;

    return Scaffold(
      appBar: AppBar(title: const Text('Estado del bastón')),
      body: t == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _EstadoCard(
                  icon: t.enLinea ? Icons.check_circle : Icons.error,
                  iconColor: t.enLinea ? Colors.green : Colors.red,
                  titulo: 'Estado general',
                  valor: t.enLinea ? 'Funcionando' : 'Con problema',
                ),
                _EstadoCard(
                  icon: t.bateria > 20 ? Icons.battery_full : Icons.battery_alert,
                  iconColor: t.bateria > 20 ? Colors.green : Colors.red,
                  titulo: 'Nivel de batería',
                  valor: '${t.bateria}%',
                ),
                _EstadoCard(
                  icon: t.enLinea ? Icons.wifi : Icons.wifi_off,
                  iconColor: t.enLinea ? Colors.green : Colors.amber,
                  titulo: 'Estado de conexión',
                  valor: t.enLinea ? 'En línea' : 'Desconectado',
                ),
                _EstadoCard(
                  icon: Icons.access_time,
                  iconColor: Colors.blueGrey,
                  titulo: 'Última señal recibida',
                  valor: t.textoUltimaActualizacion,
                ),
                _EstadoCard(
                  icon: Icons.sensors,
                  iconColor: Colors.blueGrey,
                  titulo: 'Sensor de proximidad',
                  valor: t.distanciaSuperior != null
                      ? '${t.distanciaSuperior} mm'
                      : 'Sin datos',
                ),
                _EstadoCard(
                  icon: Icons.gps_fixed,
                  iconColor: (t.latitud != 0 || t.longitud != 0) ? Colors.green : Colors.grey,
                  titulo: 'GPS',
                  valor: (t.latitud != 0 || t.longitud != 0) ? 'Con señal' : 'Sin señal',
                ),
              ],
            ),
    );
  }
}

class _EstadoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String titulo;
  final String valor;

  const _EstadoCard({
    required this.icon,
    required this.iconColor,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(titulo),
        subtitle: Text(
          valor,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}