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

  /// Obtener estadísticas de salud por enfermedad (usuario específico)
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

  /// Obtener todos los registros (para vista de líder)
  Future<List<SaludComunitariaModel>> obtenerTodosRegistros() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('fechaRegistro', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return SaludComunitariaModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener todos los registros: $e');
    }
  }

  /// Buscar registros por enfermedad, rango de edad o edad exacta
  Future<List<SaludComunitariaModel>> buscarRegistros({
    String? enfermedad,
    String? rangoEdad,
    int? edad,
  }) async {
    try {
      // Obtener registros recientes
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('fechaRegistro', descending: true)
          .limit(500)
          .get();

      final registros = querySnapshot.docs.map((doc) {
        return SaludComunitariaModel.fromJson(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Filtrado en cliente
      final filtrados = registros.where((r) {
        final matchEnfermedad = (enfermedad == null || enfermedad.isEmpty)
            ? true
            : r.enfermedad.toLowerCase().contains(enfermedad.toLowerCase());

        final matchRango = (rangoEdad == null || rangoEdad.isEmpty)
            ? true
            : r.rangoEdad == rangoEdad;

        final matchEdad = edad == null ? true : r.edadExacta == edad;

        return matchEnfermedad && matchRango && matchEdad;
      }).toList();

      return filtrados;
    } catch (e) {
      throw Exception('Error al buscar registros: $e');
    }
  }

  /// Obtener estadísticas de enfermedades por rango de edad
  /// Retorna: Map<rangoEdad, Map<enfermedad, conteo>>
  Future<Map<String, Map<String, int>>> obtenerEstadisticasPorRangoEdad() async {
    try {
      final registros = await obtenerTodosRegistros();

      final estadisticas = <String, Map<String, int>>{};

      // Inicializar mapas para cada rango de edad (del modelo)
      final rangos = ['Bebés', 'Niños', 'Adolescentes', 'Adultos', 'Adultos mayores'];
      for (final rango in rangos) {
        estadisticas[rango] = {};
      }

      // Agrupar por rango de edad y enfermedad
      for (final registro in registros) {
        final rango = registro.rangoEdad;
        final enfermedad = registro.enfermedad;

        if (estadisticas[rango] != null) {
          estadisticas[rango]![enfermedad] =
              (estadisticas[rango]![enfermedad] ?? 0) + 1;
        }
      }

      return estadisticas;
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  /// Obtener estadísticas globales de enfermedades (sin segmentación)
  /// Retorna: Map<enfermedad, conteo>
  Future<Map<String, int>> obtenerEstadisticasGlobales() async {
    try {
      final registros = await obtenerTodosRegistros();
      final estadisticas = <String, int>{};

      for (final registro in registros) {
        final enfermedad = registro.enfermedad;
        estadisticas[enfermedad] = (estadisticas[enfermedad] ?? 0) + 1;
      }

      return estadisticas;
    } catch (e) {
      throw Exception('Error al obtener estadísticas globales: $e');
    }
  }
}
