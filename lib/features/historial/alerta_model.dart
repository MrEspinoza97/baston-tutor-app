class Alerta {
  final String id;
  final double latitud;
  final double longitud;
  final int timestamp; // segundos
  final String estado; // PENDIENTE / ATENDIDA

  Alerta({
    required this.id,
    required this.latitud,
    required this.longitud,
    required this.timestamp,
    required this.estado,
  });

  factory Alerta.fromMap(String id, Map<dynamic, dynamic> map) {
    return Alerta(
      id: id,
      latitud: (map['latitud'] ?? 0).toDouble(),
      longitud: (map['longitud'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] ?? 0).toInt(),
      estado: map['estado'] ?? 'PENDIENTE',
    );
  }

  DateTime get fecha => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}