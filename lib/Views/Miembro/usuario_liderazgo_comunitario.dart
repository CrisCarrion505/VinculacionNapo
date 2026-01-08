import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_vinculacion/Modelos/liderazgo_model.dart';
import 'package:proyecto_vinculacion/Servicios/liderazgo_service.dart';
import 'package:proyecto_vinculacion/validar_cedula_ecuador.dart';

class LiderazgoComunitario extends StatefulWidget {
  const LiderazgoComunitario({super.key});

  @override
  State<LiderazgoComunitario> createState() => _LiderazgoComunitarioState();
}

class _LiderazgoComunitarioState extends State<LiderazgoComunitario> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controladores para Registro de Ventas
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _papeletaController = TextEditingController();
  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _registroVentasController = TextEditingController();
  final TextEditingController _fechaVentaController = TextEditingController();
  final TextEditingController _productoController = TextEditingController();
  final TextEditingController _servicioController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  
  // Controladores para Gastos Operativos
  final TextEditingController _materiaPrimaController = TextEditingController();
  final TextEditingController _salariosController = TextEditingController();
  final TextEditingController _serviciosPublicosController = TextEditingController();
  final TextEditingController _comisionesController = TextEditingController();
  final TextEditingController _publicidadController = TextEditingController();
  final TextEditingController _alquilerController = TextEditingController();
  
  // Estados de validación
  String? _cedulaError;
  String? _rucError;
  String? _productoServicioError;
  String? _materiaPrimaSalariosError;
  
  final List<Map<String, dynamic>> _ventas = [];
  final List<Map<String, dynamic>> _gastos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Agregar listeners para validación en tiempo real
    _cedulaController.addListener(_validarCedula);
    _rucController.addListener(_validarRUC);
  }

  void _validarCedula() {
    final texto = _cedulaController.text.trim();
    if (texto.isNotEmpty) {
      final msg = ValidarCedulaEcuador.validarConMensaje(texto);
      setState(() {
        _cedulaError = msg;
        // si hay cédula válida o no vacía, RUC deja de ser obligatorio
        _rucError = null;
      });
    } else {
      setState(() {
        _cedulaError = null;
      });
      // si la cédula se borra y hay texto en ruc, validar ruc
      if (_rucController.text.isNotEmpty) _validarRUC();
    }
  }

  void _validarRUC() {
    final texto = _rucController.text.trim();
    if (texto.isNotEmpty) {
      if (texto.length != 13) {
        setState(() {
          _rucError = 'El RUC debe tener 13 dígitos';
          // si hay RUC, cédula deja de ser obligatoria
          _cedulaError = null;
        });
      } else {
        setState(() {
          _rucError = null;
          _cedulaError = null;
        });
      }
    } else {
      setState(() {
        _rucError = null;
      });
      // si ruc se borra y hay texto en cedula, validar cedula
      if (_cedulaController.text.isNotEmpty) _validarCedula();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cedulaController.dispose();
    _papeletaController.dispose();
    _rucController.dispose();
    _registroVentasController.dispose();
    _fechaVentaController.dispose();
    _productoController.dispose();
    _servicioController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _materiaPrimaController.dispose();
    _salariosController.dispose();
    _serviciosPublicosController.dispose();
    _comisionesController.dispose();
    _publicidadController.dispose();
    _alquilerController.dispose();
    super.dispose();
  }

  void _agregarVenta() {
    // Validar que haya al menos un producto o servicio
    if (_productoController.text.isEmpty && _servicioController.text.isEmpty) {
      setState(() {
        _productoServicioError = 'Ingrese al menos un producto o servicio';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese al menos un producto o servicio"))
      );
      return;
    } else {
      setState(() {
        _productoServicioError = null;
      });
    }

    // Validar cantidad y precio
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    final precio = double.tryParse(_precioController.text) ?? 0;
    
    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La cantidad debe ser mayor a 0"))
      );
      return;
    }

    if (precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El precio debe ser mayor a 0"))
      );
      return;
    }

    final total = cantidad * precio;

    // Si el número de registro está vacío, calcular el siguiente contador automáticamente
    if (_registroVentasController.text.trim().isEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          final correo = user.email!.toLowerCase();
          FirebaseFirestore.instance
              .collection('liderazgo_comunitario')
              .doc(correo)
              .collection('ventas')
              .get()
              .then((ventasSnapshot) {
            final nextNum = ventasSnapshot.size + 1;
            setState(() {
              _registroVentasController.text = nextNum.toString();
            });
          });
        }
      } catch (_) {
        // Silenciar error; no bloquear la agregación de la venta
      }
    }

    setState(() {
      _ventas.add({
        'fecha': _fechaVentaController.text.isNotEmpty ? _fechaVentaController.text : 
                DateTime.now().toString().split(' ')[0],
        'producto': _productoController.text,
        'servicio': _servicioController.text,
        'cantidad': cantidad,
        'precio': precio,
        'total': total,
      });
    });

    _fechaVentaController.clear();
    _productoController.clear();
    _servicioController.clear();
    _cantidadController.clear();
    _precioController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Venta agregada correctamente"))
    );
  }

  void _agregarGasto() {
    // Validar que haya al menos un gasto significativo
    if (_materiaPrimaController.text.isEmpty && _salariosController.text.isEmpty) {
      setState(() {
        _materiaPrimaSalariosError = 'Ingrese al menos materia prima o salarios';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese al menos materia prima o salarios"))
      );
      return;
    } else {
      setState(() {
        _materiaPrimaSalariosError = null;
      });
    }

    // Validar que los valores sean numéricos y mayores a 0
    final materiaPrima = double.tryParse(_materiaPrimaController.text) ?? 0;
    final salarios = double.tryParse(_salariosController.text) ?? 0;
    
    if (materiaPrima < 0 || salarios < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Los valores no pueden ser negativos"))
      );
      return;
    }

    setState(() {
      _gastos.add({
        'materia_prima': _materiaPrimaController.text,
        'salarios': _salariosController.text,
        'servicios_publicos': _serviciosPublicosController.text,
        'comisiones': _comisionesController.text,
        'publicidad': _publicidadController.text,
        'alquiler': _alquilerController.text,
        'fecha': DateTime.now().toString().split(' ')[0],
      });
    });

    _materiaPrimaController.clear();
    _salariosController.clear();
    _serviciosPublicosController.clear();
    _comisionesController.clear();
    _publicidadController.clear();
    _alquilerController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gasto agregado correctamente"))
    );
  }

  Future<void> _guardarRegistroVentas() async {
    // Validar que exista al menos cédula o RUC (advertencia, no marcar en rojo)
    final cedula = _cedulaController.text.trim();
    final ruc = _rucController.text.trim();

    if (cedula.isEmpty && ruc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Advertencia: ingrese Cédula o RUC (al menos uno)"))
      );
      return;
    }

    // Validar formato si se ingresó cédula
    if (cedula.isNotEmpty) {
      final cedulaMsg = ValidarCedulaEcuador.validarConMensaje(cedula);
      if (cedulaMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cédula inválida: $cedulaMsg'))
        );
        return;
      }
    }

    // Validar RUC si se ingresó
    if (ruc.isNotEmpty && ruc.length != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RUC inválido: debe tener 13 dígitos'))
      );
      return;
    }

    if (_ventas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agregue al menos una venta"))
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario no autenticado. Inicie sesión."))
      );
      return;
    }

    final correo = user.email!.toLowerCase();

    // Si no tiene número de registro, calcular contador automático
    if (_registroVentasController.text.trim().isEmpty) {
      try {
        final ventasSnapshot = await FirebaseFirestore.instance
            .collection('liderazgo_comunitario')
            .doc(correo)
            .collection('ventas')
            .get();
        final nextNum = ventasSnapshot.size + 1;
        _registroVentasController.text = nextNum.toString();
      } catch (_) {
        // Si falla, dejar en blanco y seguir (no bloquear)
      }
    }

    final registro = RegistroVentasModel(
      correo: correo,
      cedula: _cedulaController.text,
      papeleta: _papeletaController.text,
      ruc: _rucController.text,
      registroVentas: _registroVentasController.text,
      ventas: _ventas,
    );

    try {
      await LiderazgoService().addRegistroVentas(registro, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro de ventas guardado exitosamente"))
      );
      _limpiarCamposVentas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"))
      );
    }
  }

  Future<void> _guardarGastos() async {
    if (_gastos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay gastos para guardar"))
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario no autenticado. Inicie sesión."))
      );
      return;
    }

    final correo = user.email!.toLowerCase();

    final gastosOperativos = GastosOperativosModel(
      correo: correo,
      gastos: _gastos,
    );

    try {
      await LiderazgoService().addGastosOperativos(gastosOperativos, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gastos operativos guardados exitosamente"))
      );
      setState(() {
        _gastos.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"))
      );
    }
  }

    void _limpiarCamposVentas() {
    _cedulaController.clear();
    _papeletaController.clear();
    _rucController.clear();
    _registroVentasController.clear();
    setState(() {
      _ventas.clear();
      _cedulaError = null;
      _rucError = null;
      _productoServicioError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administración de Liderazgo Comunitario"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.point_of_sale), text: "Ventas"),
            Tab(icon: Icon(Icons.payment), text: "Gastos"),
            Tab(icon: Icon(Icons.history), text: "Historial"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegistroVentas(),
          _buildGastosOperativos(),
          _buildHistorialLiderazgo(),
        ],
      ),
    );
  }

  Widget _buildHistorialLiderazgo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Usuario no autenticado'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Registros de Ventas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FutureBuilder<List<RegistroVentasModel>>(
            future: LiderazgoService().getRegistrosVentas(user.email ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                );
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No hay registros de ventas'),
                );
              }
              return Column(
                children: list.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Cédula: ${r.cedula}'),
                    subtitle: Text('Ventas: ${r.ventas.length}'),
                    trailing: const Icon(Icons.receipt),
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Gastos Operativos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FutureBuilder<List<GastosOperativosModel>>(
            future: LiderazgoService().getGastosOperativos(user.email ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                );
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No hay gastos operativos'),
                );
              }
              return Column(
                children: list.map((g) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: const Text('Gastos Operativos'),
                    subtitle: Text('Items: ${g.gastos.length}'),
                    trailing: const Icon(Icons.payment),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegistroVentas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Registro de Ventas",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Campos obligatorios marcados en rojo
          _buildTextFieldObligatorio(
            "Cédula *", 
            _cedulaController, 
            Icons.badge, 
            TextInputType.number,
            errorText: _cedulaError,
          ),
          _buildTextField(
            "Papeleta", 
            _papeletaController, 
            Icons.how_to_vote, 
            TextInputType.text
          ),
          _buildTextFieldObligatorio(
            "RUC *", 
            _rucController, 
            Icons.numbers, 
            TextInputType.number,
            errorText: _rucError,
          ),
          _buildTextField(
            "N° Registro Ventas", 
            _registroVentasController, 
            Icons.receipt_long, 
            TextInputType.text
          ),
          
          const Divider(height: 30, thickness: 2),
          const Text(
            "Detalle de Venta",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          
          // Fecha con DatePicker (readOnly)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: TextField(
              controller: _fechaVentaController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha de Venta',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 5),
                );
                if (picked != null) {
                  _fechaVentaController.text = '${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
                }
              },
            ),
          ),
          _buildTextField(
            "Producto vendido", 
            _productoController, 
            Icons.shopping_bag, 
            TextInputType.text,
            errorText: _productoServicioError,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ ]"))],
          ),
          _buildTextField(
            "Servicio vendido", 
            _servicioController, 
            Icons.room_service, 
            TextInputType.text,
            errorText: _productoServicioError,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ ]"))],
          ),
          _buildTextField(
            "Cantidad *", 
            _cantidadController, 
            Icons.numbers, 
            TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
          _buildTextField(
            "Precio unitario *", 
            _precioController, 
            Icons.attach_money, 
            TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
          
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _agregarVenta,
              icon: const Icon(Icons.add),
              label: const Text("Agregar Venta"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          
          if (_ventas.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("Ventas registradas:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ..._ventas.asMap().entries.map((entry) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text('${entry.key + 1}'),
                ),
                title: Text(
                  "${entry.value['producto'].isNotEmpty ? entry.value['producto'] : entry.value['servicio']}"
                ),
                subtitle: Text(
                  "Fecha: ${entry.value['fecha']}\n"
                  "Cantidad: ${entry.value['cantidad']} | Precio: \$${entry.value['precio']}"
                ),
                trailing: Text(
                  "\$${entry.value['total'].toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                isThreeLine: true,
              ),
            )),
            
            // Resumen de ventas
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total de Ventas:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "\$${_calcularTotalVentas().toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarRegistroVentas,
                icon: const Icon(Icons.save),
                label: const Text("Guardar Registro de Ventas"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGastosOperativos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gastos Operativos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            "Materia prima *", 
            _materiaPrimaController, 
            Icons.inventory, 
            TextInputType.number,
            errorText: _materiaPrimaSalariosError,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
          _buildTextField(
            "Salarios del personal *", 
            _salariosController, 
            Icons.people, 
            TextInputType.number,
            errorText: _materiaPrimaSalariosError,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
          _buildTextField(
            "Servicios públicos", 
            _serviciosPublicosController, 
            Icons.electrical_services, 
            TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
          _buildTextField(
            "Comisiones", 
            _comisionesController, 
            Icons.monetization_on, 
            TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
          _buildTextField(
            "Publicidad", 
            _publicidadController, 
            Icons.campaign, 
            TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
          _buildTextField(
            "Alquiler", 
            _alquilerController, 
            Icons.home, 
            TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),
          
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _agregarGasto,
              icon: const Icon(Icons.add),
              label: const Text("Agregar Gasto"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.orange,
              ),
            ),
          ),
          
          if (_gastos.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("Gastos registrados:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ..._gastos.asMap().entries.map((entry) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text('${entry.key + 1}'),
                ),
                title: Text("Gasto #${entry.key + 1} - ${entry.value['fecha']}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGastoItem("Materia prima", entry.value['materia_prima']),
                        _buildGastoItem("Salarios", entry.value['salarios']),
                        _buildGastoItem("Servicios públicos", entry.value['servicios_publicos']),
                        _buildGastoItem("Comisiones", entry.value['comisiones']),
                        _buildGastoItem("Publicidad", entry.value['publicidad']),
                        _buildGastoItem("Alquiler", entry.value['alquiler']),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            
            // Resumen de gastos
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total de Gastos:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "\$${_calcularTotalGastos().toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarGastos,
                icon: const Icon(Icons.save),
                label: const Text("Guardar Gastos Operativos"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ... (los métodos _buildGestionFinanciera, _buildFuncionesLider, 
  // _buildTextField, _buildFuncionCard se mantienen similares pero con mejoras)

  Widget _buildTextFieldObligatorio(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    TextInputType tipo, 
    {String? errorText, int maxLines = 1, List<TextInputFormatter>? inputFormatters}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, color: Colors.red),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.red),
          filled: true,
          fillColor: errorText != null ? Colors.red[50] : Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    TextInputType tipo, 
    {String? errorText, int maxLines = 1, List<TextInputFormatter>? inputFormatters}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.red),
          filled: true,
          fillColor: errorText != null ? Colors.red[50] : Colors.white,
        ),
      ),
    );
  }

  // Métodos auxiliares para cálculos
  double _calcularTotalVentas() {
    return _ventas.fold(0, (total, venta) => total + (venta['total'] as double));
  }

  double _calcularTotalGastos() {
    return _gastos.fold(0, (total, gasto) {
      double sumaGasto = 0;
      sumaGasto += double.tryParse(gasto['materia_prima'] ?? '0') ?? 0;
      sumaGasto += double.tryParse(gasto['salarios'] ?? '0') ?? 0;
      sumaGasto += double.tryParse(gasto['servicios_publicos'] ?? '0') ?? 0;
      sumaGasto += double.tryParse(gasto['comisiones'] ?? '0') ?? 0;
      sumaGasto += double.tryParse(gasto['publicidad'] ?? '0') ?? 0;
      sumaGasto += double.tryParse(gasto['alquiler'] ?? '0') ?? 0;
      return total + sumaGasto;
    });
  }

  Widget _buildGastoItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    final valorNumerico = double.tryParse(value) ?? 0;
    if (valorNumerico == 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text("\$$valorNumerico", style: const TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }

  // ... (los demás métodos _buildGestionFinanciera y _buildFuncionesLider se mantienen)
}