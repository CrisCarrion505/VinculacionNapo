import 'package:flutter/material.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        title: const Text("Administración Economia Familiar"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_cart), text: "Ingresos, Egresos y Ahorros"),
            Tab(icon: Icon(Icons.monetization_on), text: "Presupuesto mensual"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          IngresosEgresosComunidad(tabController: _tabController, onCalcular: actualizarDatos),
          PresupuestoCompleto(ingresos: ingresos, egresos: egresos, ahorros: ahorros, inversiones: inversiones),
        ],
      ),
    );
  }
}
