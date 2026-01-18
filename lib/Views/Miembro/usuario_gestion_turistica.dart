import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_vinculacion/Modelos/turismo_model.dart'; 
import 'package:proyecto_vinculacion/Servicios/turismo_service.dart';
import 'package:proyecto_vinculacion/validar_cedula_ecuador.dart';
import 'package:proyecto_vinculacion/datos_pano_tena.dart';

/// Ejemplo de widget con TabBar/TabBarView para cada categoría
class TurismoComunitario extends StatefulWidget {
  const TurismoComunitario({super.key});

  @override
  State<TurismoComunitario> createState() => _TurismoComunitarioState();
}

class _TurismoComunitarioState extends State<TurismoComunitario> {
  // Variables para Registro de Visitante
  String? _tipoServicioSeleccionado;
  String? _ubicacionSeleccionada;

  // Variables para filtrar servicios según el usuario
  List<String> _serviciosAsignados = [];
  List<String> _ubicacionesAsignadas = [];

  // Lista de tipos de servicio
  final List<String> _tiposServicio = [
    'Albergues',
    'Hospedajes rurales',
    'Rutas de turismo vivencial',
    'Experiencias astronómicas autóctonas',
    'Artesanía local',
    'Productos locales',
    'Patrimonio natural',
    'Balnearios',
  ];

  // Mapeo de tipo de servicio a ubicaciones
  final Map<String, List<String>> _servicioUbicaciones = {
    'Balnearios': [
      'Balneario Juan Bueno',
      'Balneario Lagartococha',
      'Balneario Pano',
      'Balneario Pikitzacocha',
      'Balneario Puka Urku',
      'Balneario Pumarumi',
      'Balneario Rumicocha',
      'Balneario San Andrés',
      'Balneario San Bartolomé de Imbu',
      'Balneario San Carlos',
      'Balneario Yaracocha',
    ],
    'Albergues': [
      'Hostería Napusamai Pasourcu Lodge',
    ],
    'Hospedajes rurales': [
      'Hospedaje Alto Pano',
      'Hospedaje Pano Centro',
    ],
    'Rutas de turismo vivencial': [
      'Ruta Bosque de los Sueños',
      'Ruta Cascada Achiyacu',
    ],
    'Experiencias astronómicas autóctonas': [
      'Mirador Rayuurcu',
      'Mirador Sacha Urco',
    ],
    'Artesanía local': [
      'Centro Artesanal Alto Pano',
      'Centro Artesanal Pano',
    ],
    'Productos locales': [
      'Mercado Pano',
      'Tienda Local Pano',
    ],
    'Patrimonio natural': [
      'Petroglifo Pumarumi',
      'Rumi Cocha',
      'Cañón Supaypaccha Uctu',
    ],
  };

  // Definición de categorías y sus campos (cada uno con un icono)
  final Map<String, List<Map<String, dynamic>>> categorias = {
    "Lugar Turístico": [
      {"nombre": "Número de registro turístico", "icono": Icons.confirmation_number},
      {"nombre": "Tipo de servicio turístico", "icono": Icons.room_service},
      {"nombre": "Nombre del establecimiento", "icono": Icons.store},
      {"nombre": "Capacidad de atención", "icono": Icons.people},
      {"nombre": "Tarifas por servicio", "icono": Icons.attach_money},
      {"nombre": "Horarios de operación", "icono": Icons.schedule},
      {"nombre": "Ubicación/Dirección", "icono": Icons.location_on},
    ],
    "Registro de visitante": [
      {"nombre": "Cédula", "icono": Icons.badge},
      {"nombre": "Nombre", "icono": Icons.person},
      {"nombre": "Teléfono", "icono": Icons.phone},
      {"nombre": "Opiniones y valoraciones de visitantes", "icono": Icons.star},
    ],
    "Emprendimiento Comunitario Turístico": [
      // Estos campos representarán los "servicios" que ofrece el emprendimiento.
      {"nombre": "Albergues", "icono": Icons.hotel},
      {"nombre": "Hospedajes rurales", "icono": Icons.house},
      {"nombre": "Rutas de turismo vivencial", "icono": Icons.directions_walk},
      {"nombre": "Experiencias astronómicas autóctonas", "icono": Icons.nightlight},
      {"nombre": "Artesanía local con valor cultural", "icono": Icons.handshake},
      {"nombre": "Productos locales con valor cultural", "icono": Icons.shopping_bag},
      {"nombre": "Patrimonio natural", "icono": Icons.nature},
    ],
  };

