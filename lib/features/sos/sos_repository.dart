import 'package:firebase_database/firebase_database.dart';

class SosRepository {
  final DatabaseReference _historialRef =
      FirebaseDatabase.instance.ref('historial_alertas');

  Future<String> registrarAlerta({
    required double latitud,
    required double longitud,
    required int timestamp,
  }) async {
    final ref = _historialRef.push();
    await ref.set({
      'latitud': latitud,
      'longitud': longitud,
      'timestamp': timestamp,
      'estado': 'PENDIENTE',
      'baston_id': 'BST001',
    });
    return ref.key!;
  }

  Future<void> marcarComoAtendida(String alertaId) async {
    await _historialRef.child(alertaId).update({'estado': 'ATENDIDA'});
  }
}