import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class SosScreen extends StatefulWidget {
  final double latitud;
  final double longitud;
  final int timestamp; // segundos
  final Future<void> Function() onAtendida;

  const SosScreen({
    super.key,
    required this.latitud,
    required this.longitud,
    required this.timestamp,
    required this.onAtendida,
  });

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final AudioPlayer _player = AudioPlayer();
  Timer? _vibrateTimer;
  bool _atendiendo = false;

  @override
  void initState() {
    super.initState();
    _iniciarAlarma();
  }

  Future<void> _iniciarAlarma() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    try {
      await _player.play(AssetSource('sounds/alarma.mp3'));
    } catch (_) {
      // Si falta el asset, la app sigue funcionando sin sonido.
    }

    if (await Vibration.hasVibrator() ?? false) {
      _vibrateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        Vibration.vibrate(duration: 800);
      });
    }
  }

  Future<void> _detenerAlarma() async {
    await _player.stop();
    _vibrateTimer?.cancel();
  }

  Future<void> _confirmarAtendida() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Marcar esta alerta como atendida? El sonido se detendrá.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmar == true) {
      setState(() => _atendiendo = true);
      await _detenerAlarma();
      await widget.onAtendida();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _detenerAlarma();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime.fromMillisecondsSinceEpoch(widget.timestamp * 1000);
    final fechaTexto = DateFormat("dd-MM-yy 'hrs' HH:mm").format(fecha);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.red,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 96),
                const SizedBox(height: 16),
                const Text('ALERTA SOS',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const Text('El beneficiario necesita ayuda',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Text('Hora: $fechaTexto', style: const TextStyle(color: Colors.white, fontSize: 16)),
                Text(
                  'Ubicación: ${widget.latitud.toStringAsFixed(5)}, ${widget.longitud.toStringAsFixed(5)}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Sonando · Vibrando', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.map),
                    label: const Text('Ver ubicación', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _atendiendo ? null : _confirmarAtendida,
                    child: _atendiendo
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                          )
                        : const Text(
                            'Marcar como atendida',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}