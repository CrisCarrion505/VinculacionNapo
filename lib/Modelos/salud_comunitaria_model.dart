import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo para Salud Comunitaria
class SaludComunitariaModel {
  final String id;
  final String correo;
  final String enfermedad;
  final String rangoEdad;
  final int edadExacta;
  final String genero;
  final List<String> sintomasSeleccionados;
  final String otrosSintomas;
  final DateTime fechaRegistro;
  final String? observaciones;

  SaludComunitariaModel({
    this.id = '',
    required this.correo,
    required this.enfermedad,
    required this.rangoEdad,
    required this.edadExacta,
    required this.genero,
    required this.sintomasSeleccionados,
    this.otrosSintomas = '',
    required this.fechaRegistro,
    this.observaciones,
  });

  // Convertir objeto a mapa para Firebase
  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'enfermedad': enfermedad,
      'rangoEdad': rangoEdad,
      'edadExacta': edadExacta,
      'genero': genero,
      'sintomasSeleccionados': sintomasSeleccionados,
      'otrosSintomas': otrosSintomas,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'observaciones': observaciones,
    };
  }

  // Crear objeto desde JSON de Firebase
  factory SaludComunitariaModel.fromJson(
      Map<String, dynamic> json, String id) {
    return SaludComunitariaModel(
      id: id,
      correo: json['correo'] ?? '',
      enfermedad: json['enfermedad'] ?? '',
      rangoEdad: json['rangoEdad'] ?? '',
      edadExacta: json['edadExacta'] ?? 0,
      genero: json['genero'] ?? '',
      sintomasSeleccionados:
          List<String>.from(json['sintomasSeleccionados'] ?? []),
      otrosSintomas: json['otrosSintomas'] ?? '',
      fechaRegistro: (json['fechaRegistro'] is Timestamp)
          ? (json['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
      observaciones: json['observaciones'],
    );
  }
}

/// Rangos de edad: exactamente 5 opciones obligatorias
final rangosEdad = [
  'Bebés',
  'Niños',
  'Adolescentes',
  'Adultos',
  'Adultos mayores',
];

/// Mapa de límites para cada rango de edad
final rangoEdadLimites = {
  'Bebés': {'min': 0, 'max': 4},
  'Niños': {'min': 5, 'max': 12},
  'Adolescentes': {'min': 13, 'max': 17},
  'Adultos': {'min': 18, 'max': 59},
  'Adultos mayores': {'min': 60, 'max': 120},
};

/// Géneros (opcional)
final generos = ['Masculino', 'Femenino', 'Otro', 'Prefiero no especificar'];
