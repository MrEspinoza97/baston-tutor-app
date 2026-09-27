import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'historial_repository.dart';
import 'alerta_model.dart';
import '../mapa/alerta_mapa_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final HistorialRepository _repository = HistorialRepository();

  Future<bool> _confirmarAtender(Alerta alerta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marcar como atendida'),
        content: const Text('¿Confirmas que esta alerta ya fue atendida?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmar == true) {
      await _repository.marcarComoAtendida(alerta.id);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de alertas')),
      body: StreamBuilder<List<Alerta>>(
        stream: _repository.watchHistorial(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final alertas = snapshot.data!;
          if (alertas.isEmpty) {
            return const Center(child: Text('Aún no hay alertas registradas'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alertas.length,
            itemBuilder: (context, index) {
              final alerta = alertas[index];
              final atendida = alerta.estado == 'ATENDIDA';
              final fechaTexto = DateFormat("dd-MM-yy 'hrs' HH:mm").format(alerta.fecha);

              final tarjeta = Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: atendida
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: atendida ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(fechaTexto, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${alerta.latitud.toStringAsFixed(5)}, ${alerta.longitud.toStringAsFixed(5)}',
                  ),
                  trailing: Chip(
                    label: Text(
                      alerta.estado,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: atendida ? Colors.green : Colors.orange,
                    padding: EdgeInsets.zero,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AlertaMapaScreen(
                          latitud: alerta.latitud,
                          longitud: alerta.longitud,
                          fecha: fechaTexto,
                        ),
                      ),
                    );
                  },
                ),
              );

              // Solo las pendientes se pueden deslizar para atender.
              if (atendida) return tarjeta;

              return Dismissible(
                key: ValueKey(alerta.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmarAtender(alerta),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                child: tarjeta,
              );
            },
          );
        },
      ),
    );
  }
}