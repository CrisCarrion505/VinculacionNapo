import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiderEcoFamiliarView extends StatefulWidget {
  const LiderEcoFamiliarView({super.key});

  @override
  State<LiderEcoFamiliarView> createState() => _LiderEcoFamiliarViewState();
}

class _LiderEcoFamiliarViewState extends State<LiderEcoFamiliarView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Economía Familiar - Vista Líder"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('presupuestos_comunidad')
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
              child: Text('No hay registros de economía familiar'),
            );
          }

          final registros = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: registros.length,
            itemBuilder: (context, index) {
              final data = registros[index].data() as Map<String, dynamic>;
              final ingresos = data['totalIngresos'] ?? 0.0;
              final egresos = data['totalEgresos'] ?? 0.0;
              final balance = ingresos - egresos;
              final fecha = data['fecha'] is Timestamp
                  ? (data['fecha'] as Timestamp).toDate()
                  : DateTime.now();
              final miembro = data['userId'] ?? 'Desconocido';

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
                                  'Miembro:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  miembro,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Fecha:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${fecha.day}/${fecha.month}/${fecha.year}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatistic(
                            'Ingresos',
                            '\$$ingresos',
                            Colors.green,
                          ),
                          _buildStatistic(
                            'Egresos',
                            '\$$egresos',
                            Colors.red,
                          ),
                          _buildStatistic(
                            'Balance',
                            '\$$balance',
                            balance >= 0 ? Colors.blue : Colors.orange,
                          ),
                        ],
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

  Widget _buildStatistic(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
