import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_vinculacion/Modelos/liderazgo_model.dart';

class LiderazgoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 Asegura que el documento del miembro exista
  Future<void> _asegurarDocumentoMiembro(String correo) async {
    final activeEmail = FirebaseAuth.instance.currentUser?.email;
    if (activeEmail == null) {
      throw Exception('Usuario no autenticado');
    }

    final emailNormalized = activeEmail.toLowerCase();
    // Asegurarse de que el correo pasado coincida con el del usuario autenticado
    if (correo.toLowerCase() != emailNormalized) {
      throw Exception('El correo proporcionado no coincide con el usuario autenticado');
    }

    final docRef = _firestore.collection('liderazgo_comunitario').doc(emailNormalized);

    await docRef.set({
      'correo': emailNormalized,
      'creado_en': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ================== REGISTRO DE VENTAS ==================

  Future<void> addRegistroVentas(
      RegistroVentasModel registro, String correo) async {
    try {
      final activeEmail = FirebaseAuth.instance.currentUser?.email;
      if (activeEmail == null) throw Exception('Usuario no autenticado');
      final emailNormalized = activeEmail.toLowerCase();

      await _asegurarDocumentoMiembro(emailNormalized);

      final data = registro.toMap();
      data['correo'] = emailNormalized;
      data['timestamp'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('liderazgo_comunitario')
          .doc(emailNormalized)
          .collection('ventas')
          .add(data);
    } catch (e) {
      throw Exception('Error al guardar registro de ventas: $e');
    }
  }

  Future<List<RegistroVentasModel>> getRegistrosVentas(String correo) async {
    try {
      final targetEmail = correo.isNotEmpty
          ? correo.toLowerCase()
          : FirebaseAuth.instance.currentUser?.email?.toLowerCase();

      if (targetEmail == null) throw Exception('Usuario no autenticado');

      final snapshot = await _firestore
          .collection('liderazgo_comunitario')
          .doc(targetEmail)
          .collection('ventas')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RegistroVentasModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  // ================== GASTOS OPERATIVOS ==================

  Future<void> addGastosOperativos(
      GastosOperativosModel gastos, String correo) async {
    try {
      final activeEmail = FirebaseAuth.instance.currentUser?.email;
      if (activeEmail == null) throw Exception('Usuario no autenticado');
      final emailNormalized = activeEmail.toLowerCase();

      await _asegurarDocumentoMiembro(emailNormalized);

      final data = gastos.toMap();
      data['correo'] = emailNormalized;
      data['timestamp'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('liderazgo_comunitario')
          .doc(emailNormalized)
          .collection('gastos')
          .add(data);
    } catch (e) {
      throw Exception('Error al guardar gastos: $e');
    }
  }

  Future<List<GastosOperativosModel>> getGastosOperativos(
      String correo) async {
    try {
      final targetEmail = correo.isNotEmpty
        ? correo.toLowerCase()
        : FirebaseAuth.instance.currentUser?.email?.toLowerCase();

      if (targetEmail == null) throw Exception('Usuario no autenticado');

      final snapshot = await _firestore
        .collection('liderazgo_comunitario')
        .doc(targetEmail)
        .collection('gastos')
        .orderBy('timestamp', descending: true)
        .get();

      return snapshot.docs
          .map((doc) => GastosOperativosModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener gastos: $e');
    }
  }

  // ================== GESTIÓN FINANCIERA ==================

  Future<void> addGestionFinanciera(
      GestionFinancieraModel gestion, String correo) async {
    try {
      final activeEmail = FirebaseAuth.instance.currentUser?.email;
      if (activeEmail == null) throw Exception('Usuario no autenticado');
      final emailNormalized = activeEmail.toLowerCase();

      await _asegurarDocumentoMiembro(emailNormalized);

      final data = gestion.toMap();
      data['correo'] = emailNormalized;
      data['timestamp'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('liderazgo_comunitario')
          .doc(emailNormalized)
          .collection('gestion_financiera')
          .add(data);
    } catch (e) {
      throw Exception('Error al guardar gestión financiera: $e');
    }
  }

  Future<List<GestionFinancieraModel>> getGestionFinanciera(
      String correo) async {
    try {
      final targetEmail = correo.isNotEmpty
          ? correo.toLowerCase()
          : FirebaseAuth.instance.currentUser?.email?.toLowerCase();

      if (targetEmail == null) throw Exception('Usuario no autenticado');

      final snapshot = await _firestore
          .collection('liderazgo_comunitario')
          .doc(targetEmail)
          .collection('gestion_financiera')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GestionFinancieraModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener gestión financiera: $e');
    }
  }
}
