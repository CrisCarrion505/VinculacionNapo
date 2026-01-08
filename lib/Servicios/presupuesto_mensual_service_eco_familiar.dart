import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_vinculacion/Modelos/presupuesto_mensual_model_eco_familiar.dart';

class PresupuestoService {
  final CollectionReference _presupuestoRef =
      FirebaseFirestore.instance.collection('presupuestos_comunidad');

  /// Agregar un nuevo presupuesto a Firebase
  Future<void> agregarPresupuesto(PresupuestoComunidad presupuesto) async {
    try {
      // Usuario autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener datos del usuario (nombre)
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final nombreUsuario = userDoc.exists && userDoc.data() != null
          ? userDoc.data()!['nombre'] ?? 'Desconocido'
          : 'Desconocido';

      // Convertir presupuesto a Map
      final data = presupuesto.toMap();

      // 🔥 Agregar datos del usuario (sobrescribir nombreUsuario del modelo)
      data['userId'] = user.uid;
      data['nombreUsuario'] = nombreUsuario;
      data['fecha'] = Timestamp.fromDate(presupuesto.fecha);

      // Guardar en Firestore
      await _presupuestoRef.add(data);
    } catch (e) {
      throw Exception('Error al guardar el presupuesto: $e');
    }
  }

  /// Obtener todos los presupuestos de un usuario
  Future<List<PresupuestoComunidad>> obtenerPresupuestos(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _presupuestoRef
          .where('userId', isEqualTo: userId)
          .orderBy('fecha', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return PresupuestoComunidad.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener los presupuestos: $e');
    }
  }

  /// Eliminar un presupuesto por ID
  Future<void> eliminarPresupuesto(String id) async {
    try {
      await _presupuestoRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar el presupuesto: $e');
    }
  }
}
