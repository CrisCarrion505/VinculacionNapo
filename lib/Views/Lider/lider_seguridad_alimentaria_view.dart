import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_vinculacion/Modelos/seguridad_alimentaria_model.dart';
import 'package:proyecto_vinculacion/Servicios/seguridad_alimentaria_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Vista de Seguridad Alimentaria para usuarios con rol "Líder".
///
/// Esta pantalla contiene exactamente dos pestañas:
///  - Registro de Seguridad Alimentaria
///  - Estadísticas de Alimentos Escasos
class LiderSeguridadAlimentariaView extends StatefulWidget {
  const LiderSeguridadAlimentariaView({super.key});

  @override
  State<LiderSeguridadAlimentariaView> createState() =>
      _LiderSeguridadAlimentariaViewState();
}

class _LiderSeguridadAlimentariaViewState
    extends State<LiderSeguridadAlimentariaView> {
  final SeguridadAlimentariaService _service = SeguridadAlimentariaService();

  // Nota: acceso abierto — ya no se verifica rol (se permite entrada directa)

  // Búsqueda (líder solo ve registros, no puede crear)
  final TextEditingController _buscarAlimentoController = TextEditingController();
  final TextEditingController _buscarProveedorController = TextEditingController();
  final TextEditingController _buscarTelefonoController = TextEditingController();
  List<SeguridadAlimentariaModel> _reportesListado = [];
  bool _listando = false;

  // Ubicaciones / Calles de Pano (Tena) - listado representativo (puede usarse en filtros)
  final List<String> _ubicacionesPano = [
    'Centro',
    'Avenida Orellana',
    'Avenida Amazonas',
    'Calle Sucre',
    'Calle Bolívar',
    'Calle Guayas',
    'Calle Mejía',
    'Calle Juan Montalvo',
    'Calle 10 de Agosto',
    'Barrio La Merced',
    'Sector El Arenal',
    'Puerto Bolívar',
    'Otra',
  ];

  @override
  void initState() {
    super.initState();
    _cargarListado();
  }

  @override
  void dispose() {
    _buscarAlimentoController.dispose();
    _buscarProveedorController.dispose();
    _buscarTelefonoController.dispose();
    super.dispose();
  }

  // Acceso ya no verificado aquí — se asume permiso para acceder a la vista

  // --- Logica: listado y búsqueda ------------------------------------
  Future<void> _cargarListado() async {
    setState(() => _listando = true);
    try {
      _reportesListado = await _service.obtenerTodosReportes();
    } catch (e) {
      _reportesListado = [];
    } finally {
      setState(() => _listando = false);
    }
  }

  Future<void> _aplicarBusqueda() async {
    setState(() => _listando = true);
    try {
      final alimentos = _buscarAlimentoController.text.trim();
      final proveedor = _buscarProveedorController.text.trim();
      final telefono = _buscarTelefonoController.text.trim();
      _reportesListado = await _service.buscarReportes(
          alimento: alimentos.isEmpty ? null : alimentos,
          proveedor: proveedor.isEmpty ? null : proveedor,
          telefono: telefono.isEmpty ? null : telefono);
    } catch (e) {
      _reportesListado = [];
    } finally {
      setState(() => _listando = false);
    }
  }

  // El líder no puede crear ni eliminar reportes desde esta vista.

  // --- Estadísticas --------------------------------------------------
  /// Calcula y retorna un mapa con llave = alimento y valor = mapa de proveedor->conteo
  Map<String, Map<String, int>> _calcularEstadisticasPorProveedor(
      List<SeguridadAlimentariaModel> lista) {
    final Map<String, Map<String, int>> result = {};

    for (var r in lista) {
      final alimento = r.alimentoEscaso;
      final proveedorKey = '${r.nombreProveedor} (${r.telefonoProveedor})';
      result.putIfAbsent(alimento, () => {});
      final mapaProv = result[alimento]!;
      mapaProv[proveedorKey] = (mapaProv[proveedorKey] ?? 0) + 1;
    }

    return result;
  }

  /// Retorna un color distinto para cada alimento
  Color _getColorPorAlimento(String alimento) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.yellow,
      Colors.lime,
      Colors.green,
      Colors.cyan,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
    ];
    return colors[alimento.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seguridad Alimentaria - Líder'),
          bottom: const TabBar(tabs: [Tab(text: 'Registro'), Tab(text: 'Estadísticas')]),
        ),
        body: TabBarView(children: [_buildRegistroTab(), _buildEstadisticasTab()]),
      ),
    );
  }

  // ----------------- UI: Registro Tab --------------------------------
  Widget _buildRegistroTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Registros de Seguridad Alimentaria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // Buscador
        const Text('Buscar registros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _buscarAlimentoController, decoration: const InputDecoration(labelText: 'Alimento'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _buscarProveedorController, decoration: const InputDecoration(labelText: 'Proveedor'))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _buscarTelefonoController, decoration: const InputDecoration(labelText: 'Teléfono'))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _aplicarBusqueda, child: const Text('Buscar')),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: _cargarListado, child: const Text('Reset')),
        ]),

        const SizedBox(height: 12),
        if (_listando) const Center(child: CircularProgressIndicator()),
        if (!_listando && _reportesListado.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(12), child: Text('No hay registros'))),
        if (!_listando && _reportesListado.isNotEmpty) ...[
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reportesListado.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final r = _reportesListado[index];
              return Card(
                child: ListTile(
                  title: Text(r.alimentoEscaso),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Proveedor: ${r.nombreProveedor}'),
                    Text('Tel: ${r.telefonoProveedor} • ${r.cantidadNecesaria} ${r.unidad}'),
                    Text('Ubicación: ${r.ubicacion}'),
                    Text('Fecha: ${r.fechaRegistro.day}/${r.fechaRegistro.month}/${r.fechaRegistro.year}', style: TextStyle(color: Colors.grey[600])),
                  ]),
                ),
              );
            },
          ),
        ]
      ]),
    );
  }

  // ----------------- UI: Estadísticas Tab -----------------------------
  Widget _buildEstadisticasTab() {
    return FutureBuilder<List<SeguridadAlimentariaModel>>(
      future: _service.obtenerTodosReportes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        final lista = snapshot.data ?? [];

        // Estadística por alimento: total de registros
        final Map<String, int> totalPorAlimento = {};
        for (var r in lista) {
          totalPorAlimento[r.alimentoEscaso] = (totalPorAlimento[r.alimentoEscaso] ?? 0) + 1;
        }

        // Ordenar alimentos de más escaso a menos
        final alimentosOrdenados = totalPorAlimento.keys.toList()
          ..sort((a, b) => (totalPorAlimento[b] ?? 0).compareTo(totalPorAlimento[a] ?? 0));

        final statsPorProveedor = _calcularEstadisticasPorProveedor(lista);

        // Calcular el máximo para normalizar las barras
        final maxRegistros = alimentosOrdenados.isEmpty
            ? 1
            : (totalPorAlimento[alimentosOrdenados.first] ?? 1);

        // Lista con barras + tarjetas
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECCIÓN: BARRAS ESTADÍSTICAS
              const Text('Alimentos más escasos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (alimentosOrdenados.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: Text('No hay datos disponibles')))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: alimentosOrdenados.map((alimento) {
                    final total = totalPorAlimento[alimento] ?? 0;
                    final porcentaje = (total / maxRegistros).clamp(0.0, 1.0);
                    final color = _getColorPorAlimento(alimento);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(alimento, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('$total registros', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ]),
                          const SizedBox(height: 6),
                          // Barra visual
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: porcentaje,
                              minHeight: 20,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // SECCIÓN: TARJETAS DETALLADAS
              const Text('Detalle por proveedor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...alimentosOrdenados.map((alimento) {
                final total = totalPorAlimento[alimento] ?? 0;
                final proveedoresMap = statsPorProveedor[alimento] ?? {};

                // Lista de proveedores ordenada por mayor a menor
                final proveedoresOrdenados = proveedoresMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('$alimento', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Registros: $total', style: const TextStyle(color: Colors.grey)),
                      ]),
                      const SizedBox(height: 8),
                      const Text('Proveedores (ordenados por número de registros):', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DataTable(
                        columns: const [DataColumn(label: Text('Proveedor')), DataColumn(label: Text('Teléfono')), DataColumn(label: Text('Registros'))],
                        rows: proveedoresOrdenados.map((e) {
                          final key = e.key;
                          final match = RegExp(r'^(.*) \((.*)\) ').firstMatch(key + '\u0000');
                          String nombre = key;
                          String telefono = '';
                          if (match != null) {
                            nombre = match.group(1) ?? key;
                            telefono = match.group(2) ?? '';
                          } else {
                            final parts = key.split('(');
                            nombre = parts.first.trim();
                            telefono = parts.length > 1 ? parts.last.replaceAll(')', '').trim() : '';
                          }
                          return DataRow(cells: [DataCell(Text(nombre)), DataCell(Text(telefono)), DataCell(Text(e.value.toString()))]);
                        }).toList(),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
