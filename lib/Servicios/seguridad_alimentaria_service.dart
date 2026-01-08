import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_vinculacion/Modelos/seguridad_alimentaria_model.dart';

class SeguridadAlimentariaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'seguridad_alimentaria';

  /// Agregar un nuevo reporte de seguridad alimentaria
  Future<void> agregarReporte(SeguridadAlimentariaModel reporte) async {
    try {
      await _firestore.collection(_collectionName).add(reporte.toMap());
    } catch (e) {
      throw Exception('Error al guardar reporte alimentario: $e');
    }
  }

  /// Obtener todos los reportes de un usuario
  Future<List<SeguridadAlimentariaModel>> obtenerReportes(
      String correo) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('correo', isEqualTo: correo)
          .orderBy('fechaRegistro', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return SeguridadAlimentariaModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener reportes: $e');
    }
  }

  /// Actualizar un reporte (solo reportes recientes)
  Future<void> actualizarReporte(
      String id, SeguridadAlimentariaModel reporte) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionName).doc(id).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final fechaRegistro = (data['fechaRegistro'] as Timestamp).toDate();
        
        // Solo permite editar si el reporte es de menos de 7 días
        final diferenciaDias =
            DateTime.now().difference(fechaRegistro).inDays;
        if (diferenciaDias <= 7) {
          await _firestore
              .collection(_collectionName)
              .doc(id)
              .update({...reporte.toMap(), 'editado': true});
        } else {
          throw Exception('Solo puedes editar reportes de menos de 7 días');
        }
      }
    } catch (e) {
      throw Exception('Error al actualizar reporte: $e');
    }
  }

  /// Eliminar un reporte
  Future<void> eliminarReporte(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar reporte: $e');
    }
  }

  /// Obtener un reporte específico por ID
  Future<SeguridadAlimentariaModel?> obtenerReportePorId(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return SeguridadAlimentariaModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener reporte: $e');
    }
  }

  /// Obtener todos los reportes (útil para vistas de líder)
  Future<List<SeguridadAlimentariaModel>> obtenerTodosReportes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('fechaRegistro', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return SeguridadAlimentariaModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener todos los reportes: $e');
    }
  }

  /// Buscar reportes por alimento, proveedor o teléfono (filtrado cliente para búsquedas simples)
  Future<List<SeguridadAlimentariaModel>> buscarReportes({
    String? alimento,
    String? proveedor,
    String? telefono,
  }) async {
    try {
      CollectionReference col = _firestore.collection(_collectionName);

      // Obtiene un conjunto razonable de registros recientes y aplica filtro en cliente
      QuerySnapshot querySnapshot = await col
          .orderBy('fechaRegistro', descending: true)
          .limit(500)
          .get();

      final results = querySnapshot.docs.map((doc) {
        return SeguridadAlimentariaModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      final filtered = results.where((r) {
        final matchAlimento = (alimento == null || alimento.isEmpty)
            ? true
            : r.alimentoEscaso.toLowerCase().contains(alimento.toLowerCase());
        final matchProveedor = (proveedor == null || proveedor.isEmpty)
            ? true
            : r.nombreProveedor.toLowerCase().contains(proveedor.toLowerCase());
        final matchTelefono = (telefono == null || telefono.isEmpty)
            ? true
            : r.telefonoProveedor.toLowerCase().contains(telefono.toLowerCase());

        return matchAlimento && matchProveedor && matchTelefono;
      }).toList();

      return filtered;
    } catch (e) {
      throw Exception('Error al buscar reportes: $e');
    }
  }

  /// Obtener estadísticas de alimentos escasos
  Future<Map<String, int>> obtenerEstadisticasAlimentos(
      String correo) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('correo', isEqualTo: correo)
          .get();

      Map<String, int> estadisticas = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final alimento = data['alimentoEscaso'] ?? 'Desconocido';
        estadisticas[alimento] = (estadisticas[alimento] ?? 0) + 1;
      }

      return estadisticas;
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  /// Obtener reportes por prioridad
  Future<Map<String, int>> obtenerReportesPorPrioridad(
      String correo) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('correo', isEqualTo: correo)
          .get();

      Map<String, int> porPrioridad = {
        'Baja': 0,
        'Media': 0,
        'Alta': 0,
        'Urgente': 0,
      };

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final prioridad = data['prioridad'] ?? 'Media';
        if (porPrioridad.containsKey(prioridad)) {
          porPrioridad[prioridad] = porPrioridad[prioridad]! + 1;
        }
      }

      return porPrioridad;
    } catch (e) {
      throw Exception('Error al obtener reportes por prioridad: $e');
    }
  }
}
