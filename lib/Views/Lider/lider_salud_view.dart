import 'package:flutter/material.dart';
import 'package:proyecto_vinculacion/Modelos/salud_comunitaria_model.dart';
import 'package:proyecto_vinculacion/Servicios/salud_comunitaria_service.dart';

/// Vista de Salud Comunitaria para líderes (dos pestañas)
/// - Pestaña 1: Registros con buscador
/// - Pestaña 2: Estadísticas por rango de edad
class LiderSaludView extends StatefulWidget {
  const LiderSaludView({super.key});

  @override
  State<LiderSaludView> createState() =>
      _LiderSaludViewState();
}

class _LiderSaludViewState
    extends State<LiderSaludView> {
  final SaludComunitariaService _service = SaludComunitariaService();

  // Búsqueda
  final TextEditingController _buscarEnfermedadController = TextEditingController();
  final TextEditingController _buscarRangoEdadController = TextEditingController();
  final TextEditingController _buscarEdadController = TextEditingController();
  List<SaludComunitariaModel> _registrosBuscados = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarTodosRegistros();
  }

  @override
  void dispose() {
    _buscarEnfermedadController.dispose();
    _buscarRangoEdadController.dispose();
    _buscarEdadController.dispose();
    super.dispose();
  }

  /// Cargar todos los registros inicialmente
  Future<void> _cargarTodosRegistros() async {
    setState(() => _cargando = true);
    try {
      _registrosBuscados = await _service.obtenerTodosRegistros();
    } catch (e) {
      _registrosBuscados = [];
    } finally {
      setState(() => _cargando = false);
    }
  }

  /// Aplicar búsqueda con filtros
  Future<void> _aplicarBusqueda() async {
    setState(() => _cargando = true);
    try {
      final enfermedad = _buscarEnfermedadController.text.trim();
      final rangoEdad = _buscarRangoEdadController.text.trim();
      final edadStr = _buscarEdadController.text.trim();
      final edad = edadStr.isEmpty ? null : int.tryParse(edadStr);

      _registrosBuscados = await _service.buscarRegistros(
        enfermedad: enfermedad.isEmpty ? null : enfermedad,
        rangoEdad: rangoEdad.isEmpty ? null : rangoEdad,
        edad: edad,
      );
    } catch (e) {
      _registrosBuscados = [];
    } finally {
      setState(() => _cargando = false);
    }
  }

  /// Limpiar búsqueda
  void _limpiarBusqueda() {
    _buscarEnfermedadController.clear();
    _buscarRangoEdadController.clear();
    _buscarEdadController.clear();
    _cargarTodosRegistros();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Salud Comunitaria - Líder'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Registros'),
              Tab(text: 'Estadísticas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRegistrosTab(),
            _buildEstadisticasTab(),
          ],
        ),
      ),
    );
  }

  // ==================== PESTAÑA 1: REGISTROS ====================
  Widget _buildRegistrosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registros de Salud Comunitaria',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Buscador
          const Text(
            'Buscar registros',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Enfermedad
          TextField(
            controller: _buscarEnfermedadController,
            decoration: InputDecoration(
              labelText: 'Enfermedad',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.health_and_safety),
            ),
          ),
          const SizedBox(height: 8),

          // Rango de Edad y Edad
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _buscarRangoEdadController.text.isEmpty
                      ? null
                      : _buscarRangoEdadController.text,
                  items: ['Bebés', 'Niños', 'Adolescentes', 'Adultos', 'Adultos mayores']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Rango de edad',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      _buscarRangoEdadController.text = val;
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _buscarEdadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Edad exacta',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.cake),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botones
          Row(
            children: [
              ElevatedButton(
                onPressed: _aplicarBusqueda,
                child: const Text('Buscar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _limpiarBusqueda,
                child: const Text('Reset'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Listado
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else if (_registrosBuscados.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No hay registros encontrados'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _registrosBuscados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final reg = _registrosBuscados[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              reg.enfermedad,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${reg.fechaRegistro.day}/${reg.fechaRegistro.month}/${reg.fechaRegistro.year}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Usuario: ${reg.correo}'),
                        Text('Rango de edad: ${reg.rangoEdad}'),
                        Text('Edad exacta: ${reg.edadExacta} años'),
                        if (reg.genero.isNotEmpty)
                          Text('Género: ${reg.genero}'),
                        if (reg.observaciones != null && reg.observaciones!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Observaciones: ${reg.observaciones}',
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==================== PESTAÑA 2: ESTADÍSTICAS ====================
  Widget _buildEstadisticasTab() {
    return FutureBuilder<Map<String, Map<String, int>>>(
      future: _service.obtenerEstadisticasPorRangoEdad(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final estadisticas = snapshot.data ?? {};
        final rangos = ['Bebés', 'Niños', 'Adolescentes', 'Adultos', 'Adultos mayores'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estadísticas por Rango de Edad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...rangos.map((rango) {
                final enfermedadesMap = estadisticas[rango] ?? {};

                // Ordenar enfermedades de mayor a menor
                final enfermedadesOrdenadas = enfermedadesMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                final totalCasos = enfermedadesOrdenadas.fold<int>(
                    0, (sum, e) => sum + e.value);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rango,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Total: $totalCasos',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (enfermedadesOrdenadas.isEmpty)
                          const Text('Sin registros')
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: enfermedadesOrdenadas.map((entry) {
                              final enfermedad = entry.key;
                              final cantidad = entry.value;
                              final porcentaje = (cantidad / totalCasos * 100).toStringAsFixed(1);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(enfermedad),
                                        Text('$cantidad ($porcentaje%)', style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: cantidad / totalCasos,
                                        minHeight: 12,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _getColorPorRango(rango),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Retorna un color diferente según el rango de edad
  Color _getColorPorRango(String rango) {
    switch (rango) {
      case 'Bebés':
        return Colors.blue;
      case 'Niños':
        return Colors.green;
      case 'Adolescentes':
        return Colors.orange;
      case 'Adultos':
        return Colors.red;
      case 'Adultos mayores':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
