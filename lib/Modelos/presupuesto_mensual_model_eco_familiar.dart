import 'package:cloud_firestore/cloud_firestore.dart';

class PresupuestoComunidad {
  String id;
  String userId;
  List<Map<String, dynamic>> ingresos;
  List<Map<String, dynamic>> egresos;
  List<Map<String, dynamic>> ahorros;
  List<Map<String, dynamic>> inversiones;
  double totalIngresos;
  double totalEgresos;
  double totalAhorros;
  double totalInversiones;
  double saldoFinal;
  DateTime fecha;

  PresupuestoComunidad({
    this.id = '',
    required this.userId,
    required this.ingresos,
    required this.egresos,
    required this.ahorros,
    required this.inversiones,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.totalAhorros,
    required this.totalInversiones,
    required this.saldoFinal,
    required this.fecha,
  });

  // Convertir objeto a JSON para Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'ingresos': ingresos,
      'egresos': egresos,
      'ahorros': ahorros,
      'inversiones': inversiones,
      'totalIngresos': totalIngresos,
      'totalEgresos': totalEgresos,
      'totalAhorros': totalAhorros,
      'totalInversiones': totalInversiones,
      'saldoFinal': saldoFinal,
      'fecha': fecha.toIso8601String(),
    };
  }

 factory PresupuestoComunidad.fromJson(Map<String, dynamic> json, String id) {
  return PresupuestoComunidad(
    id: id,
    userId: json['userId'],
    ingresos: List<Map<String, dynamic>>.from(json['ingresos'] ?? []),
    egresos: List<Map<String, dynamic>>.from(json['egresos'] ?? []),
    ahorros: List<Map<String, dynamic>>.from(json['ahorros'] ?? []),
    inversiones: List<Map<String, dynamic>>.from(json['inversiones'] ?? []),
    totalIngresos: (json['totalIngresos'] as num?)?.toDouble() ?? 0.0,
    totalEgresos: (json['totalEgresos'] as num?)?.toDouble() ?? 0.0,
    totalAhorros: (json['totalAhorros'] as num?)?.toDouble() ?? 0.0,
    totalInversiones: (json['totalInversiones'] as num?)?.toDouble() ?? 0.0,
    saldoFinal: (json['saldoFinal'] as num?)?.toDouble() ?? 0.0,
    fecha: (json['fecha'] is Timestamp) ? (json['fecha'] as Timestamp).toDate() : DateTime.now(),
  );
}

}
