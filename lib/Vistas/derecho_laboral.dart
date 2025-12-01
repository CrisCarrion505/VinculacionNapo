import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_vinculacion/Modelos/derecho_laboral_model.dart';
import 'package:proyecto_vinculacion/Servicios/derecho_laboral_service.dart';

class DerechoLaboral extends StatefulWidget {
  const DerechoLaboral({super.key});

  @override
  State<DerechoLaboral> createState() => _DerechoLaboralState();
}

class _DerechoLaboralState extends State<DerechoLaboral> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controladores para Contratos de Trabajo
  final TextEditingController _nombreEmpleadoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  String _tipoContrato = 'Indefinido';
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _salarioController = TextEditingController();
  
  // Controladores para Afiliación IESS
  final TextEditingController _fechaAfiliacionController = TextEditingController();
  final TextEditingController _numeroAfiliacionController = TextEditingController();
  
  // Beneficios Sociales
  bool _decimoTercero = false;
  bool _decimoCuarto = false;
  bool _fondosReserva = false;
  bool _vacaciones = false;
  bool _horasExtra = false;
  
  // Control de Asistencia
  final TextEditingController _fechaAsistenciaController = TextEditingController();
  final TextEditingController _horaEntradaController = TextEditingController();
  final TextEditingController _horaSalidaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  
  // Derecho Tributario
  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _documentacionController = TextEditingController();
  final TextEditingController _declaracionImpuestosController = TextEditingController();
  
  // ignore: unused_field
  List<Map<String, dynamic>> _contratos = [];
  List<Map<String, dynamic>> _asistencias = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreEmpleadoController.dispose();
    _cedulaController.dispose();
    _fechaInicioController.dispose();
    _salarioController.dispose();
    _fechaAfiliacionController.dispose();
    _numeroAfiliacionController.dispose();
    _fechaAsistenciaController.dispose();
    _horaEntradaController.dispose();
    _horaSalidaController.dispose();
    _observacionesController.dispose();
    _rucController.dispose();
    _documentacionController.dispose();
    _declaracionImpuestosController.dispose();
    super.dispose();
  }

  Future<void> _guardarContrato() async {
    if (_nombreEmpleadoController.text.isEmpty || _cedulaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete los campos obligatorios"))
      );
      return;
    }

    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    
    final contrato = ContratoTrabajoModel(
      correo: correo,
      nombreEmpleado: _nombreEmpleadoController.text,
      cedula: _cedulaController.text,
      tipoContrato: _tipoContrato,
      fechaInicio: _fechaInicioController.text,
      salario: _salarioController.text,
      fechaAfiliacion: _fechaAfiliacionController.text,
      numeroAfiliacion: _numeroAfiliacionController.text,
    );

    try {
      await DerechoLaboralService().addContrato(contrato, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contrato guardado correctamente"))
      );
      _limpiarCamposContrato();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"))
      );
    }
  }

  Future<void> _guardarBeneficios() async {
    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    
    final beneficios = BeneficiosSocialesModel(
      correo: correo,
      decimoTercero: _decimoTercero,
      decimoCuarto: _decimoCuarto,
      fondosReserva: _fondosReserva,
      vacaciones: _vacaciones,
      horasExtra: _horasExtra,
    );

    try {
      await DerechoLaboralService().addBeneficios(beneficios, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Beneficios sociales guardados"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    }
  }

  void _agregarAsistencia() {
    if (_fechaAsistenciaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese la fecha de asistencia"))
      );
      return;
    }

    setState(() {
      _asistencias.add({
        'fecha': _fechaAsistenciaController.text,
        'hora_entrada': _horaEntradaController.text,
        'hora_salida': _horaSalidaController.text,
        'observaciones': _observacionesController.text,
      });
    });

    _fechaAsistenciaController.clear();
    _horaEntradaController.clear();
    _horaSalidaController.clear();
    _observacionesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Asistencia registrada"))
    );
  }

  Future<void> _guardarAsistencias() async {
    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    
    final asistencia = ControlAsistenciaModel(
      correo: correo,
      registros: _asistencias,
    );

    try {
      await DerechoLaboralService().addAsistencia(asistencia, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Asistencias guardadas correctamente"))
      );
      setState(() {
        _asistencias.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    }
  }

  Future<void> _guardarDerechoTributario() async {
    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    
    final tributario = DerechoTributarioModel(
      correo: correo,
      ruc: _rucController.text,
      documentacion: _documentacionController.text,
      declaracionImpuestos: _declaracionImpuestosController.text,
    );

    try {
      await DerechoLaboralService().addDerechoTributario(tributario, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Derecho tributario guardado"))
      );
      _limpiarCamposTributario();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    }
  }

  void _limpiarCamposContrato() {
    _nombreEmpleadoController.clear();
    _cedulaController.clear();
    _fechaInicioController.clear();
    _salarioController.clear();
    _fechaAfiliacionController.clear();
    _numeroAfiliacionController.clear();
  }

  void _limpiarCamposTributario() {
    _rucController.clear();
    _documentacionController.clear();
    _declaracionImpuestosController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asesoramiento en Derecho Laboral y Tributario"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.work), text: "Contratos"),
            Tab(icon: Icon(Icons.card_giftcard), text: "Beneficios"),
            Tab(icon: Icon(Icons.access_time), text: "Asistencia"),
            Tab(icon: Icon(Icons.account_balance), text: "Tributario"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContratos(),
          _buildBeneficios(),
          _buildAsistencia(),
          _buildTributario(),
        ],
      ),
    );
  }

  Widget _buildContratos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Formalizar Contratos de Trabajo",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTextField("Nombre del empleado *", _nombreEmpleadoController, Icons.person, TextInputType.text),
          _buildTextField("Cédula *", _cedulaController, Icons.badge, TextInputType.number),
          
          const SizedBox(height: 15),
          const Text("Tipo de contrato:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _tipoContrato,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.description),
            ),
            items: ['Indefinido', 'Ocasional', 'Por obra', 'Servicio determinado']
                .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                .toList(),
            onChanged: (val) => setState(() => _tipoContrato = val!),
          ),
          
          const SizedBox(height: 15),
          _buildTextField("Fecha de inicio", _fechaInicioController, Icons.calendar_today, TextInputType.datetime),
          _buildTextField("Salario", _salarioController, Icons.attach_money, TextInputType.number),
          
          const Divider(height: 30, thickness: 2),
          const Text(
            "Afiliación al IESS",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTextField("Fecha de afiliación", _fechaAfiliacionController, Icons.event, TextInputType.datetime),
          _buildTextField("Número de afiliación", _numeroAfiliacionController, Icons.numbers, TextInputType.text),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _guardarContrato,
              icon: const Icon(Icons.save),
              label: const Text("Guardar Contrato"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficios() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Beneficios Sociales",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text("Décimo tercer sueldo"),
            subtitle: const Text("Remuneración adicional anual"),
            value: _decimoTercero,
            onChanged: (val) => setState(() => _decimoTercero = val ?? false),
            secondary: const Icon(Icons.money, color: Colors.green),
          ),
          CheckboxListTile(
            title: const Text("Décimo cuarto sueldo"),
            subtitle: const Text("Salario básico unificado"),
            value: _decimoCuarto,
            onChanged: (val) => setState(() => _decimoCuarto = val ?? false),
            secondary: const Icon(Icons.payments, color: Colors.blue),
          ),
          CheckboxListTile(
            title: const Text("Fondos de reserva"),
            subtitle: const Text("Aplica desde el primer año"),
            value: _fondosReserva,
            onChanged: (val) => setState(() => _fondosReserva = val ?? false),
            secondary: const Icon(Icons.savings, color: Colors.orange),
          ),
          CheckboxListTile(
            title: const Text("Vacaciones"),
            subtitle: const Text("Según lo establece la ley"),
            value: _vacaciones,
            onChanged: (val) => setState(() => _vacaciones = val ?? false),
            secondary: const Icon(Icons.beach_access, color: Colors.purple),
          ),
          CheckboxListTile(
            title: const Text("Horas extra"),
            subtitle: const Text("Según jornada laboral"),
            value: _horasExtra,
            onChanged: (val) => setState(() => _horasExtra = val ?? false),
            secondary: const Icon(Icons.schedule, color: Colors.red),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _guardarBeneficios,
              icon: const Icon(Icons.save),
              label: const Text("Guardar Beneficios"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsistencia() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Control de Asistencia",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTextField("Fecha", _fechaAsistenciaController, Icons.calendar_today, TextInputType.datetime),
          _buildTextField("Hora de entrada", _horaEntradaController, Icons.login, TextInputType.datetime),
          _buildTextField("Hora de salida", _horaSalidaController, Icons.logout, TextInputType.datetime),
          _buildTextField("Observaciones", _observacionesController, Icons.note, TextInputType.text, maxLines: 3),
          
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _agregarAsistencia,
              icon: const Icon(Icons.add),
              label: const Text("Agregar Registro"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          
          if (_asistencias.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("Registros de asistencia:", style: TextStyle(fontWeight: FontWeight.bold)),
            ..._asistencias.map((reg) => Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text("Fecha: ${reg['fecha']}"),
                subtitle: Text("Entrada: ${reg['hora_entrada']} | Salida: ${reg['hora_salida']}"),
              ),
            )),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarAsistencias,
                icon: const Icon(Icons.save),
                label: const Text("Guardar Todas las Asistencias"),
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

  Widget _buildTributario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Derecho Tributario Comunitario",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTextField("RUC", _rucController, Icons.numbers, TextInputType.number),
          _buildTextField("Documentación del negocio", _documentacionController, Icons.description, TextInputType.text, maxLines: 3),
          _buildTextField("Declaración de impuestos", _declaracionImpuestosController, Icons.receipt_long, TextInputType.text, maxLines: 3),
          
          const SizedBox(height: 20),
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recordatorio:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text("• Realizar declaraciones y pagos a tiempo"),
                  Text("• Mantener documentación actualizada"),
                  Text("• Cumplir con obligaciones tributarias"),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _guardarDerechoTributario,
              icon: const Icon(Icons.save),
              label: const Text("Guardar Información"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, TextInputType tipo, {int maxLines = 1}) {
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
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}