// Modelo para Contratos de Trabajo
class ContratoTrabajoModel {
  final String correo;
  final String nombreEmpleado;
  final String cedula;
  final String tipoContrato;
  final String fechaInicio;
  final String salario;
  final String fechaAfiliacion;
  final String numeroAfiliacion;

  ContratoTrabajoModel({
    required this.correo,
    required this.nombreEmpleado,
    required this.cedula,
    required this.tipoContrato,
    required this.fechaInicio,
    required this.salario,
    required this.fechaAfiliacion,
    required this.numeroAfiliacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'nombre_empleado': nombreEmpleado,
      'cedula': cedula,
      'tipo_contrato': tipoContrato,
      'fecha_inicio': fechaInicio,
      'salario': salario,
      'fecha_afiliacion': fechaAfiliacion,
      'numero_afiliacion': numeroAfiliacion,
      'fecha_registro': DateTime.now().toIso8601String(),
    };
  }

  factory ContratoTrabajoModel.fromMap(Map<String, dynamic> map) {
    return ContratoTrabajoModel(
      correo: map['correo'] ?? '',
      nombreEmpleado: map['nombre_empleado'] ?? '',
      cedula: map['cedula'] ?? '',
      tipoContrato: map['tipo_contrato'] ?? '',
      fechaInicio: map['fecha_inicio'] ?? '',
      salario: map['salario'] ?? '',
      fechaAfiliacion: map['fecha_afiliacion'] ?? '',
      numeroAfiliacion: map['numero_afiliacion'] ?? '',
    );
  }
}

// Modelo para Beneficios Sociales
class BeneficiosSocialesModel {
  final String correo;
  final bool decimoTercero;
  final bool decimoCuarto;
  final bool fondosReserva;
  final bool vacaciones;
  final bool horasExtra;

  BeneficiosSocialesModel({
    required this.correo,
    required this.decimoTercero,
    required this.decimoCuarto,
    required this.fondosReserva,
    required this.vacaciones,
    required this.horasExtra,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'decimo_tercero': decimoTercero,
      'decimo_cuarto': decimoCuarto,
      'fondos_reserva': fondosReserva,
      'vacaciones': vacaciones,
      'horas_extra': horasExtra,
      'fecha_registro': DateTime.now().toIso8601String(),
    };
  }

  factory BeneficiosSocialesModel.fromMap(Map<String, dynamic> map) {
    return BeneficiosSocialesModel(
      correo: map['correo'] ?? '',
      decimoTercero: map['decimo_tercero'] ?? false,
      decimoCuarto: map['decimo_cuarto'] ?? false,
      fondosReserva: map['fondos_reserva'] ?? false,
      vacaciones: map['vacaciones'] ?? false,
      horasExtra: map['horas_extra'] ?? false,
    );
  }
}

// Modelo para Control de Asistencia
class ControlAsistenciaModel {
  final String correo;
  final List<Map<String, dynamic>> registros;

  ControlAsistenciaModel({
    required this.correo,
    required this.registros,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'registros': registros,
      'fecha_registro': DateTime.now().toIso8601String(),
    };
  }

  factory ControlAsistenciaModel.fromMap(Map<String, dynamic> map) {
    return ControlAsistenciaModel(
      correo: map['correo'] ?? '',
      registros: List<Map<String, dynamic>>.from(map['registros'] ?? []),
    );
  }
}

// Modelo para Derecho Tributario Comunitario
class DerechoTributarioModel {
  final String correo;
  final String ruc;
  final String documentacion;
  final String declaracionImpuestos;

  DerechoTributarioModel({
    required this.correo,
    required this.ruc,
    required this.documentacion,
    required this.declaracionImpuestos,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'ruc': ruc,
      'documentacion': documentacion,
      'declaracion_impuestos': declaracionImpuestos,
      'fecha_registro': DateTime.now().toIso8601String(),
    };
  }

  factory DerechoTributarioModel.fromMap(Map<String, dynamic> map) {
    return DerechoTributarioModel(
      correo: map['correo'] ?? '',
      ruc: map['ruc'] ?? '',
      documentacion: map['documentacion'] ?? '',
      declaracionImpuestos: map['declaracion_impuestos'] ?? '',
    );
  }
}