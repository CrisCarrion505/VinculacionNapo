// Modelo para Registro de Ventas
class RegistroVentasModel {
  final String correo;
  final String cedula;
  final String papeleta;
  final String ruc;
  final String registroVentas;
  final List<Map<String, dynamic>> ventas;

  RegistroVentasModel({
    required this.correo,
    required this.cedula,
    required this.papeleta,
    required this.ruc,
    required this.registroVentas,
    required this.ventas,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'cedula': cedula,
      'papeleta': papeleta,
      'ruc': ruc,
      'registro_ventas': registroVentas,
      'ventas': ventas,
    };
  }
  
  factory RegistroVentasModel.fromMap(Map<String, dynamic> map) {
    return RegistroVentasModel(
      correo: map['correo'] ?? '',
      cedula: map['cedula'] ?? '',
      papeleta: map['papeleta'] ?? '',
      ruc: map['ruc'] ?? '',
      registroVentas: map['registro_ventas'] ?? '',
      ventas: List<Map<String, dynamic>>.from(map['ventas'] ?? []),
    );
  }
}

// Modelo para Gastos Operativos
class GastosOperativosModel {
  final String correo;
  final List<Map<String, dynamic>> gastos;

  GastosOperativosModel({
    required this.correo,
    required this.gastos,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'gastos': gastos,
    };
  }

  factory GastosOperativosModel.fromMap(Map<String, dynamic> map) {
    return GastosOperativosModel(
      correo: map['correo'] ?? '',
      gastos: List<Map<String, dynamic>>.from(map['gastos'] ?? []),
    );
  }
}

// Modelo para Gestión Financiera Comunitaria
class GestionFinancieraModel {
  final String correo;
  final bool reunionesPeriodicas;
  final String resumenFinanciero;
  final String presupuestoAnual;
  final String presupuestoMensual;
  final String fondosEmergencia;
  final bool registrosContables;

  GestionFinancieraModel({
    required this.correo,
    required this.reunionesPeriodicas,
    required this.resumenFinanciero,
    required this.presupuestoAnual,
    required this.presupuestoMensual,
    required this.fondosEmergencia,
    required this.registrosContables,
  });

  Map<String, dynamic> toMap() {
    return {
      'correo': correo,
      'reuniones_periodicas': reunionesPeriodicas,
      'resumen_financiero': resumenFinanciero,
      'presupuesto_anual': presupuestoAnual,

      
      'presupuesto_mensual': presupuestoMensual,
      'fondos_emergencia': fondosEmergencia,
      'registros_contables': registrosContables,
    };
  }

  factory GestionFinancieraModel.fromMap(Map<String, dynamic> map) {
    return GestionFinancieraModel(
      correo: map['correo'] ?? '',
      reunionesPeriodicas: map['reuniones_periodicas'] ?? false,
      resumenFinanciero: map['resumen_financiero'] ?? '',
      presupuestoAnual: map['presupuesto_anual'] ?? '',
      presupuestoMensual: map['presupuesto_mensual'] ?? '',
      fondosEmergencia: map['fondos_emergencia'] ?? '',
      registrosContables: map['registros_contables'] ?? false,
    );
  }
}