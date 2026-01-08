// turismo_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para Lugar Turístico
class LugarTuristicoModel {
  final String id;
  final String correo;
  final String numeroRegistroTuristico;
  final String tipoServicio;
  final String nombreEstablecimiento;
  final String capacidadAtencion;
  final String tarifasPorServicio;
  final String horariosOperacion;
  final String ubicacion;
  final DateTime fechaRegistro;

  LugarTuristicoModel({
    this.id = '',
    required this.correo,
    required this.numeroRegistroTuristico,
    required this.tipoServicio,
    required this.nombreEstablecimiento,
    required this.capacidadAtencion,
    required this.tarifasPorServicio,
    required this.horariosOperacion,
    required this.ubicacion,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'numeroRegistroTuristico': numeroRegistroTuristico,
      'tipoServicio': tipoServicio,
      'nombreEstablecimiento': nombreEstablecimiento,
      'capacidadAtencion': capacidadAtencion,
      'tarifasPorServicio': tarifasPorServicio,
      'horariosOperacion': horariosOperacion,
      'ubicacion': ubicacion,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  factory LugarTuristicoModel.fromMap(Map<String, dynamic> map, String id) {
    return LugarTuristicoModel(
      id: id,
      correo: map['correo'] ?? '',
      numeroRegistroTuristico: map['numeroRegistroTuristico'] ?? '',
      tipoServicio: map['tipoServicio'] ?? '',
      nombreEstablecimiento: map['nombreEstablecimiento'] ?? '',
      capacidadAtencion: map['capacidadAtencion'] ?? '',
      tarifasPorServicio: map['tarifasPorServicio'] ?? '',
      horariosOperacion: map['horariosOperacion'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      fechaRegistro: (map['fechaRegistro'] is Timestamp)
          ? (map['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

/// Modelo para Registro de Visitante
class RegistroVisitanteModel {
  final String id;
  final String correo;
  final String tipoServicio;
  final String ubicacion;
  final String nombre;
  final String telefono;
  final String opinionesValoraciones;
  final DateTime fechaVisita;

  RegistroVisitanteModel({
    this.id = '',
    required this.correo,
    required this.tipoServicio,
    required this.ubicacion,
    required this.nombre,
    required this.telefono,
    required this.opinionesValoraciones,
    required this.fechaVisita,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'tipoServicio': tipoServicio,
      'ubicacion': ubicacion,
      'nombre': nombre,
      'telefono': telefono,
      'opinionesValoraciones': opinionesValoraciones,
      'fechaVisita': Timestamp.fromDate(fechaVisita),
    };
  }

  factory RegistroVisitanteModel.fromMap(Map<String, dynamic> map, String id) {
    return RegistroVisitanteModel(
      id: id,
      correo: map['correo'] ?? '',
      tipoServicio: map['tipoServicio'] ?? '',
      ubicacion: map['ubicacion'] ?? '',
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      opinionesValoraciones: map['opinionesValoraciones'] ?? '',
      fechaVisita: (map['fechaVisita'] is Timestamp)
          ? (map['fechaVisita'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

/// Modelo para Emprendimiento Comunitario Turístico
class EmprendimientoComunitarioTuristico {
  final String correo;
  final String nombre;
  final List<String> servicios;

  EmprendimientoComunitarioTuristico({
    required this.correo,
    required this.nombre,
    required this.servicios,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'nombre': nombre,
      'servicios': servicios,
    };
  }

  factory EmprendimientoComunitarioTuristico.fromMap(Map<String, dynamic> map) {
    return EmprendimientoComunitarioTuristico(
      correo: map['correo'] ?? '',
      nombre: map['nombre'] ?? '',
      servicios: List<String>.from(map['servicios'] ?? []),
    );
  }
}

/// Modelo para Estrategia de Turismo Comunitario
class EstrategiaTurismoComunitarioModel {
  final String correo;
  final String nombre;
  final List<String> acciones;

  EstrategiaTurismoComunitarioModel({
    required this.correo,
    required this.nombre,
    required this.acciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'nombre': nombre,
      'acciones': acciones,
    };
  }

  factory EstrategiaTurismoComunitarioModel.fromMap(Map<String, dynamic> map) {
    return EstrategiaTurismoComunitarioModel(
      correo: map['correo'] ?? '',
      nombre: map['nombre'] ?? '',
      acciones: List<String>.from(map['acciones'] ?? []),
    );
  }
}