  /// Mapa para administrar un TextEditingController para cada campo.
  /// Estructura: { "Categoria": { "Nombre del campo": controller } }
  final Map<String, Map<String, TextEditingController>> controllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores para cada campo
    categorias.forEach((categoria, items) {
      controllers[categoria] = {};
      for (var item in items) {
        String fieldName = item["nombre"];
        controllers[categoria]![fieldName] = TextEditingController();
      }
      // Para las categorías que requieren un campo adicional de "Nombre", se agrega aquí.
      if (categoria == "Emprendimiento Comunitario Turístico") {
        controllers[categoria]!["Nombre"] = TextEditingController();
      }
    });

    // Inicializar valores por defecto para Tipo de servicio (Lugar Turístico)
    controllers["Lugar Turístico"]!['Tipo de servicio turístico'] ??= TextEditingController();
    controllers["Lugar Turístico"]!['Horarios de operación'] ??= TextEditingController();

    // Cargar servicios y ubicaciones asignadas del usuario
    _cargarServiciosAsignados();
  }

  /// Cargar los servicios y ubicaciones asignadas al usuario durante el registro
  Future<void> _cargarServiciosAsignados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _serviciosAsignados = List<String>.from(data['serviciosAsignados'] ?? []);
          _ubicacionesAsignadas = List<String>.from(data['ubicacionesAsignadas'] ?? []);

          // Si el usuario tiene servicios asignados, filtrar los tipos de servicio
          if (_serviciosAsignados.isNotEmpty) {
            // Mantener solo los servicios que están en la lista de servicios asignados
            _tiposServicio.retainWhere((servicio) => 
              _serviciosAsignados.contains(servicio)
            );
          }
        });
      }
    } catch (e) {
      print('Error cargando servicios asignados: $e');
    }
  }

  @override
  void dispose() {
    // Liberar los controladores
    controllers.forEach((categoria, map) {
      map.forEach((field, controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }

  // Guardar datos para "Lugar Turístico"
  Future<void> guardarDatosLugarTuristico() async {
    Map<String, String> data = {};
    for (var item in categorias["Lugar Turístico"]!) {
      String fieldName = item["nombre"];
      String value = controllers["Lugar Turístico"]![fieldName]?.text ?? "";
      data[fieldName] = value;
    }
    final correo = FirebaseAuth.instance.currentUser?.email;
    if (correo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario no autenticado')));
      return;
    }

    // Si no hay número de registro, generar contador automático
    final regKey = 'Número de registro turístico';
    if ((data[regKey] ?? '').trim().isEmpty) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('lugares_turisticos')
            .where('correo', isEqualTo: correo)
            .get();
        final next = snapshot.size + 1;
        data[regKey] = next.toString();
        controllers['Lugar Turístico']![regKey]!.text = next.toString();
      } catch (_) {}
    }

    // Validaciones básicas: tarifa numérica y horarios
    final tarifa = data['Tarifas por servicio'] ?? '';
    if (tarifa.isNotEmpty && double.tryParse(tarifa) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarifa inválida')));
      return;
    }

    try {
      await FirebaseTurismoService().addLugarTuristico(data, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos guardados para Lugar Turístico"))
      );
      limpiarCampos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"))
      );
    }
  }

  // Guardar datos para "Registro de visitante"
  Future<void> guardarDatosRegistroVisitante() async {
    // Validar que tipoServicio y ubicación estén seleccionados
    if (_tipoServicioSeleccionado == null || _tipoServicioSeleccionado!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un tipo de servicio turístico'))
      );
      return;
    }

    if (_ubicacionSeleccionada == null || _ubicacionSeleccionada!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una ubicación/lugar turístico'))
      );
      return;
    }

    Map<String, String> data = {};
    for (var item in categorias["Registro de visitante"]!) {
      String fieldName = item["nombre"];
      String value = controllers["Registro de visitante"]![fieldName]?.text ?? "";
      data[fieldName] = value;
    }
    final correo = FirebaseAuth.instance.currentUser?.email;
    if (correo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario no autenticado')));
      return;
    }

    // Validar cédula y teléfono usando utilitarios
    final cedula = (data['Cédula'] ?? '').trim();
    final telefono = (data['Teléfono'] ?? '').trim();

    // Cédula: usar el validador centralizado
    final cedulaMsg = ValidarCedulaEcuador.validarConMensaje(cedula);
    if (cedulaMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cédula inválida: $cedulaMsg')));
      return;
    }

    // Teléfono: obligatorio y sólo dígitos entre 7 y 15 caracteres
    if (telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El teléfono es obligatorio')));
      return;
    }
    final phoneValid = RegExp(r'^\d{7,15}$');
    if (!phoneValid.hasMatch(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teléfono inválido: debe tener 7 a 15 dígitos numéricos')));
      return;
    }

    try {
      await FirebaseTurismoService().addRegistroVisitante(
        data,
        correo,
        _tipoServicioSeleccionado!,
        _ubicacionSeleccionada!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos guardados para Registro de visitante"))
      );
      limpiarCampos();
      // Limpiar también las selecciones de tipo de servicio y ubicación
      setState(() {
        _tipoServicioSeleccionado = null;
        _ubicacionSeleccionada = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"))
      );
    }
  }

  // Guardar datos para "Emprendimiento Comunitario Turístico"
  Future<void> guardarDatosEmprendimiento() async {
    const cat = "Emprendimiento Comunitario Turístico";
    final catControllers = controllers[cat]!;
    String nombre = catControllers["Nombre"]?.text ?? "";
    List<String> servicios = [];
    for (var item in categorias[cat]!) {
      String fieldName = item["nombre"];
      String value = catControllers[fieldName]?.text ?? "";
      servicios.add("$fieldName: $value");
    }
    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    // Crear la instancia del modelo de emprendimiento
    final emprendimiento = EmprendimientoComunitarioTuristico(
      correo: correo,
      nombre: nombre,
      servicios: servicios,
    );
    try {
      await FirebaseTurismoService().addEmprendimiento(emprendimiento, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos guardados para Emprendimiento"))
      );
      limpiarCampos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"))
      );
    }
  }

  // Guardar datos para "Estrategias para el fortalecimiento del turismo comunitario" - REMOVIDO
  // Este método fue eliminado y ya no se utiliza

  /// Método para construir el formulario de los dos primeros tabs (Lugar Turístico y Registro de visitante)
  /// Construir el formulario especializado para "Registro de visitante" con selección de servicio y ubicación
  Widget _buildRegistroVisitanteTab() {
    // Filtrar servicios según los asignados al usuario
    List<String> serviciosDisponibles = _serviciosAsignados.isNotEmpty 
        ? _tiposServicio.where((s) => _serviciosAsignados.contains(s)).toList()
        : _tiposServicio;

    // Filtrar ubicaciones según las asignadas al usuario
    List<String> ubicacionesDisponibles = _ubicacionesAsignadas.isNotEmpty
        ? _ubicacionesAsignadas
        : (_servicioUbicaciones[_tipoServicioSeleccionado] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Selección de Tipo de Servicio Turístico
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.room_service, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Tipo de Servicio Turístico",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _tipoServicioSeleccionado,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "Selecciona un tipo de servicio",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  items: serviciosDisponibles.map((servicio) {
                    return DropdownMenuItem<String>(
                      value: servicio,
                      child: Text(servicio),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoServicioSeleccionado = value;
                      // Resetear la ubicación cuando cambia el servicio
                      _ubicacionSeleccionada = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor selecciona un tipo de servicio";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Selección de Ubicación (solo si hay servicio seleccionado)
          if (_tipoServicioSeleccionado != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Lugar/Ubicación Turística",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _ubicacionSeleccionada,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Selecciona una ubicación",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    items: ubicacionesDisponibles
                        .map((ubicacion) {
                      return DropdownMenuItem<String>(
                        value: ubicacion,
                        child: Text(ubicacion),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _ubicacionSeleccionada = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor selecciona una ubicación";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          
          // Campos del formulario de visitante
          _buildList("Registro de visitante", categorias["Registro de visitante"]!),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: guardarDatosRegistroVisitante,
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  /// Construir el formulario estándar para las categorías principales
  Widget _buildTabContent(String categoria, VoidCallback onGuardar) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildList(categoria, categorias[categoria]!),
          const SizedBox(height: 20,),
          ElevatedButton(onPressed: onGuardar, child: const Text("Guardar"))
        ],
      ),
    );
  }

  /// Construir el formulario para "Emprendimiento Comunitario Turístico"
  Widget _buildEmprendimientoTab() {
    const cat = "Emprendimiento Comunitario Turístico";
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: controllers[cat]!["Nombre"],
            decoration: const InputDecoration(
              labelText: "Nombre del Emprendimiento",
              border: OutlineInputBorder(),
              
            ),
          ),
          const SizedBox(height: 20),
          _buildList(cat, categorias[cat]!),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: guardarDatosEmprendimiento, child: const Text("Guardar"))
        ],
      ),
    );
  }

  /// Método para construir la lista de campos (con su TextField) de una categoría
  Widget _buildList(String categoria, List<Map<String, dynamic>> items) {
  return Column(
    children: items.map((item) {
      String fieldName = item["nombre"];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior con icono y nombre del campo (se envuelve el texto para que se ajuste en dos líneas)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item["icono"], color: Colors.black),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fieldName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Campo especializado según categoría y nombre
            if (categoria == 'Lugar Turístico') ...[
              if (fieldName == 'Número de registro turístico')
                TextField(
                  controller: controllers[categoria]![fieldName],
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Se asigna automáticamente si queda vacío',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else if (fieldName == 'Tipo de servicio turístico')
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: controllers[categoria]![fieldName]!.text.isEmpty ? null : controllers[categoria]![fieldName]!.text,
                      items: [
                        // Mostrar solo servicios asignados si existen
                        if (_serviciosAsignados.isNotEmpty)
                          ..._serviciosAsignados
                        else
                          ...[
                            'Albergues',
                            'Hospedajes rurales',
                            'Rutas de turismo vivencial',
                            'Experiencias astronómicas autóctonas',
                            'Artesanía local',
                            'Productos locales',
                            'Patrimonio natural',
                          ],
                        'Otro',
                      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) {
                        setState(() {
                          controllers[categoria]![fieldName]!.text = v ?? '';
                          if (v != null && v != 'Otro') {
                            controllers[categoria]!['TipoServicioOtro']?.text = '';
                          }
                        });
                      },
                      decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    if (controllers[categoria]!['Tipo de servicio turístico']!.text == 'Otro')
                      TextField(
                        controller: controllers[categoria]!['TipoServicioOtro'] ??= TextEditingController(),
                        decoration: const InputDecoration(
                          hintText: 'Especifique otro tipo de servicio',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                  ],
                )
              else if (fieldName == 'Tarifas por servicio')
                TextField(
                  controller: controllers[categoria]![fieldName],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: InputDecoration(
                    hintText: 'Ingrese tarifa numérica',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else if (fieldName == 'Horarios de operación')
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controllers[categoria]![fieldName],
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Inicio - Fin (HH:MM - HH:MM)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onTap: () async {
                          final start = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (start != null) {
                            final end = await showTimePicker(context: context, initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute));
                            if (end != null) {
                              controllers[categoria]![fieldName]!.text = '${start.format(context)} - ${end.format(context)}';
                            }
                          }
                        },
                      ),
                    ),
                  ],
                )
              else if (fieldName == 'Ubicación/Dirección')
                // Autocompletado para ubicaciones de Pano
                _buildUbicacionAutocompletado(categoria, fieldName)
              else
                TextField(
                  controller: controllers[categoria]![fieldName],
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Ingrese...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
            ] else if (categoria == 'Registro de visitante') ...[
              if (fieldName == 'Cédula')
                TextField(
                  controller: controllers[categoria]![fieldName],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(hintText: 'Ingrese cédula', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                )
              else if (fieldName == 'Teléfono')
                TextField(
                  controller: controllers[categoria]![fieldName],
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(hintText: 'Ingrese teléfono (solo números)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                )
              else
                TextField(
                  controller: controllers[categoria]![fieldName],
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Ingrese...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
            ] else
              TextField(
                controller: controllers[categoria]![fieldName],
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Ingrese...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
          ],
        ),
      );
    }).toList(),
  );
}


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gestión Turística"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Lugar Turístico"),
              Tab(text: "Registro visitante"),
              Tab(text: "Emprendimiento"),
              Tab(text: "Historial"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent("Lugar Turístico", guardarDatosLugarTuristico),
            _buildRegistroVisitanteTab(),
            _buildEmprendimientoTab(),
            _buildHistorialTurismo(),
          ],
        ),
      ),
    );
  }
  Widget _buildHistorialTurismo() {
    final correo = FirebaseAuth.instance.currentUser?.email ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lugares Turísticos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseTurismoService().getLugaresTuristicos(correo),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              final list = snapshot.data ?? [];
              if (list.isEmpty) return const Text('No hay registros');
              return Column(children: list.map((d) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(title: Text(d['nombre'] ?? 'Lugar')))).toList());
            },
          ),
          const SizedBox(height: 16),
          const Text('Registros de Visitantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseTurismoService().getVisitantes(correo),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              final list = snapshot.data ?? [];
              if (list.isEmpty) return const Text('No hay registros');
              return Column(children: list.map((d) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(title: Text(d['data']?['Nombre'] ?? 'Visitante')))).toList());
            },
          ),
          const SizedBox(height: 16),
          const Text('Emprendimientos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseTurismoService().getEmprendimientos(correo),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              final list = snapshot.data ?? [];
              if (list.isEmpty) return const Text('No hay registros');
              return Column(children: list.map((d) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(title: Text(d['nombre'] ?? 'Emprendimiento')))).toList());
            },
          ),
          const SizedBox(height: 16),
          const Text('Estrategias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseTurismoService().getEstrategias(correo),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              final list = snapshot.data ?? [];
              if (list.isEmpty) return const Text('No hay registros');
              return Column(children: list.map((d) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(title: Text(d['nombre'] ?? 'Estrategia')))).toList());
            },
          ),
        ],
      ),
    );
  }
  // Función para limpiar los campos después de guardar
