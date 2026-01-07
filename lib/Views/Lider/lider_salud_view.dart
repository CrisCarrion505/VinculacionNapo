import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiderSaludView extends StatelessWidget {
  const LiderSaludView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salud Comunitaria - Vista Líder')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('salud_comunitaria')
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
              final enfermedad = data['enfermedad'] ?? '';
              final rango = data['rangoEdad'] ?? '';
              final edad = data['edadExacta'] ?? 0;
              final genero = data['genero'] ?? '';
              final sintomas = List<String>.from(data['sintomasSeleccionados'] ?? []);
              final otros = data['otrosSintomas'] ?? '';
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
                          Text(enfermedad, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${fecha.day}/${fecha.month}/${fecha.year}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Usuario: $correo'),
                      const SizedBox(height: 6),
                      Text('Edad: $edad ($rango)'),
                      const SizedBox(height: 6),
                      Text('Género: $genero'),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, children: sintomas.map((s) => Chip(label: Text(s))).toList()),
                      if (otros != null && (otros as String).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Otros: $otros', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
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
