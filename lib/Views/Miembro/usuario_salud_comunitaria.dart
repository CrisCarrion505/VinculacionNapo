import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_vinculacion/Modelos/salud_comunitaria_model.dart';
import 'package:proyecto_vinculacion/Servicios/salud_comunitaria_service.dart';

class UsuarioSaludComunitariaView extends StatefulWidget {
  const UsuarioSaludComunitariaView({super.key});

  @override
  State<UsuarioSaludComunitariaView> createState() =>
      _UsuarioSaludComunitariaViewState();
}

class _UsuarioSaludComunitariaViewState
    extends State<UsuarioSaludComunitariaView> {
  final SaludComunitariaService _service = SaludComunitariaService();
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;

  // Form fields
  String? _enfermedadSeleccionada;
  String? _rangoEdadSeleccionado;
  int? _edadExacta;
  String? _generoSeleccionado;
  List<String> _sintomasSeleccionados = [];
  final TextEditingController _otrosSintomasController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Lista de enfermedades disponibles
  final List<String> _enfermedades = [
    'Gripe',
    'Diarrea',
    'Tos',
    'Fiebre',
    'Dolor de Cabeza',
    'Infección Respiratoria',
    'Gastroenteritis',
    'Alergia',
    'Otra enfermedad',
  ];

  // Síntomas genéricos
  final Map<String, List<String>> _sintomasGeneral = {
    'Gripe': ['Fiebre', 'Tos', 'Dolor de garganta', 'Escalofríos', 'Fatiga'],
    'Diarrea': ['Dolor abdominal', 'Heces sueltas', 'Nauseas', 'Vómitos'],
    'Tos': ['Tos seca', 'Tos con flemas', 'Dolor al toser', 'Garganta irritada'],
    'Fiebre': ['Temperatura alta', 'Escalofríos', 'Sudoración', 'Debilidad'],
    'Dolor de Cabeza': ['Dolor frontal', 'Migraña', 'Presión en la cabeza'],
    'Infección Respiratoria': ['Congestión', 'Estornudos', 'Secreción nasal', 'Tos'],
    'Gastroenteritis': ['Dolor abdominal', 'Vómitos', 'Diarrea', 'Pérdida de apetito'],
    'Alergia': ['Picazón', 'Rash', 'Hinchazón', 'Estornudos'],
    'Otra enfermedad': ['Síntoma 1', 'Síntoma 2', 'Síntoma 3'],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _otrosSintomasController.dispose();
    super.dispose();
  }

  String? _validateRangoEdad(String? value) {
    if (_rangoEdadSeleccionado == null) {
      return 'Por favor selecciona un rango de edad';
    }
    return null;
  }

  String? _validateEdadExacta(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu edad exacta';
    }
    final edad = int.tryParse(value);
    if (edad == null || edad < 0 || edad > 120) {
      return 'Edad inválida (0-120)';
    }

    // Validar coherencia con rango seleccionado usando rangoEdadLimites
    if (_rangoEdadSeleccionado != null) {
      final limites = rangoEdadLimites[_rangoEdadSeleccionado];
      if (limites != null) {
        final min = limites['min'] as int;
        final max = limites['max'] as int;
        
        if (edad < min || edad > max) {
          return 'La edad debe estar entre $min y $max para el rango seleccionado';
        }
      }
    }

    return null;
  }

  String? _validateEnfermedad(String? value) {
    if (_enfermedadSeleccionada == null) {
      return 'Por favor selecciona una enfermedad';
    }
    return null;
  }

  String? _validateGenero(String? value) {
    if (_generoSeleccionado == null) {
      return 'Por favor selecciona un género';
    }
    return null;
  }

  String? _validateSintomas(List<String>? value) {
    if (_sintomasSeleccionados.isEmpty) {
      return 'Por favor selecciona al menos un síntoma';
    }
    return null;
  }

  String? _validateOtrosSintomas(String? value) {
    if ((value ?? '').isNotEmpty && value!.length > 200) {
      return 'Máximo 200 caracteres';
    }
    return null;
  }

  void _guardarRegistro() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Usuario no autenticado');

        final registro = SaludComunitariaModel(
          correo: user.email ?? '',
          enfermedad: _enfermedadSeleccionada ?? '',
          rangoEdad: _rangoEdadSeleccionado ?? '',
          edadExacta: _edadExacta ?? 0,
          genero: _generoSeleccionado ?? '',
          sintomasSeleccionados: _sintomasSeleccionados,
          otrosSintomas: _otrosSintomasController.text.trim(),
          fechaRegistro: DateTime.now(),
        );

        await _service.agregarRegistroSalud(registro);

        if (!mounted) return;

        // Limpiar formulario
        setState(() {
          _enfermedadSeleccionada = null;
          _rangoEdadSeleccionado = null;
          _edadExacta = null;
          _generoSeleccionado = null;
          _sintomasSeleccionados = [];
          _otrosSintomasController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registro guardado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
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

  void _mostrarConfirmacionCancelar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Cancelar Registro'),
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
              setState(() {
                _enfermedadSeleccionada = null;
                _rangoEdadSeleccionado = null;
                _edadExacta = null;
                _generoSeleccionado = null;
                _sintomasSeleccionados = [];
                _otrosSintomasController.clear();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Descartar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salud Comunitaria'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildFormularioRegistro(),
          _buildHistorialRegistros(),
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
            label: 'Nuevo Registro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioRegistro() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nuevo Registro de Salud',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Enfermedad
            FormField<String>(
              validator: _validateEnfermedad,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enfermedad *',
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
                        value: _enfermedadSeleccionada,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecciona una enfermedad'),
                        items: _enfermedades.map((String enfermedad) {
                          return DropdownMenuItem<String>(
                            value: enfermedad,
                            child: Text(enfermedad),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _enfermedadSeleccionada = newValue;
                            _sintomasSeleccionados = [];
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
            // Rango de Edad
            FormField<String>(
              validator: _validateRangoEdad,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rango de Edad *',
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
                        value: _rangoEdadSeleccionado,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecciona tu rango de edad'),
                        items: rangosEdad.map((String rango) {
                          return DropdownMenuItem<String>(
                            value: rango,
                            child: Text(rango),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _rangoEdadSeleccionado = newValue;
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
            // Edad Exacta
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Edad Exacta *',
                hintText: 'Ej: 25',
                prefixIcon: const Icon(Icons.cake),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _edadExacta = int.tryParse(value);
                }
              },
              validator: _validateEdadExacta,
            ),
            const SizedBox(height: 20),
            // Género
            FormField<String>(
              validator: _validateGenero,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Género *',
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
                        value: _generoSeleccionado,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Selecciona tu género'),
                        items: generos.map((String genero) {
                          return DropdownMenuItem<String>(
                            value: genero,
                            child: Text(genero),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _generoSeleccionado = newValue;
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
            // Síntomas
            if (_enfermedadSeleccionada != null)
              FormField<List<String>>(
                validator: _validateSintomas,
                builder: (state) {
                  final sintomas =
                      _sintomasGeneral[_enfermedadSeleccionada] ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Síntomas de $_enfermedadSeleccionada *',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                state.hasError ? Colors.red : Colors.grey,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: sintomas.map((sintoma) {
                            return CheckboxListTile(
                              title: Text(sintoma),
                              value: _sintomasSeleccionados.contains(sintoma),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _sintomasSeleccionados.add(sintoma);
                                  } else {
                                    _sintomasSeleccionados.remove(sintoma);
                                  }
                                });
                                state.didChange(_sintomasSeleccionados);
                              },
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                            );
                          }).toList(),
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
            // Otros Síntomas
            TextFormField(
              controller: _otrosSintomasController,
              maxLength: 200,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Otros Síntomas (opcional)',
                hintText: 'Describe otros síntomas hasta 200 caracteres',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: _validateOtrosSintomas,
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
                          onPressed: _guardarRegistro,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Enviar Registro',
                            style: TextStyle(
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

  Widget _buildHistorialRegistros() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return FutureBuilder<List<SaludComunitariaModel>>(
      future: _service.obtenerRegistrosSalud(user.email ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error.toString()}'));
        }

        final registros = snapshot.data ?? [];

        if (registros.isEmpty) {
          return const Center(
            child: Text('No hay registros de salud aún'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: registros.length,
          itemBuilder: (context, index) {
            final registro = registros[index];
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
                              'Enfermedad:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              registro.enfermedad,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Fecha:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${registro.fechaRegistro.day}/${registro.fechaRegistro.month}/${registro.fechaRegistro.year}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
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
                          Text('Edad: ${registro.edadExacta} años (${registro.rangoEdad})',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('Género: ${registro.genero}',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          const Text('Síntomas:',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 8,
                            children: registro.sintomasSeleccionados
                                .map((sintoma) => Chip(label: Text(sintoma)))
                                .toList(),
                          ),
                          if (registro.otrosSintomas.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Otros: ${registro.otrosSintomas}',
                                style: const TextStyle(
                                    fontSize: 13, fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
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
}