void limpiarCampos() {
  // Iterar sobre las categorías y limpiar los controladores de cada campo
  categorias.forEach((categoria, items) {
    for (var item in items) {
      String fieldName = item["nombre"];
      controllers[categoria]![fieldName]?.clear();
    }
    // Limpiar el campo "Nombre" para las categorías específicas si existe
    if (categoria == "Emprendimiento Comunitario Turístico") {
      controllers[categoria]!["Nombre"]?.clear();
    }
  });
  
  // Mostrar un mensaje de éxito al usuario
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Campos limpiados"))
  );
}

  /// Widget para autocompletado de ubicaciones en Pano
  Widget _buildUbicacionAutocompletado(String categoria, String fieldName) {
    final controller = controllers[categoria]![fieldName]!;
    
    // Usar ubicaciones asignadas si existen, de lo contrario usar todas
    final ubicacionesDisponibles = _ubicacionesAsignadas.isNotEmpty
        ? _ubicacionesAsignadas
        : ubicacionesPanoTena;
    
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return ubicacionesDisponibles.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (BuildContext context, TextEditingController fieldController, 
          FocusNode focusNode, VoidCallback onFieldSubmitted) {
        // Sincronizar el controller del Autocomplete con el nuestro
        fieldController.text = controller.text;
        controller.addListener(() {
          fieldController.text = controller.text;
        });
        
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          onChanged: (value) {
            controller.text = value;
          },
          decoration: InputDecoration(
            hintText: "Busca un lugar en Pano...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.location_on),
          ),
        );
      },
    );
  }
}