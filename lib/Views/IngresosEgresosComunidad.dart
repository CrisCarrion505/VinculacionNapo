import 'package:flutter/material.dart';

class IngresosEgresosComunidad extends StatefulWidget {
  final TabController tabController;
  final Function(List<Map<String, dynamic>>, List<Map<String, dynamic>>, 
                 List<Map<String, dynamic>>, List<Map<String, dynamic>>) onCalcular;

  const IngresosEgresosComunidad({
    super.key,
    required this.tabController,
    required this.onCalcular,
  });

  @override
  State<IngresosEgresosComunidad> createState() =>
      _IngresosEgresosComunidadState();
}

class _IngresosEgresosComunidadState extends State<IngresosEgresosComunidad> {
  final TextEditingController _ingresoController = TextEditingController();
  final TextEditingController _egresoController = TextEditingController();
  final TextEditingController _ahorreController = TextEditingController();

  List<Map<String, dynamic>> ingresos = [];
  List<Map<String, dynamic>> egresos = [];
  List<Map<String, dynamic>> ahorros = [];
  List<Map<String, dynamic>> inversiones = [];

  void _agregarIngreso() {
    final monto = double.tryParse(_ingresoController.text);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido')),
      );
      return;
    }

    setState(() {
      ingresos.add({
        'monto': monto,
        'fecha': DateTime.now(),
      });
    });

    _ingresoController.clear();
  }

  void _agregarEgreso() {
    final monto = double.tryParse(_egresoController.text);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido')),
      );
      return;
    }

    setState(() {
      egresos.add({
        'monto': monto,
        'fecha': DateTime.now(),
      });
    });

    _egresoController.clear();
  }

  void _agregarAhorro() {
    final monto = double.tryParse(_ahorreController.text);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido')),
      );
      return;
    }

    setState(() {
      ahorros.add({
        'monto': monto,
        'fecha': DateTime.now(),
      });
    });

    _ahorreController.clear();
  }

  double _calcularTotal(List<Map<String, dynamic>> lista) {
    return lista.fold(0, (total, item) => total + (item['monto'] as double));
  }

  void _calcular() {
    // Enviar datos actualizados al padre
    widget.onCalcular(ingresos, egresos, ahorros, inversiones);
  }

  @override
  void dispose() {
    _ingresoController.dispose();
    _egresoController.dispose();
    _ahorreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalIngresos = _calcularTotal(ingresos);
    final totalEgresos = _calcularTotal(egresos);
    final totalAhorros = _calcularTotal(ahorros);
    final balance = totalIngresos - totalEgresos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingresos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ingresoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto de ingreso',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.add_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _agregarIngreso,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Agregar Ingreso'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Egresos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _egresoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto de egreso',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.remove_circle, color: Colors.red),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _agregarEgreso,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Agregar Egreso'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ahorros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ahorreController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto de ahorro',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.savings, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _agregarAhorro,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Agregar Ahorro'),
          ),
          const SizedBox(height: 30),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Ingresos:'),
                      Text(
                        '\$$totalIngresos',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Egresos:'),
                      Text(
                        '\$$totalEgresos',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Balance:'),
                      Text(
                        '\$$balance',
                        style: TextStyle(
                          color: balance >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Ahorros:'),
                      Text(
                        '\$$totalAhorros',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calcular,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.all(15),
              ),
              child: const Text(
                'Continuar al Presupuesto',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
