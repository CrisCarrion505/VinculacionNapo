import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_vinculacion/Modelos/turismo_model.dart'; // Ajusta la ruta según dónde tengas definidos tus modelos
// Asegúrate de importar también los modelos de Emprendimiento y Estrategia si están en archivos separados:
// import 'package:proyecto_vinculacion/Modelos/emprendimiento_model.dart';
// import 'package:proyecto_vinculacion/Modelos/estrategia_model.dart';

class FirebaseTurismoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guarda los datos de Lugar Turístico en un nuevo documento de la colección "Turismo".
  Future<void> addLugarTuristico(Map<String, String> data, String correo) async {
    try {
      await _firestore.collection('lugares_turisticos').add({
        'categoria': 'Lugar Turístico',
        'correo': correo,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error al agregar Lugar Turístico: $e");
    }
  }

  /// Obtener documentos guardados por correo para cada colección
  Future<List<Map<String, dynamic>>> getLugaresTuristicos(String correo) async {
    try {
      try {
        final snapshot = await _firestore.collection('lugares_turisticos')
            .where('correo', isEqualTo: correo)
            .orderBy('timestamp', descending: true)
            .get();
        return snapshot.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
      } catch (e) {
        // Si la consulta requiere un índice, hacemos una consulta sin orderBy como fallback
        final message = e.toString();
        if (message.contains('failed-precondition') || message.contains('requires an index')) {
          final snapshot = await _firestore.collection('lugares_turisticos')
              .where('correo', isEqualTo: correo)
              .get();
          return snapshot.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Error al obtener lugares turísticos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getVisitantes(String correo) async {
    try {
      try {
        final snapshot = await _firestore.collection('visitantes')
            .where('correo', isEqualTo: correo)
            .orderBy('timestamp', descending: true)
            .get();
        return snapshot.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
      } catch (e) {
        final message = e.toString();
        if (message.contains('failed-precondition') || message.contains('requires an index')) {
          final snapshot = await _firestore.collection('visitantes')
              .where('correo', isEqualTo: correo)
              .get();
          return snapshot.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Error al obtener visitantes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEmprendimientos(String correo) async {
    try {
      final snapshot = await _firestore.collection('emp_comun_turistico')
          .where('correo', isEqualTo: correo)
          .get();
      return snapshot.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getEstrategias(String correo) async {
    try {
      final snapshot = await _firestore.collection('estra_fort_turismo_comun')
          .where('correo', isEqualTo: correo)
          .get();
      return snapshot.docs.map((d) => d.data()).toList().cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Guarda los datos de Registro de visitante en un nuevo documento de la colección "Turismo".
  Future<void> addRegistroVisitante(Map<String, String> data, String correo) async {
    try {
      await _firestore.collection('visitantes').add({
        'categoria': 'Registro de visitante',
        'correo': correo,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error al agregar Registro de visitante: $e");
    }
  }

  /// Guarda los datos de Emprendimiento Comunitario Turístico.
  /// Se recibe una instancia de [EmprendimientoComunitarioTuristico] que contiene el nombre y la lista de servicios.
  Future<void> addEmprendimiento(EmprendimientoComunitarioTuristico model, String correo) async {
    try {
      await _firestore.collection('emp_comun_turistico').add({
        'categoria': 'Emprendimiento Comunitario Turístico',
        'correo': correo,
        'nombre': model.nombre,
        'servicios': model.servicios,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error al agregar Emprendimiento Comunitario Turístico: $e");
    }
  }

  /// Guarda los datos de Estrategias para el fortalecimiento del turismo comunitario.
  /// Se recibe una instancia de [EstrategiaTurismoComunitario] que contiene el nombre y la lista de acciones.
  Future<void> addEstrategia(EstrategiaTurismoComunitarioModel model, String correo) async {
    try {
      await _firestore.collection('estra_fort_turismo_comun').add({
        'categoria': 'Estrategias para el fortalecimiento del turismo comunitario',
        'correo': correo,
        'nombre': model.nombre,
        'acciones': model.acciones,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error al agregar Estrategia: $e");
    }
  }
}
