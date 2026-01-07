import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_vinculacion/Modelos/salud_comunitaria_model.dart';

class SaludComunitariaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'salud_comunitaria';

  /// Agregar un nuevo registro de salud
  Future<void> agregarRegistroSalud(
      SaludComunitariaModel registro) async {
    try {
      await _firestore.collection(_collectionName).add(registro.toMap());
    } catch (e) {
      throw Exception('Error al guardar registro de salud: $e');
    }
  }

  /// Obtener todos los registros de salud de un usuario
  Future<List<SaludComunitariaModel>> obtenerRegistrosSalud(
      String correo) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('correo', isEqualTo: correo)
          .orderBy('fechaRegistro', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return SaludComunitariaModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener registros de salud: $e');
    }
  }

  /// Actualizar un registro de salud
  Future<void> actualizarRegistroSalud(
      String id, SaludComunitariaModel registro) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update(registro.toMap());
    } catch (e) {
      throw Exception('Error al actualizar registro de salud: $e');
    }
  }

  /// Eliminar un registro de salud
  Future<void> eliminarRegistroSalud(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar registro de salud: $e');
    }
  }

  /// Obtener un registro específico por ID
  Future<SaludComunitariaModel?> obtenerRegistroPorId(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return SaludComunitariaModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener registro: $e');
    }
  }

  /// Obtener estadísticas de salud por enfermedad
  Future<Map<String, int>> obtenerEstadisticasEnfermedades(
      String correo) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .where('correo', isEqualTo: correo)
          .get();

      Map<String, int> estadisticas = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final enfermedad = data['enfermedad'] ?? 'Desconocida';
        estadisticas[enfermedad] = (estadisticas[enfermedad] ?? 0) + 1;
      }

      return estadisticas;
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}
