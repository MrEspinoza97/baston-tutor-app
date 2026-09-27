import 'package:intl/intl.dart';

class Telemetria {
  final double latitud;
  final double longitud;
  final bool sos;
  final int bateria;
  final int ultimaConexion;
  final int? distanciaSuperior; // opcional, según la especificación

  Telemetria({
    required this.latitud,
    required this.longitud,
    required this.sos,
    required this.bateria,
    required this.ultimaConexion,
    this.distanciaSuperior,
  });

  factory Telemetria.fromMap(Map<dynamic, dynamic> map) {
    return Telemetria(
      latitud: (map['latitud'] ?? 0).toDouble(),
      longitud: (map['longitud'] ?? 0).toDouble(),
      sos: map['sos'] ?? false,
      bateria: (map['bateria'] ?? 0).toInt(),
      ultimaConexion: (map['ultima_conexion'] ?? 0).toInt(),
      distanciaSuperior: map['distancia_superior'] != null
          ? (map['distancia_superior'] as num).toInt()
          : null,
    );
  }

  DateTime get fechaUltimaConexion =>
      DateTime.fromMillisecondsSinceEpoch(ultimaConexion * 1000);

  bool get enLinea {
    final ahoraSegundos = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (ahoraSegundos - ultimaConexion) < 30;
  }

  int get segundosDesdeUltimaConexion {
    final ahoraSegundos = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return ahoraSegundos - ultimaConexion;
  }

  String get textoUltimaActualizacion {
    final segundos = segundosDesdeUltimaConexion;
    if (segundos < 0) return 'Fecha inválida';
    if (segundos < 60) return 'Hace $segundos s';
    if (segundos < 3600) return 'Hace ${(segundos / 60).floor()} min';
    return DateFormat("dd-MM-yy 'hrs' HH:mm").format(fechaUltimaConexion);
  }
}