import 'package:firebase_database/firebase_database.dart';
import 'telemetria_model.dart';

class MapaRepository {
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref('bastones/BST001/telemetria');

  Stream<Telemetria> watchTelemetria() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return Telemetria.fromMap(data);
    });
  }

  Future<String> obtenerNombreBeneficiario(String beneficiarioId) async {
    final snapshot =
        await FirebaseDatabase.instance.ref('beneficiarios/$beneficiarioId/nombre').get();
    return snapshot.value?.toString() ?? 'Beneficiario';
  }
}