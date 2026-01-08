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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gestión Turística - Líder"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Lugares Turísticos'),
              Tab(text: 'Registro de Visitantes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLugaresTuristicosTab(),
            _buildRegistroVisitantesTab(),
          ],
        ),
      ),
    );
  }

  // ==================== PESTAÑA 1: LUGARES TURÍSTICOS ====================
  Widget _buildLugaresTuristicosTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lugares_turisticos')
          .orderBy('timestamp', descending: true)
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
            final timestamp = data['timestamp'];
            final fecha = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
            final nombre = data['nombreEstablecimiento'] ?? 'Sin especificar';
            final ubicacion = data['ubicacion'] ?? '';
            final tipoServicio = data['tipoServicio'] ?? '';
            final capacidad = data['capacidadAtencion'] ?? '';
            final tarifa = data['tarifasPorServicio'] ?? '';
            final horarios = data['horariosOperacion'] ?? '';
            final numeroRegistro = data['numeroRegistroTuristico'] ?? '';

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
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
                                nombre,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.location_on, color: Colors.orange),
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
                          _buildInfoRow('Registro:', numeroRegistro),
                          _buildInfoRow('Tipo de Servicio:', tipoServicio),
                          _buildInfoRow('Ubicación:', ubicacion),
                          _buildInfoRow('Capacidad:', capacidad),
                          _buildInfoRow('Tarifa:', tarifa),
                          _buildInfoRow('Horarios:', horarios),
                          const SizedBox(height: 8),
                          Text(
                            'Registrado: ${fecha.day}/${fecha.month}/${fecha.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
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
    );
  }

  // ==================== PESTAÑA 2: REGISTRO DE VISITANTES ====================
  Widget _buildRegistroVisitantesTab() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('visitantes')
          .orderBy('timestamp', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No hay registros de visitantes'),
          );
        }

        final registros = snapshot.data!.docs;
        final totalVisitantes = registros.length;

        // Agrupar visitantes por tipoServicio y ubicación
        Map<String, Map<String, List<Map<String, dynamic>>>> servicioUbicacionGrouped = {};
        
        for (var doc in registros) {
          final data = doc.data() as Map<String, dynamic>;
          final tipoServicio = data['tipoServicio'] ?? 'Sin clasificar';
          final ubicacion = data['ubicacion'] ?? 'Sin ubicación';
          
          servicioUbicacionGrouped.putIfAbsent(tipoServicio, () => {});
          servicioUbicacionGrouped[tipoServicio]!.putIfAbsent(ubicacion, () => []);
          servicioUbicacionGrouped[tipoServicio]![ubicacion]!.add(data);
        }

        return Column(
          children: [
            // Contador total de visitantes
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      totalVisitantes.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      'Registros de Visitantes',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            // Listado jerárquico agrupado por servicio y ubicación
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: servicioUbicacionGrouped.entries.map((servicioEntry) {
                  final tipoServicio = servicioEntry.key;
                  final ubicaciones = servicioEntry.value;
                  final totalServicio = ubicaciones.values
                      .fold<int>(0, (total, list) => total + list.length);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              tipoServicio,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Text(
                              totalServicio.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: ubicaciones.entries.map((ubicacionEntry) {
                        final ubicacion = ubicacionEntry.key;
                        final visitantes = ubicacionEntry.value;
                        final totalUbicacion = visitantes.length;

                        return Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                          child: Card(
                            color: Colors.grey[50],
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ExpansionTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ubicacion,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      totalUbicacion.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: visitantes.map((visitanteData) {
                                final timestamp = visitanteData['timestamp'];
                                final fecha = timestamp is Timestamp
                                    ? timestamp.toDate()
                                    : DateTime.now();
                                final nombre = visitanteData['nombre'] ?? 'Desconocido';
                                final opiniones =
                                    visitanteData['opinionesValoraciones'] ?? '';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              nombre,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${fecha.day}/${fecha.month}/${fecha.year}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (opiniones.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Text(
                                            opiniones,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      const Divider(height: 12),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
