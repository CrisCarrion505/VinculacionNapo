const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Cloud Function para limpiar y migrar datos en Firestore
 * - Renombra campos de timestamp antiguos a 'timestamp' estándar
 * - Elimina colecciones obsoletas
 * - Ejecutar una sola vez: firebase deploy --only functions:cleanupFirestore
 */
exports.cleanupFirestore = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Iniciando limpieza de Firestore...");

    // 1. Migrar timestamps en liderazgo_comunitario
    await migrateTimestampsInCollection("liderazgo_comunitario");

    // 2. Migrar timestamps en colecciones de turismo
    await migrateTimestampsInCollection("lugares_turisticos");
    await migrateTimestampsInCollection("visitantes");
    await migrateTimestampsInCollection("emp_comun_turistico");
    await migrateTimestampsInCollection("estra_fort_turismo_comun");

    // 3. Migrar timestamps en presupuestos
    await migrateTimestampsInCollection("presupuestos_comunidad");

    // 4. Eliminar colecciones obsoletas (descomenta si existen)
    // await deleteCollection("coleccion_obsoleta_1");
    // await deleteCollection("coleccion_obsoleta_2");

    res.json({
      success: true,
      message: "Limpieza completada exitosamente",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error("Error durante la limpieza:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * Migra timestamps en una colección
 * Renombra 'createdAt' y 'fecha_registro' a 'timestamp'
 */
async function migrateTimestampsInCollection(collectionName) {
  console.log(`Migrando timestamps en: ${collectionName}`);

  const snapshot = await db.collection(collectionName).get();
  const batch = db.batch();
  let count = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const updates = {};

    // Si tiene 'createdAt' y no tiene 'timestamp', renombra
    if (data.createdAt && !data.timestamp) {
      updates.timestamp = data.createdAt;
      updates.createdAt = admin.firestore.FieldValue.delete();
      batch.update(doc.ref, updates);
      count++;
    }

    // Si tiene 'fecha_registro' y no tiene 'timestamp', renombra
    if (data.fecha_registro && !data.timestamp) {
      updates.timestamp = admin.firestore.Timestamp.fromDate(
        new Date(data.fecha_registro)
      );
      updates.fecha_registro = admin.firestore.FieldValue.delete();
      batch.update(doc.ref, updates);
      count++;
    }
  }

  if (count > 0) {
    await batch.commit();
    console.log(`  ✓ ${count} documentos migraron en ${collectionName}`);
  } else {
    console.log(`  ✓ Sin documentos para migrar en ${collectionName}`);
  }
}

/**
 * Migra timestamps en subcollecciones
 * Ej: liderazgo_comunitario/{userId}/ventas/
 */
async function migrateTimestampsInSubcollections(parentCollectionName) {
  console.log(`Migrando timestamps en subcollecciones de: ${parentCollectionName}`);

  const parentSnapshot = await db.collection(parentCollectionName).get();

  for (const parentDoc of parentSnapshot.docs) {
    // Obtener subcollecciones (ventas, gastos, etc.)
    const subCollections = await parentDoc.ref.listCollections();

    for (const subCollection of subCollections) {
      const subSnapshot = await subCollection.get();
      const batch = db.batch();
      let count = 0;

      for (const doc of subSnapshot.docs) {
        const data = doc.data();
        const updates = {};

        if (data.createdAt && !data.timestamp) {
          updates.timestamp = data.createdAt;
          updates.createdAt = admin.firestore.FieldValue.delete();
          batch.update(doc.ref, updates);
          count++;
        }

        if (data.fecha_registro && !data.timestamp) {
          updates.timestamp = admin.firestore.Timestamp.fromDate(
            new Date(data.fecha_registro)
          );
          updates.fecha_registro = admin.firestore.FieldValue.delete();
          batch.update(doc.ref, updates);
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        console.log(
          `  ✓ ${count} documentos migraron en ${parentCollectionName}/${subCollection.id}`
        );
      }
    }
  }
}

/**
 * Elimina una colección completa
 */
async function deleteCollection(collectionName) {
  console.log(`Eliminando colección: ${collectionName}`);

  const snapshot = await db.collection(collectionName).get();
  const batch = db.batch();

  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  console.log(`  ✓ Colección ${collectionName} eliminada`);
}

/**
 * Función alternativa: limpiar por demanda HTTP
 * Llamar desde: curl https://YOUR_CLOUD_FUNCTION_URL
 */
exports.cleanupOldTimestamps = functions.https.onRequest(
  async (req, res) => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Solo POST permitido" });
    }

    try {
      // Migrar en todas las colecciones principales
      await migrateTimestampsInCollection("liderazgo_comunitario");
      await migrateTimestampsInSubcollections("liderazgo_comunitario");
      await migrateTimestampsInCollection("lugares_turisticos");
      await migrateTimestampsInCollection("visitantes");
      await migrateTimestampsInCollection("presupuestos_comunidad");

      res.json({
        success: true,
        message: "Migración de timestamps completada",
      });
    } catch (error) {
      console.error("Error:", error);
      res.status(500).json({ error: error.message });
    }
  }
);
