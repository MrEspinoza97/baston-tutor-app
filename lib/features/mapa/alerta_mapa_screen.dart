import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AlertaMapaScreen extends StatelessWidget {
  final double latitud;
  final double longitud;
  final String fecha;

  const AlertaMapaScreen({
    super.key,
    required this.latitud,
    required this.longitud,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    final punto = LatLng(latitud, longitud);
    return Scaffold(
      appBar: AppBar(title: Text('Alerta del $fecha')),
      body: FlutterMap(
        options: MapOptions(initialCenter: punto, initialZoom: 16),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.baston_tutor_app',
          ),
          MarkerLayer(markers: [
            Marker(
              point: punto,
              width: 48,
              height: 48,
              child: const Icon(Icons.location_on, color: Colors.red, size: 48),
            ),
          ]),
        ],
      ),
    );
  }
}