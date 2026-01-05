import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiderGestionTuristicaView extends StatefulWidget {
  const LiderGestionTuristicaView({super.key});

  @override
  State<LiderGestionTuristicaView> createState() => _LiderGestionTuristicaViewState();
}

class _LiderGestionTuristicaViewState extends State<LiderGestionTuristicaView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión Turística - Vista Líder"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lugares_turisticos')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay registros de lugares turísticos'),
            );
          }

          final registros = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: registros.length,
            itemBuilder: (context, index) {
                final data = registros[index].data() as Map<String, dynamic>;
                  final miembro = data['correo'] ?? data['nombreUsuario'] ?? 'Desconocido';
                  final createdAt = data['createdAt'];
                  final fecha = createdAt is Timestamp ? createdAt.toDate() : DateTime.now();
                  final Map<String, dynamic> payload = Map<String, dynamic>.from(data['data'] ?? {});
                  final lugar = payload['Nombre del establecimiento'] ?? payload['lugar'] ?? 'Sin especificar';
                  final descripcion = payload['Ubicación/Dirección'] ?? payload['descripcion'] ?? '';
                  final visitantes = int.tryParse(payload['Visitantes']?.toString() ?? '') ?? (payload['visitantes'] ?? 0);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lugar Turístico:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  lugar,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.location_on, color: Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Miembro:',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(miembro),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Visitantes:',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      visitantes.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Descripción:',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(descripcion),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),
                                Text(
                                  '${fecha.day}/${fecha.month}/${fecha.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
