import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiderSeguridadAlimentariaView extends StatelessWidget {
  const LiderSeguridadAlimentariaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad Alimentaria - Vista Líder')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('seguridad_alimentaria')
            .orderBy('fechaRegistro', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No se han encontrado resultados'));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final correo = data['correo'] ?? 'Desconocido';
              final alimento = data['alimentoEscaso'] ?? '';
              final cantidad = data['cantidadNecesaria'] ?? 0;
              final unidad = data['unidad'] ?? '';
              final proveedor = data['nombreProveedor'] ?? '';
              final telefono = data['telefonoProveedor'] ?? '';
              final prioridad = data['prioridad'] ?? 'Media';
              final fecha = data['fechaRegistro'] is Timestamp
                  ? (data['fechaRegistro'] as Timestamp).toDate()
                  : DateTime.now();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(alimento, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: prioridad == 'Urgente' ? Colors.red : (prioridad == 'Alta' ? Colors.deepOrange : (prioridad == 'Media' ? Colors.orange : Colors.green)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(prioridad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Usuario: $correo'),
                      const SizedBox(height: 6),
                      Text('Cantidad: $cantidad $unidad'),
                      const SizedBox(height: 6),
                      Text('Proveedor: $proveedor ($telefono)'),
                      const SizedBox(height: 8),
                      Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
