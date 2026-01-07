import 'package:flutter/material.dart';
import 'Lider/lider_eco_familiar_view.dart';
import 'Lider/lider_liderazgo_view.dart';
import 'Lider/lider_gestion_turistica_view.dart';
import 'Lider/lider_salud_view.dart';
import 'Lider/lider_seguridad_alimentaria_view.dart';

class DashboardLider extends StatelessWidget {
  const DashboardLider({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Líder'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.teal],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.92,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Servicios ofrecidos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.86,
                          children: [
                            _buildModuleCard(
                              context,
                              title: 'Economía Familiar',
                              description: 'Observa registros de economía familiar',
                              icon: Icons.trending_up,
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LiderEcoFamiliarView(),
                                  ),
                                );
                              },
                            ),
                            _buildModuleCard(
                              context,
                              title: 'Liderazgo Comunitario',
                              description: 'Observa registros de ventas y gastos',
                              icon: Icons.people,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LiderLiderazgoView(),
                                  ),
                                );
                              },
                            ),
                            _buildModuleCard(
                              context,
                              title: 'Gestión Turística',
                              description: 'Observa lugares turísticos registrados',
                              icon: Icons.location_on,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LiderGestionTuristicaView(),
                                  ),
                                );
                              },
                            ),
                            _buildModuleCard(
                              context,
                              title: 'Salud Comunitaria',
                              description: 'Ver registros de salud de miembros',
                              icon: Icons.health_and_safety,
                              color: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LiderSaludView(),
                                  ),
                                );
                              },
                            ),
                            _buildModuleCard(
                              context,
                              title: 'Seguridad Alimentaria',
                              description: 'Ver reportes alimentarios',
                              icon: Icons.lunch_dining,
                              color: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LiderSeguridadAlimentariaView(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F8),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 0,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.teal),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
