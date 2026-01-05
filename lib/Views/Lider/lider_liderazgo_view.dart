import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiderLiderazgoView extends StatefulWidget {
  const LiderLiderazgoView({super.key});

  @override
  State<LiderLiderazgoView> createState() => _LiderLiderazgoViewState();
}

class _LiderLiderazgoViewState extends State<LiderLiderazgoView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liderazgo Comunitario - Vista Líder"),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildRegistroVentasView(),
          _buildGastosOperativosView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) => _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Gastos',
          ),
        ],
      ),
    );
  }

  Widget _buildRegistroVentasView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('ventas')
          .orderBy('fecha_registro', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No hay registros de ventas'),
          );
        }

        final registros = snapshot.data!.docs;

        final allVentas = <Map<String, dynamic>>[];
        for (var doc in registros) {
          final data = doc.data() as Map<String, dynamic>;
          final correo = data['correo'] ?? 'Desconocido';
          final ventas = List<Map<String, dynamic>>.from(data['ventas'] ?? []);
          final fechaRegistro = DateTime.tryParse(data['fecha_registro'] ?? '') ?? DateTime.now();
          for (var venta in ventas) {
            allVentas.add({
              'miembro': correo,
              'fecha': venta['fecha'] ?? fechaRegistro.toIso8601String(),
              'producto': venta['producto'] ?? 'Sin especificar',
              'cantidad': venta['cantidad'] ?? 0,
              'precio': venta['precio'] ?? 0,
              'total': venta['total'] ?? 0,
            });
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allVentas.length,
          itemBuilder: (context, index) {
            final venta = allVentas[index];
            final miembro = venta['miembro'] as String;
            final fecha = DateTime.tryParse(venta['fecha']?.toString() ?? '') ?? DateTime.now();
            final producto = venta['producto'] ?? 'Sin especificar';
            final cantidad = venta['cantidad'] ?? 0;
            final precio = venta['precio'] ?? 0;
            final total = venta['total'] ?? 0;

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Miembro:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(miembro, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Fecha:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('${fecha.day}/${fecha.month}/${fecha.year}'),
                          ],
                        ),
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
                          Text('Producto: $producto', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Cantidad: $cantidad'),
                          Text('Precio unitario: \$$precio'),
                          const SizedBox(height: 8),
                          Text(
                            'Total: \$$total',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
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

  Widget _buildGastosOperativosView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('gastos')
          .orderBy('fecha_registro', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No hay registros de gastos'),
          );
        }

        final registros = snapshot.data!.docs;

        final allGastos = <Map<String, dynamic>>[];
        for (var doc in registros) {
          final data = doc.data() as Map<String, dynamic>;
          final correo = data['correo'] ?? 'Desconocido';
          final gastos = List<Map<String, dynamic>>.from(data['gastos'] ?? []);
          final fechaRegistro = DateTime.tryParse(data['fecha_registro'] ?? '') ?? DateTime.now();
          for (var gasto in gastos) {
            allGastos.add({
              'miembro': correo,
              'fecha': gasto['fecha'] ?? fechaRegistro.toIso8601String(),
              'materia_prima': double.tryParse(gasto['materia_prima']?.toString() ?? '0') ?? 0,
              'salarios': double.tryParse(gasto['salarios']?.toString() ?? '0') ?? 0,
              'servicios_publicos': double.tryParse(gasto['servicios_publicos']?.toString() ?? '0') ?? 0,
              'comisiones': double.tryParse(gasto['comisiones']?.toString() ?? '0') ?? 0,
              'publicidad': double.tryParse(gasto['publicidad']?.toString() ?? '0') ?? 0,
              'alquiler': double.tryParse(gasto['alquiler']?.toString() ?? '0') ?? 0,
            });
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allGastos.length,
          itemBuilder: (context, index) {
            final gasto = allGastos[index];
            final miembro = gasto['miembro'] as String;
            final fecha = DateTime.tryParse(gasto['fecha']?.toString() ?? '') ?? DateTime.now();
            final materiaPrima = gasto['materia_prima'] ?? 0;
            final salarios = gasto['salarios'] ?? 0;
            final otros = (gasto['servicios_publicos'] ?? 0) +
                (gasto['comisiones'] ?? 0) +
                (gasto['publicidad'] ?? 0) +
                (gasto['alquiler'] ?? 0);

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Miembro:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(miembro, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Fecha:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('${fecha.day}/${fecha.month}/${fecha.year}'),
                          ],
                        ),
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
                          Text('Materia Prima: \$$materiaPrima'),
                          const SizedBox(height: 8),
                          Text('Salarios: \$$salarios'),
                          const SizedBox(height: 8),
                          Text('Otros Gastos: \$$otros'),
                          const Divider(),
                          Text(
                            'Total: \$${materiaPrima + salarios + otros}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
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
}
