import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_vinculacion/Modelos/liderazgo_model.dart';

class LiderazgoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Guardar Registro de Ventas
  Future<void> addRegistroVentas(RegistroVentasModel registro, String correo) async {
    try {
      await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('ventas')
          .add(registro.toMap());
    } catch (e) {
      throw Exception('Error al guardar registro de ventas: $e');
    }
  }

  // Obtener registros de ventas
  Future<List<RegistroVentasModel>> getRegistrosVentas(String correo) async {
    try {
      final snapshot = await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('ventas')
          .orderBy('fecha_registro', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RegistroVentasModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  // Guardar Gastos Operativos
  Future<void> addGastosOperativos(GastosOperativosModel gastos, String correo) async {
    try {
      await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('gastos')
          .add(gastos.toMap());
    } catch (e) {
      throw Exception('Error al guardar gastos: $e');
    }
  }

  // Obtener gastos operativos
  Future<List<GastosOperativosModel>> getGastosOperativos(String correo) async {
    try {
      final snapshot = await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('gastos')
          .orderBy('fecha_registro', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GastosOperativosModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener gastos: $e');
    }
  }

  // Guardar Gestión Financiera
  Future<void> addGestionFinanciera(GestionFinancieraModel gestion, String correo) async {
    try {
      await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('gestion_financiera')
          .add(gestion.toMap());
    } catch (e) {
      throw Exception('Error al guardar gestión financiera: $e');
    }
  }

  // Obtener gestión financiera
  Future<List<GestionFinancieraModel>> getGestionFinanciera(String correo) async {
    try {
      final snapshot = await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('gestion_financiera')
          .orderBy('fecha_registro', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GestionFinancieraModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener gestión financiera: $e');
    }
  }

  // Eliminar registro de ventas
  Future<void> deleteRegistroVentas(String correo, String ventaId) async {
    try {
      await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('ventas')
          .doc(ventaId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar venta: $e');
    }
  }

  // Eliminar gastos
  Future<void> deleteGasto(String correo, String gastoId) async {
    try {
      await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('gastos')
          .doc(gastoId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar gasto: $e');
    }
  }

  // Actualizar registro de ventas
  Future<void> updateRegistroVentas(String correo, String ventaId, RegistroVentasModel registro) async {
    try {
      await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('ventas')
          .doc(ventaId)
          .update(registro.toMap());
    } catch (e) {
      throw Exception('Error al actualizar venta: $e');
    }
  }

  // Obtener totales de ventas
  Future<Map<String, double>> getTotalesVentas(String correo) async {
    try {
      final snapshot = await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('ventas')
          .get();

      double totalVentas = 0;
      int cantidadVentas = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final ventas = List<Map<String, dynamic>>.from(data['ventas'] ?? []);
        for (var venta in ventas) {
          totalVentas += (venta['total'] as num?)?.toDouble() ?? 0;
          cantidadVentas++;
        }
      }

      return {
        'total': totalVentas,
        'cantidad': cantidadVentas.toDouble(),
        'promedio': cantidadVentas > 0 ? totalVentas / cantidadVentas : 0,
      };
    } catch (e) {
      throw Exception('Error al calcular totales: $e');
    }
  }

  // Obtener totales de gastos
  Future<Map<String, double>> getTotalesGastos(String correo) async {
    try {
      final snapshot = await _firestore
          .collection('liderazgo_comunitario')
          .doc(correo)
          .collection('gastos')
          .get();

      double totalGastos = 0;
      Map<String, double> categorias = {
        'materia_prima': 0,
        'salarios': 0,
        'servicios_publicos': 0,
        'comisiones': 0,
        'publicidad': 0,
        'alquiler': 0,
      };

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final gastos = List<Map<String, dynamic>>.from(data['gastos'] ?? []);
        for (var gasto in gastos) {
          categorias.forEach((key, value) {
            final monto = double.tryParse(gasto[key]?.toString() ?? '0') ?? 0;
            categorias[key] = categorias[key]! + monto;
            totalGastos += monto;
          });
        }
      }

      return {
        'total': totalGastos,
        ...categorias,
      };
    } catch (e) {
      throw Exception('Error al calcular gastos: $e');
    }
  }
}