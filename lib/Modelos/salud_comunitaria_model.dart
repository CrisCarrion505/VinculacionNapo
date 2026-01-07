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

// Mapa de enfermedades con síntomas específicos
final enfermedadesMap = {
  'Gripe': [
    'Fiebre',
    'Tos',
    'Dolor de garganta',
    'Congestión nasal',
    'Dolores corporales'
  ],
  'Diabetes': [
    'Sed excesiva',
    'Frecuencia urinaria',
    'Fatiga',
    'Visión borrosa',
    'Heridas que cicatrizan lentamente'
  ],
  'Hipertensión': [
    'Dolor de cabeza',
    'Mareos',
    'Dolor en el pecho',
    'Visión borrosa',
    'Dificultad para respirar'
  ],
  'Desnutrición': [
    'Debilidad',
    'Pérdida de peso',
    'Fatiga',
    'Problemas de concentración',
    'Piel seca'
  ],
  'Gastroenteritis': [
    'Diarrea',
    'Vómito',
    'Dolor abdominal',
    'Fiebre',
    'Pérdida de apetito'
  ],
  'Anemia': [
    'Fatiga',
    'Debilidad',
    'Palidez',
    'Falta de aire',
    'Mareos'
  ],
  'Infección Respiratoria': [
    'Tos',
    'Fiebre',
    'Dolor de pecho',
    'Dificultad para respirar',
    'Flemas'
  ],
  'Dengue': [
    'Fiebre alta',
    'Dolor de cabeza',
    'Dolor muscular',
    'Erupción cutánea',
    'Náuseas'
  ],
  'Parasitosis': [
    'Dolor abdominal',
    'Diarrea',
    'Prurito anal',
    'Pérdida de apetito',
    'Irritabilidad'
  ],
  'Otra': [],
};

// Rangos de edad
final rangosEdad = [
  'Menor de 5 años',
  '5 - 12 años',
  '13 - 18 años',
  '19 - 35 años',
  '36 - 60 años',
  'Mayor de 60 años',
];

// Géneros
final generos = ['Masculino', 'Femenino', 'Otro', 'Prefiero no especificar'];
