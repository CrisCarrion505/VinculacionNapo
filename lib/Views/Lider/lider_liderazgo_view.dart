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

  // Obtener todas las ventas de todos los miembros
  Future<List<Map<String, dynamic>>> _getAllVentas() async {
    List<Map<String, dynamic>> allVentas = [];
    try {
      print('Obteniendo documentos de liderazgo_comunitario...');
      
      // Consultar todos los correos en liderazgo_comunitario (cada doc tiene id = correo)
      final membersSnapshot = await FirebaseFirestore.instance
          .collection('liderazgo_comunitario')
          .get();

      print('Documentos encontrados: ${membersSnapshot.docs.length}');

      // Para cada miembro, obtener sus ventas
      for (var memberDoc in membersSnapshot.docs) {
        final correo = memberDoc.id;
        print('Obteniendo ventas de: $correo');
        
        try {
          final ventasSnapshot = await FirebaseFirestore.instance
              .collection('liderazgo_comunitario')
              .doc(correo)
              .collection('ventas')
              .get();

          print('  Ventas encontradas: ${ventasSnapshot.docs.length}');

          for (var ventaDoc in ventasSnapshot.docs) {
            final data = ventaDoc.data();
            final timestamp = (data['timestamp'] is Timestamp) 
                ? data['timestamp'] as Timestamp 
                : Timestamp.now();
            
            // Las ventas están en una lista dentro del documento
            final ventasList = List<Map<String, dynamic>>.from(data['ventas'] ?? []);
            for (var venta in ventasList) {
              allVentas.add({
                'miembro': correo,
                'producto': venta['producto'] ?? 'Sin especificar',
                'cantidad': venta['cantidad'] ?? 0,
                'precio': venta['precio'] ?? 0,
                'total': venta['total'] ?? 0,
                'timestamp': timestamp,
              });
            }
          }
        } catch (e) {
          print('Error obteniendo ventas de $correo: $e');
        }
      }
      
      // Ordenar por timestamp de mayor a menor
      if (allVentas.isNotEmpty) {
        allVentas.sort((a, b) {
          final tsA = a['timestamp'] as Timestamp;
          final tsB = b['timestamp'] as Timestamp;
          return tsB.compareTo(tsA);
        });
      }
      print('Total ventas compiladas: ${allVentas.length}');
    } catch (e) {
      print('Error general en _getAllVentas: $e');
      rethrow;
    }
    return allVentas;
  }

  // Obtener todos los gastos de todos los miembros
  Future<List<Map<String, dynamic>>> _getAllGastos() async {
    List<Map<String, dynamic>> allGastos = [];
    try {
      print('Obteniendo documentos de liderazgo_comunitario...');
      
      final membersSnapshot = await FirebaseFirestore.instance
          .collection('liderazgo_comunitario')
          .get();

      print('Documentos encontrados: ${membersSnapshot.docs.length}');

      for (var memberDoc in membersSnapshot.docs) {
        final correo = memberDoc.id;
        print('Obteniendo gastos de: $correo');
        
        try {
          final gastosSnapshot = await FirebaseFirestore.instance
              .collection('liderazgo_comunitario')
              .doc(correo)
              .collection('gastos')
              .get();

          print('  Gastos encontrados: ${gastosSnapshot.docs.length}');

          for (var gastoDoc in gastosSnapshot.docs) {
            final data = gastoDoc.data();
            final timestamp = (data['timestamp'] is Timestamp) 
                ? data['timestamp'] as Timestamp 
                : Timestamp.now();
            
            // Los gastos están en una lista dentro del documento
            final gastosList = List<Map<String, dynamic>>.from(data['gastos'] ?? []);
            for (var gasto in gastosList) {
              allGastos.add({
                'miembro': correo,
                'concepto': gasto['concepto'] ?? gasto.entries.map((e) => '${e.key}: ${e.value}').join(', ') ?? 'Sin especificar',
                'monto': 0.0, // Los gastos están separados por categoría
                'timestamp': timestamp,
              });
            }
          }
        } catch (e) {
          print('Error obteniendo gastos de $correo: $e');
        }
      }
      
      // Ordenar por timestamp de mayor a menor
      if (allGastos.isNotEmpty) {
        allGastos.sort((a, b) {
          final tsA = a['timestamp'] as Timestamp;
          final tsB = b['timestamp'] as Timestamp;
          return tsB.compareTo(tsA);
        });
      }
      print('Total gastos compilados: ${allGastos.length}');
    } catch (e) {
      print('Error general en _getAllGastos: $e');
      rethrow;
    }
    return allGastos;
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllVentas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final allVentas = snapshot.data ?? [];

        if (allVentas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                const Text('No hay registros de ventas guardados'),
                const SizedBox(height: 8),
                const Text(
                  'Los miembros deben guardar ventas en su sección\nde Liderazgo Comunitario',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allVentas.length,
          itemBuilder: (context, index) {
            final venta = allVentas[index];
            final miembro = venta['miembro'] as String;
            final fecha = (venta['timestamp'] as Timestamp).toDate();
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllGastos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final allGastos = snapshot.data ?? [];

        if (allGastos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                const Text('No hay registros de gastos guardados'),
                const SizedBox(height: 8),
                const Text(
                  'Los miembros deben guardar gastos en su sección\nde Liderazgo Comunitario',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allGastos.length,
          itemBuilder: (context, index) {
            final gasto = allGastos[index];
            final miembro = gasto['miembro'] as String;
            final fecha = (gasto['timestamp'] as Timestamp).toDate();
            final concepto = gasto['concepto'] ?? 'Sin especificar';
            final monto = gasto['monto'] ?? 0;

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
                          Text('Concepto: $concepto', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            'Monto: \$$monto',
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

