import 'package:flutter/material.dart';
import '../mapa/mapa_repository.dart';
import '../mapa/telemetria_model.dart';
import 'sos_repository.dart';
import 'sos_screen.dart';
import '../../core/navigation.dart';

class SosListener extends StatefulWidget {
  final Widget child;
  const SosListener({super.key, required this.child});

  @override
  State<SosListener> createState() => _SosListenerState();
}

class _SosListenerState extends State<SosListener> {
  final MapaRepository _mapaRepository = MapaRepository();
  final SosRepository _sosRepository = SosRepository();
  bool _sosAnterior = false;
  String? _alertaActivaId;

  @override
  void initState() {
    super.initState();
    _mapaRepository.watchTelemetria().listen(_onTelemetria);
  }

  Future<void> _onTelemetria(Telemetria t) async {
    if (t.sos && !_sosAnterior) {
      _alertaActivaId = await _sosRepository.registrarAlerta(
        latitud: t.latitud,
        longitud: t.longitud,
        timestamp: t.ultimaConexion,
      );
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => SosScreen(
            latitud: t.latitud,
            longitud: t.longitud,
            timestamp: t.ultimaConexion,
            onAtendida: () async {
              if (_alertaActivaId != null) {
                await _sosRepository.marcarComoAtendida(_alertaActivaId!);
              }
            },
          ),
        ),
      );
    }
    _sosAnterior = t.sos;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}