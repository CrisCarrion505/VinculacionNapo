import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_vinculacion/Servicios/presupuesto_mensual_service_eco_familiar.dart';
import 'package:proyecto_vinculacion/Modelos/presupuesto_mensual_model_eco_familiar.dart';
import 'IngresosEgresosComunidad.dart';
import 'usuario_presupuesto_eco_familiar.dart';

class AdminEcoFamiliar extends StatefulWidget {
  const AdminEcoFamiliar({super.key});

  @override
  State<AdminEcoFamiliar> createState() => _AdminEcoFamiliarState();
}

class _AdminEcoFamiliarState extends State<AdminEcoFamiliar> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Map<String, dynamic>> ingresos = [];
  List<Map<String, dynamic>> egresos = [];
  List<Map<String, dynamic>> ahorros = [];
  List<Map<String, dynamic>> inversiones = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void actualizarDatos(List<Map<String, dynamic>> nuevosIngresos, List<Map<String, dynamic>> nuevosEgresos, List<Map<String, dynamic>> nuevosAhorros, List<Map<String, dynamic>> nuevosInversiones) {
    setState(() {
      ingresos = nuevosIngresos;
      egresos = nuevosEgresos;
      ahorros = nuevosAhorros;
      inversiones = nuevosInversiones;  
    });

    // Cambiar a la pestaña de Presupuesto
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          centerTitle: true,
          elevation: 4,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          title: const Text(
            "Administración Economía Familiar",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.shopping_cart), text: "Ingresos, Egresos y Ahorros"),
              Tab(icon: Icon(Icons.monetization_on), text: "Presupuesto mensual"),
              Tab(icon: Icon(Icons.history), text: "Historial"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          IngresosEgresosComunidad(tabController: _tabController, onCalcular: actualizarDatos),
          PresupuestoCompleto(ingresos: ingresos, egresos: egresos, ahorros: ahorros, inversiones: inversiones),
          _buildHistorialPresupuestos(),
        ],
      ),
    );
  }

  Widget _buildHistorialPresupuestos() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Usuario no autenticado'));

    return FutureBuilder<List<PresupuestoComunidad>>(
      future: PresupuestoService().obtenerPresupuestos(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) return const Center(child: Text('No hay presupuestos guardados'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final p = items[index];
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
                        const Text('Fecha:'),
                        Text('${p.fecha.day}/${p.fecha.month}/${p.fecha.year}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Ingresos: \$${p.totalIngresos}', style: const TextStyle(color: Colors.green)),
                    Text('Egresos: \$${p.totalEgresos}', style: const TextStyle(color: Colors.red)),
                    Text('Ahorros: \$${p.totalAhorros}', style: const TextStyle(color: Colors.blue)),
                    const SizedBox(height: 8),
                    Text('Saldo final: \$${p.saldoFinal}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
