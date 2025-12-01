import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_vinculacion/Modelos/turismo_model.dart'; 
import 'package:proyecto_vinculacion/Servicios/turismo_service.dart';

/// Ejemplo de widget con TabBar/TabBarView para cada categoría
class TurismoComunitario extends StatefulWidget {
  const TurismoComunitario({super.key});

  @override
  State<TurismoComunitario> createState() => _TurismoComunitarioState();
}

class _TurismoComunitarioState extends State<TurismoComunitario> {
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
    "Estrategias para el fortalecimiento del turismo comunitario": [
      // Estos campos representarán las "acciones" o estrategias.
      {"nombre": "Programas de formación en gestión de emprendimientos turísticos", "icono": Icons.school},
      {"nombre": "Microcréditos para proyectos comunitarios", "icono": Icons.monetization_on},
      {"nombre": "Financiamiento para proyectos comunitarios", "icono": Icons.account_balance},
      {"nombre": "Estrategias de marketing digital", "icono": Icons.public},
      {"nombre": "Estrategias de turismo experiencial", "icono": Icons.explore},
      {"nombre": "Alianzas con el sector público", "icono": Icons.business},
      {"nombre": "Alianzas con el sector privado", "icono": Icons.handshake},
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
      if (categoria == "Emprendimiento Comunitario Turístico" ||
          categoria == "Estrategias para el fortalecimiento del turismo comunitario") {
        controllers[categoria]!["Nombre"] = TextEditingController();
      }
    });
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
    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
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
    Map<String, String> data = {};
    for (var item in categorias["Registro de visitante"]!) {
      String fieldName = item["nombre"];
      String value = controllers["Registro de visitante"]![fieldName]?.text ?? "";
      data[fieldName] = value;
    }
    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    try {
      await FirebaseTurismoService().addRegistroVisitante(data, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos guardados para Registro de visitante"))
      );
      limpiarCampos();
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

  // Guardar datos para "Estrategias para el fortalecimiento del turismo comunitario"
  Future<void> guardarDatosEstrategia() async {
    const cat = "Estrategias para el fortalecimiento del turismo comunitario";
    final catControllers = controllers[cat]!;
    String nombre = catControllers["Nombre"]?.text ?? "";
    List<String> acciones = [];
    for (var item in categorias[cat]!) {
      String fieldName = item["nombre"];
      String value = catControllers[fieldName]?.text ?? "";
      acciones.add("$fieldName: $value");
    }
    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Sin correo';
    final estrategia = EstrategiaTurismoComunitarioModel(
      correo: correo,
      nombre: nombre,
      acciones: acciones,
    );
    try {
      await FirebaseTurismoService().addEstrategia(estrategia, correo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos guardados para Estrategia"))
      );
      limpiarCampos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"))
      );
    }
  }

  /// Método para construir el formulario de los dos primeros tabs (Lugar Turístico y Registro de visitante)
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

  /// Construir el formulario para "Estrategias para el fortalecimiento del turismo comunitario"
  Widget _buildEstrategiaTab() {
    const cat = "Estrategias para el fortalecimiento del turismo comunitario";
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: controllers[cat]!["Nombre"],
            decoration: const InputDecoration(
              labelText: "Nombre de la Estrategia",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          _buildList(cat, categorias[cat]!),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: guardarDatosEstrategia, child: const Text("Guardar"))
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
            // TextField debajo del nombre
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
              Tab(text: "Estrategias"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent("Lugar Turístico", guardarDatosLugarTuristico),
            _buildTabContent("Registro de visitante", guardarDatosRegistroVisitante),
            _buildEmprendimientoTab(),
            _buildEstrategiaTab(),
          ],
        ),
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
    if (categoria == "Emprendimiento Comunitario Turístico" || categoria == "Estrategias para el fortalecimiento del turismo comunitario") {
      controllers[categoria]!["Nombre"]?.clear();
    }
  });
  
  // Mostrar un mensaje de éxito al usuario
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Campos limpiados"))
  );
}

}
