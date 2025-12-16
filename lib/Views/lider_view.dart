import 'package:flutter/material.dart';
import 'usuario_liderazgo_comunitario.dart';
import 'usuario_eco_familiar.dart';
import 'usuario_gestion_turistica.dart';

class LiderComunidad extends StatefulWidget {
  const LiderComunidad({super.key});

  @override
  State<LiderComunidad> createState() => _LiderComunidadState();
}

class _LiderComunidadState extends State<LiderComunidad> {
  Widget _buildModuloCard({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, size: 50, color: Colors.white),
                const SizedBox(height: 15),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Lider'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: const Text('Cerrar sesión'),
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.blue],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel de Control - Lider de Comunidad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 1,
                    mainAxisSpacing: 20,
                    children: [
                      _buildModuloCard(
                        titulo: 'Liderazgo Comunitario',
                        descripcion: 'Gestiona ventas y gastos operativos de tu emprendimiento',
                        icono: Icons.people,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LiderazgoComunitario(),
                            ),
                          );
                        },
                      ),
                      _buildModuloCard(
                        titulo: 'Economía Familiar',
                        descripcion: 'Administra ingresos, egresos y presupuesto familiar',
                        icono: Icons.home,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminEcoFamiliar(),
                            ),
                          );
                        },
                      ),
                      _buildModuloCard(
                        titulo: 'Gestión Turística',
                        descripcion: 'Registra y administra tu emprendimiento turístico',
                        icono: Icons.place,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TurismoComunitario(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
