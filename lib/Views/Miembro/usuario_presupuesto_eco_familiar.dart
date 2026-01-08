import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_vinculacion/Servicios/presupuesto_mensual_service_eco_familiar.dart';
import 'package:proyecto_vinculacion/Modelos/presupuesto_mensual_model_eco_familiar.dart';

class PresupuestoCompleto extends StatefulWidget {
  final List<Map<String, dynamic>> ingresos;
  final List<Map<String, dynamic>> egresos;
  final List<Map<String, dynamic>> ahorros;
  final List<Map<String, dynamic>> inversiones;

  const PresupuestoCompleto({
    super.key,
    required this.ingresos,
    required this.egresos,
    required this.ahorros,
    required this.inversiones,
  });

  @override
  State<PresupuestoCompleto> createState() => _PresupuestoCompletoState();
}

class _PresupuestoCompletoState extends State<PresupuestoCompleto> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  double _calcularTotal(List<Map<String, dynamic>> lista) {
    return lista.fold(0, (total, item) => total + (item['monto'] as double));
  }

  Future<void> _guardarPresupuesto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final totalIngresos = _calcularTotal(widget.ingresos);
      final totalEgresos = _calcularTotal(widget.egresos);
      final totalAhorros = _calcularTotal(widget.ahorros);
      final totalInversiones = _calcularTotal(widget.inversiones);

      final presupuesto = PresupuestoComunidad(
        userId: userId,
        ingresos: widget.ingresos,
        egresos: widget.egresos,
        ahorros: widget.ahorros,
        inversiones: widget.inversiones,
        totalIngresos: totalIngresos,
        totalEgresos: totalEgresos,
        totalAhorros: totalAhorros,
        totalInversiones: totalInversiones,
        saldoFinal: totalIngresos - totalEgresos,
        fecha: DateTime.now(),
      );

      await PresupuestoService().agregarPresupuesto(presupuesto);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Presupuesto guardado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalIngresos = _calcularTotal(widget.ingresos);
    final totalEgresos = _calcularTotal(widget.egresos);
    final totalAhorros = _calcularTotal(widget.ahorros);
    final balance = totalIngresos - totalEgresos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Presupuesto Mensual',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow('Ingresos totales', totalIngresos, Colors.green),
                  const Divider(),
                  _buildSummaryRow('Egresos totales', totalEgresos, Colors.red),
                  const Divider(),
                  _buildSummaryRow('Ahorros', totalAhorros, Colors.blue),
                  const Divider(),
                  _buildSummaryRow(
                    'Balance neto',
                    balance,
                    balance >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Detalles de Ingresos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...widget.ingresos.map((ingreso) => ListTile(
            title: Text('Ingreso'),
            trailing: Text(
              '\$${ingreso['monto']}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          )),
          const SizedBox(height: 20),
          const Text(
            'Detalles de Egresos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...widget.egresos.map((egreso) => ListTile(
            title: Text('Egreso'),
            trailing: Text(
              '\$${egreso['monto']}',
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          )),
          const SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notas adicionales',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _guardarPresupuesto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Text(
                      'Guardar Presupuesto',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          '\$$amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
