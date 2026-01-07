import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_vinculacion/Modelos/seguridad_alimentaria_model.dart';
import 'package:proyecto_vinculacion/Servicios/seguridad_alimentaria_service.dart';

class UsuarioSeguridadAlimentariaView extends StatefulWidget {
  const UsuarioSeguridadAlimentariaView({super.key});

  @override
  State<UsuarioSeguridadAlimentariaView> createState() =>
      _UsuarioSeguridadAlimentariaViewState();
}

class _UsuarioSeguridadAlimentariaViewState
    extends State<UsuarioSeguridadAlimentariaView> {
  final SeguridadAlimentariaService _service = SeguridadAlimentariaService();
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;

  // Form fields
  String? _alimentoSeleccionado;
  final TextEditingController _nombreProveedorController =
      TextEditingController();
  final TextEditingController _telefonoProveedorController =
      TextEditingController();
  String? _frecuenciaSeleccionada;
  final TextEditingController _cantidadController = TextEditingController();
  String? _unidadSeleccionada;
  String? _razonSeleccionada;
  final TextEditingController _razonOtraController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  String? _ubicacionSeleccionada;

  final _formKey = GlobalKey<FormState>();

  // Para edición
  SeguridadAlimentariaModel? _reporteEnEdicion;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nombreProveedorController.dispose();
    _telefonoProveedorController.dispose();
    _cantidadController.dispose();
    _razonOtraController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // Validaciones
  String? _validateAlimento(String? value) {
    if (_alimentoSeleccionado == null) {
      return 'Por favor selecciona un alimento';
    }
    return null;
  }

  String? _validateNombreProveedor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre del proveedor';
    }
    if (value.length < 3 || value.length > 100) {
      return 'El nombre debe tener entre 3 y 100 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$').hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }
    return null;
  }

  String? _validateTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el teléfono';
    }
    // Formato ecuatoriano: +593 9 XXXX XXXX o 09XXXXXXXX
    final telefonoLimpio = value.replaceAll(RegExp(r'[^\d]'), '');
    if (telefonoLimpio.length < 10) {
      return 'Teléfono inválido (mínimo 10 dígitos)';
    }
    if (!RegExp(r'^(?:\+593|0)?9\d{8,9}$').hasMatch(telefonoLimpio)) {
      return 'Ingresa un teléfono ecuatoriano válido (09XXXXXXXX)';
    }
    return null;
  }

  String? _validateFrecuencia(String? value) {
    if (_frecuenciaSeleccionada == null) {
      return 'Por favor selecciona una frecuencia';
    }
    return null;
  }

  String? _validateCantidad(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la cantidad';
    }
    final cantidad = double.tryParse(value);
    if (cantidad == null || cantidad <= 0) {
      return 'Ingresa un valor numérico positivo';
    }
    return null;
  }

  String? _validateUnidad(String? value) {
    if (_unidadSeleccionada == null) {
      return 'Por favor selecciona una unidad';
    }
    return null;
  }

  String? _validateRazon(String? value) {
    if (_razonSeleccionada == null) {
      return 'Por favor selecciona una razón';
    }
    return null;
  }

  String? _validateRazonOtra(String? value) {
    if (_razonSeleccionada == 'Otro') {
      if (value == null || value.isEmpty) {
        return 'Especifica la razón';
      }
      if (value.length > 150) {
        return 'Máximo 150 caracteres';
      }
    }
    return null;
  }

  String? _validateObservaciones(String? value) {
    if ((value ?? '').isNotEmpty && value!.length > 250) {
      return 'Máximo 250 caracteres';
    }
    return null;
  }

  String? _validateUbicacion(String? value) {
    if (_ubicacionSeleccionada == null) {
      return 'Por favor selecciona tu ubicación';
    }
    return null;
  }

  void _guardarReporte() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Usuario no autenticado');

        final reporte = SeguridadAlimentariaModel(
          correo: user.email ?? '',
          alimentoEscaso: _alimentoSeleccionado ?? '',
          nombreProveedor: _nombreProveedorController.text.trim(),
          telefonoProveedor:
              _telefonoProveedorController.text.replaceAll(RegExp(r'[^\d]'), ''),
          frecuenciaEscasez: _frecuenciaSeleccionada ?? '',
          cantidadNecesaria: double.parse(_cantidadController.text),
          unidad: _unidadSeleccionada ?? '',
          prioridad: 'Media',
          razonEscasez: _razonSeleccionada ?? '',
          razonEscasezOtro: _razonOtraController.text.trim(),
          observaciones: _observacionesController.text.trim(),
          ubicacion: _ubicacionSeleccionada ?? '',
          fechaRegistro: DateTime.now(),
        );

        if (_reporteEnEdicion != null) {
          await _service.actualizarReporte(_reporteEnEdicion!.id, reporte);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Reporte actualizado correctamente'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          await _service.agregarReporte(reporte);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Reporte guardado correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Limpiar formulario
        _limpiarFormulario();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _alimentoSeleccionado = null;
      _nombreProveedorController.clear();
      _telefonoProveedorController.clear();
      _frecuenciaSeleccionada = null;
      _cantidadController.clear();
      _unidadSeleccionada = null;
      _razonSeleccionada = null;
      _razonOtraController.clear();
      _observacionesController.clear();
      _ubicacionSeleccionada = null;
      _reporteEnEdicion = null;
    });
  }

  void _mostrarConfirmacionCancelar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Cancelar Reporte'),
        content: const Text(
            '¿Estás seguro de que deseas cancelar? Se perderán todos los datos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mantener'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _limpiarFormulario();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Descartar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _cargarReporteParaEdicion(
      SeguridadAlimentariaModel reporte) {
    setState(() {
      _reporteEnEdicion = reporte;
      _alimentoSeleccionado = reporte.alimentoEscaso;
      _nombreProveedorController.text = reporte.nombreProveedor;
      _telefonoProveedorController.text = reporte.telefonoProveedor;
      _frecuenciaSeleccionada = reporte.frecuenciaEscasez;
      _cantidadController.text = reporte.cantidadNecesaria.toString();
      _unidadSeleccionada = reporte.unidad;
      _razonSeleccionada = reporte.razonEscasez;
      _razonOtraController.text = reporte.razonEscasezOtro;
      _observacionesController.text = reporte.observaciones;
      _ubicacionSeleccionada = reporte.ubicacion;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad Alimentaria'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildFormularioReporte(),
          _buildHistorialReportes(),
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
            icon: Icon(Icons.add_circle),
            label: 'Nuevo Reporte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioReporte() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _reporteEnEdicion != null
                  ? 'Editar Reporte'
                  : 'Nuevo Reporte de Seguridad Alimentaria',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Alimento Escaso
            FormField<String>(
              validator: _validateAlimento,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alimento Escaso *',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.hasError ? Colors.red : Colors.grey,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _alimentoSeleccionado,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecciona un alimento'),
                        items: alimentosComunes.map((String alimento) {
                          return DropdownMenuItem<String>(
                            value: alimento,
                            child: Text(alimento),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _alimentoSeleccionado = newValue;
                          });
                          state.didChange(newValue);
                        },
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(state.errorText ?? '',
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Nombre Proveedor
            TextFormField(
              controller: _nombreProveedorController,
              decoration: InputDecoration(
                labelText: 'Nombre del Proveedor *',
                hintText: 'Ej: Don Juan',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: _validateNombreProveedor,
            ),
            const SizedBox(height: 20),
            // Teléfono Proveedor
            TextFormField(
              controller: _telefonoProveedorController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono del Proveedor *',
                hintText: 'Ej: 09XXXXXXXX o +593 9 XXXX XXXX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: _validateTelefono,
            ),
            const SizedBox(height: 20),
            // Frecuencia
            FormField<String>(
              validator: _validateFrecuencia,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Frecuencia de Escasez *',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.hasError ? Colors.red : Colors.grey,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _frecuenciaSeleccionada,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecciona una frecuencia'),
                        items: frecuenciasEscasez.map((String frecuencia) {
                          return DropdownMenuItem<String>(
                            value: frecuencia,
                            child: Text(frecuencia),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _frecuenciaSeleccionada = newValue;
                          });
                          state.didChange(newValue);
                        },
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(state.errorText ?? '',
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Cantidad
            TextFormField(
              controller: _cantidadController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cantidad Necesaria *',
                hintText: 'Ej: 50',
                prefixIcon: const Icon(Icons.scale),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: _validateCantidad,
            ),
            const SizedBox(height: 20),
            // Unidad
            FormField<String>(
              validator: _validateUnidad,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unidad de Medida *',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.hasError ? Colors.red : Colors.grey,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _unidadSeleccionada,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecciona una unidad'),
                        items: unidades.map((String unidad) {
                          return DropdownMenuItem<String>(
                            value: unidad,
                            child: Text(unidad),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _unidadSeleccionada = newValue;
                          });
                          state.didChange(newValue);
                        },
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(state.errorText ?? '',
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Razón de Escasez
            FormField<String>(
              validator: _validateRazon,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Razón de Escasez *',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.hasError ? Colors.red : Colors.grey,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _razonSeleccionada,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecciona una razón'),
                        items: razonesEscasez.map((String razon) {
                          return DropdownMenuItem<String>(
                            value: razon,
                            child: Text(razon),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _razonSeleccionada = newValue;
                          });
                          state.didChange(newValue);
                        },
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(state.errorText ?? '',
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                );
              },
            ),
            // Razón Otra (si aplica)
            if (_razonSeleccionada == 'Otro') ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _razonOtraController,
                maxLength: 150,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Especifica la razón *',
                  hintText: 'Describe brevemente la razón',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: _validateRazonOtra,
              ),
            ],
            const SizedBox(height: 20),
            // Ubicación
            FormField<String>(
              validator: _validateUbicacion,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ubicación / Sector *',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.hasError ? Colors.red : Colors.grey,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _ubicacionSeleccionada,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecciona tu sector'),
                        items: sectores.map((String sector) {
                          return DropdownMenuItem<String>(
                            value: sector,
                            child: Text(sector),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _ubicacionSeleccionada = newValue;
                          });
                          state.didChange(newValue);
                        },
                      ),
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(state.errorText ?? '',
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Observaciones
            TextFormField(
              controller: _observacionesController,
              maxLength: 250,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observaciones (opcional)',
                hintText: 'Agregate información adicional',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: _validateObservaciones,
            ),
            const SizedBox(height: 24),
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _mostrarConfirmacionCancelar,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: _guardarReporte,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _reporteEnEdicion != null
                                ? 'Actualizar Reporte'
                                : 'Enviar Reporte',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialReportes() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return FutureBuilder<List<SeguridadAlimentariaModel>>(
      future: _service.obtenerReportes(user.email ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error.toString()}'));
        }

        final reportes = snapshot.data ?? [];

        if (reportes.isEmpty) {
          return const Center(
            child: Text('No hay reportes de seguridad alimentaria aún'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reportes.length,
          itemBuilder: (context, index) {
            final reporte = reportes[index];
            final puedeEditar =
                DateTime.now().difference(reporte.fechaRegistro).inDays <= 7;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                            const Text(
                              'Alimento:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              reporte.alimentoEscaso,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getColorPrioridad(reporte.prioridad),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            reporte.prioridad,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cantidad: ${reporte.cantidadNecesaria} ${reporte.unidad}',
                                  style: const TextStyle(fontSize: 13)),
                              Text(
                                '${reporte.fechaRegistro.day}/${reporte.fechaRegistro.month}/${reporte.fechaRegistro.year}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Proveedor: ${reporte.nombreProveedor}',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Teléfono: ${reporte.telefonoProveedor}',
                              style: const TextStyle(
                                  fontSize: 13, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 8),
                          Text('Sector: ${reporte.ubicacion}',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('Frecuencia: ${reporte.frecuenciaEscasez}',
                              style: const TextStyle(fontSize: 13)),
                          if (reporte.observaciones.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Obs: ${reporte.observaciones}',
                                style: const TextStyle(
                                    fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                          if (reporte.editado == true) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Editado',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (puedeEditar)
                          ElevatedButton.icon(
                            onPressed: () =>
                                _cargarReporteParaEdicion(reporte),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Editar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          )
                        else
                          const Text(
                            'No se puede editar (> 7 días)',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _mostrarConfirmacionEliminar(
                              context, reporte.id),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
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

  Color _getColorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'Baja':
        return Colors.green;
      case 'Media':
        return Colors.orange;
      case 'Alta':
        return Colors.deepOrange;
      case 'Urgente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _mostrarConfirmacionEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Eliminar Reporte'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este reporte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.eliminarReporte(id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Reporte eliminado'),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {});
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
