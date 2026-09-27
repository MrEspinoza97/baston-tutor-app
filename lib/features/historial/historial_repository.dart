import 'package:firebase_database/firebase_database.dart';
import 'alerta_model.dart';

class HistorialRepository {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('historial_alertas');

  Stream<List<Alerta>> watchHistorial() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final alertas = data.entries
          .map((e) => Alerta.fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>))
          .toList();
      alertas.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return alertas;
    });
  }

  Future<void> marcarComoAtendida(String alertaId) async {
    await _ref.child(alertaId).update({'estado': 'ATENDIDA'});
  }
}