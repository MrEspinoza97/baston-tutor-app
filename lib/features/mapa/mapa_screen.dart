import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'mapa_repository.dart';
import 'telemetria_model.dart';
import '../historial/historial_screen.dart';
import '../estado/estado_screen.dart';
import '../perfil/perfil_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapaRepository _repository = MapaRepository();
  final MapController _mapController = MapController();
  StreamSubscription<Telemetria>? _subscription;
  Telemetria? _telemetria;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _subscription = _repository.watchTelemetria().listen((data) {
      setState(() => _telemetria = data);
      _mapController.move(LatLng(data.latitud, data.longitud), _mapController.camera.zoom);
    });
    _tickTimer = Timer.periodic(const Duration(seconds: 5), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  Color _colorEstado() {
    if (_telemetria == null) return Colors.grey;
    if (_telemetria!.sos) return Colors.red;
    if (!_telemetria!.enLinea) return Colors.amber;
    return Colors.green;
  }

  String _textoEstado() {
    if (_telemetria == null) return 'Cargando...';
    if (_telemetria!.sos) return 'SOS ACTIVO';
    if (!_telemetria!.enLinea) return 'Sin conexión';
    return 'En línea';
  }

  @override
  Widget build(BuildContext context) {
    final t = _telemetria;
    final punto = t != null ? LatLng(t.latitud, t.longitud) : const LatLng(-17.3935, -66.1570);

    return Scaffold(
appBar: AppBar(
  title: const Text('Bastón Tutor'),
  actions: [
    IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: 'Estado del bastón',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EstadoScreen()),
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.history),
      tooltip: 'Historial de alertas',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HistorialScreen()),
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.person),
      tooltip: 'Perfil',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PerfilScreen()),
        );
      },
    ),
  ],
),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: punto, initialZoom: 16),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.baston_tutor_app',
              ),
              if (t != null)
                MarkerLayer(markers: [
                  Marker(
                    point: punto,
                    width: 48,
                    height: 48,
                    child: Icon(Icons.location_on, color: _colorEstado(), size: 48),
                  ),
                ]),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: _colorEstado(), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_textoEstado(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (t != null)
                            Text(t.textoUltimaActualizacion),
                        ],
                      ),
                    ),
                    if (t != null) ...[
                      Icon(
                        t.bateria > 20 ? Icons.battery_full : Icons.battery_alert,
                        color: t.bateria > 20 ? Colors.green : Colors.red,
                      ),
                      Text('${t.bateria}%'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'centrar',
            onPressed: t == null
                ? null
                : () => _mapController.move(punto, 16),
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'ruta',
            onPressed: () {
              // TODO: implementar "Ver ruta en el mapa" (historial de posiciones)
            },
            label: const Text('Ver ruta'),
            icon: const Icon(Icons.route),
          ),
        ],
      ),
    );
  }
}