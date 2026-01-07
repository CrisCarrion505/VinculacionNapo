import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo para Seguridad Alimentaria
class SeguridadAlimentariaModel {
  final String id;
  final String correo;
  final String alimentoEscaso;
  final String nombreProveedor;
  final String telefonoProveedor;
  final String frecuenciaEscasez;
  final double cantidadNecesaria;
  final String unidad;
  final String prioridad;
  final String razonEscasez;
  final String razonEscasezOtro;
  final String observaciones;
  final String ubicacion;
  final DateTime fechaRegistro;
  final bool? editado;

  SeguridadAlimentariaModel({
    this.id = '',
    required this.correo,
    required this.alimentoEscaso,
    required this.nombreProveedor,
    required this.telefonoProveedor,
    required this.frecuenciaEscasez,
    required this.cantidadNecesaria,
    required this.unidad,
    this.prioridad = 'Media',
    required this.razonEscasez,
    this.razonEscasezOtro = '',
    this.observaciones = '',
    required this.ubicacion,
    required this.fechaRegistro,
    this.editado = false,
  });

  // Convertir objeto a mapa para Firebase
  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'alimentoEscaso': alimentoEscaso,
      'nombreProveedor': nombreProveedor,
      'telefonoProveedor': telefonoProveedor,
      'frecuenciaEscasez': frecuenciaEscasez,
      'cantidadNecesaria': cantidadNecesaria,
      'unidad': unidad,
      'prioridad': prioridad,
      'razonEscasez': razonEscasez,
      'razonEscasezOtro': razonEscasezOtro,
      'observaciones': observaciones,
      'ubicacion': ubicacion,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'editado': editado ?? false,
    };
  }

  // Crear objeto desde JSON de Firebase
  factory SeguridadAlimentariaModel.fromJson(
      Map<String, dynamic> json, String id) {
    return SeguridadAlimentariaModel(
      id: id,
      correo: json['correo'] ?? '',
      alimentoEscaso: json['alimentoEscaso'] ?? '',
      nombreProveedor: json['nombreProveedor'] ?? '',
      telefonoProveedor: json['telefonoProveedor'] ?? '',
      frecuenciaEscasez: json['frecuenciaEscasez'] ?? '',
      cantidadNecesaria:
          (json['cantidadNecesaria'] as num?)?.toDouble() ?? 0.0,
      unidad: json['unidad'] ?? '',
      prioridad: json['prioridad'] ?? 'Media',
      razonEscasez: json['razonEscasez'] ?? '',
      razonEscasezOtro: json['razonEscasezOtro'] ?? '',
      observaciones: json['observaciones'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      fechaRegistro: (json['fechaRegistro'] is Timestamp)
          ? (json['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
      editado: json['editado'] ?? false,
    );
  }
}

// Alimentos comunes en Ecuador
final alimentosComunes = [
  'Arroz',
  'Frijoles',
  'Maíz',
  'Papa',
  'Plátano',
  'Yuca',
  'Carne de res',
  'Pollo',
  'Huevos',
  'Leche',
  'Queso',
  'Verduras (lechuga, tomate, cebolla)',
  'Frutas (naranja, plátano, manzana)',
  'Aceite',
  'Sal',
  'Azúcar',
  'Trigo/Harina',
  'Otro',
];

// Frecuencias de escasez
final frecuenciasEscasez = [
  'Siempre (constantemente)',
  'Muy frecuente (casi siempre)',
  'Frecuente (varias veces por semana)',
  'Ocasional (algunas veces al mes)',
  'Rara vez',
];

// Razones de escasez
final razonesEscasez = [
  'Falta de dinero',
  'Cultivo fallido',
  'Dependencia de proveedores',
  'Carreteras malas',
  'Falta de transporte',
  'Plagas en cultivos',
  'Sequía',
  'Precio muy alto',
  'Otro',
];

// Unidades
final unidades = [
  'Kilogramos (kg)',
  'Libras (lb)',
  'Arrobas',
  'Litros (L)',
  'Docenas',
  'Sacos',
  'Porciones',
  'Unidades',
];

// Sectores comunes (ubicaciones)
final sectores = [
  'Centro',
  'Noroccidente',
  'Nororiente',
  'Suroriente',
  'Suroeste',
  'Zona rural',
  'Otra',
];

// Prioridades
final prioridades = ['Baja', 'Media', 'Alta', 'Urgente'];
