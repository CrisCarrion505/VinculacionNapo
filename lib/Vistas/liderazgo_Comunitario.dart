import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_vinculacion/Modelos/liderazgo_model.dart';
import 'package:proyecto_vinculacion/Servicios/liderazgo_service.dart';
import 'package:proyecto_vinculacion/Utilidades/validar_cedula_ecuador.dart';

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
  
  // Controladores para Gestión Financiera
  final TextEditingController _resumenFinancieroController = TextEditingController();
  final TextEditingController _presupuestoAnualController = TextEditingController();
  final TextEditingController _presupuestoMensualController = TextEditingController();
  final TextEditingController _fondosEmergenciaController = TextEditingController();
  
  // Control de checkboxes
  bool _reunionesPeriodicas = false;
  bool _registrosContables = false;
  
  // Estados de validación
  String? _cedulaError;
  String? _rucError;
  String? _productoServicioError;
  String? _materiaPrimaSalariosError;
  
  List<Map<String, dynamic>> _ventas = [];
  List<Map<String, dynamic>> _gastos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Agregar listeners para validación en tiempo real
    _cedulaController.addListener(_validarCedula);
    _rucController.addListener(_validarRUC);
  }

  void _validarCedula() {
    if (_cedulaController.text.isNotEmpty) {
      setState(() {
        _cedulaError = ValidarCedulaEcuador.validarConMensaje(_cedulaController.text);
      });
    } else {
      setState(() {
        _cedulaError = null;
      });
    }
  }

  void _validarRUC() {
    if (_rucController.text.isNotEmpty && _rucController.text.length != 13) {
      setState(() {
        _rucError = 'El RUC debe tener 13 dígitos';
      });
    } else {
      setState(() {
        _rucError = null;
      });
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
    _resumenFinancieroController.dispose();
    _presupuestoAnualController.dispose();
    _presupuestoMensualController.dispose();
    _fondosEmergenciaController.dispose();
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
    // Validar campos obligatorios
    if (_cedulaController.text.isEmpty) {
      setState(() {
        _cedulaError = 'La cédula es obligatoria';
      });
    }
    
    if (_rucController.text.isEmpty) {
      setState(() {
        _rucError = 'El RUC es obligatorio';
      });
    }

    if (_cedulaController.text.isEmpty || _rucController.text.isEmpty || _cedulaError != null || _rucError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete los campos obligatorios correctamente"))
      );
      return;
    }

    if (_ventas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agregue al menos una venta"))
      );
      return;
    }

    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    
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

    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    
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

  Future<void> _guardarGestionFinanciera() async {
    // Validar campos importantes de gestión financiera
    if (_resumenFinancieroController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El resumen financiero es importante"))
      );
      return;
    }

    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    
    final gestion = GestionFinancieraModel(
      correo: correo,
      reunionesPeriodicas: _reunionesPeriodicas,
      resumenFinanciero: _resumenFinancieroController.text,
      presupuestoAnual: _presupuestoAnualController.text,
      presupuestoMensual: _presupuestoMensualController.text,
      fondosEmergencia: _fondosEmergenciaController.text,
      registrosContables: _registrosContables,
    );

    try {
      await LiderazgoService().addGestionFinanciera(gestion, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gestión financiera guardada exitosamente"))
      );
      _limpiarCamposGestion();
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

  void _limpiarCamposGestion() {
    _resumenFinancieroController.clear();
    _presupuestoAnualController.clear();
    _presupuestoMensualController.clear();
    _fondosEmergenciaController.clear();
    setState(() {
      _reunionesPeriodicas = false;
      _registrosContables = false;
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
            Tab(icon: Icon(Icons.analytics), text: "Gestión Financiera"),
            Tab(icon: Icon(Icons.people), text: "Funciones"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegistroVentas(),
          _buildGastosOperativos(),
          _buildGestionFinanciera(),
          _buildFuncionesLider(),
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
          
          _buildTextField(
            "Fecha de Venta", 
            _fechaVentaController, 
            Icons.calendar_today, 
            TextInputType.datetime
          ),
          _buildTextField(
            "Producto vendido", 
            _productoController, 
            Icons.shopping_bag, 
            TextInputType.text,
            errorText: _productoServicioError,
          ),
          _buildTextField(
            "Servicio vendido", 
            _servicioController, 
            Icons.room_service, 
            TextInputType.text,
            errorText: _productoServicioError,
          ),
          _buildTextField(
            "Cantidad *", 
            _cantidadController, 
            Icons.numbers, 
            TextInputType.number,
          ),
          _buildTextField(
            "Precio unitario *", 
            _precioController, 
            Icons.attach_money, 
            TextInputType.number,
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
          ),
          _buildTextField(
            "Salarios del personal *", 
            _salariosController, 
            Icons.people, 
            TextInputType.number,
            errorText: _materiaPrimaSalariosError,
          ),
          _buildTextField(
            "Servicios públicos", 
            _serviciosPublicosController, 
            Icons.electrical_services, 
            TextInputType.number
          ),
          _buildTextField(
            "Comisiones", 
            _comisionesController, 
            Icons.monetization_on, 
            TextInputType.number
          ),
          _buildTextField(
            "Publicidad", 
            _publicidadController, 
            Icons.campaign, 
            TextInputType.number
          ),
          _buildTextField(
            "Alquiler", 
            _alquilerController, 
            Icons.home, 
            TextInputType.number
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
    {String? errorText, int maxLines = 1}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
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
    {String? errorText, int maxLines = 1}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
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