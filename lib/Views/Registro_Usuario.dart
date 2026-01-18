import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_vinculacion/datos_pano_tena.dart';
import 'Login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isObscurePassword = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;
  String _selectedRole = 'Miembro'; // Por defecto
  
  // Variables para servicios y ubicaciones (solo para Miembro)
  Set<String> _serviciosSeleccionados = {};
  Set<String> _ubicacionesSeleccionadas = {};
  List<String> _ubicacionesFiltradas = [];
  final TextEditingController _otroServicioController = TextEditingController();
  final TextEditingController _otroUbicacionController = TextEditingController();
  
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠️ Por favor ingresa tu correo electrónico';
    }
    
    value = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return '⚠️ Ingresa un correo válido';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠️ Por favor ingresa una contraseña';
    }
    
    // Requisitos: mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número, 1 carácter especial
    if (value.length < 8) {
      return '⚠️ La contraseña debe tener al menos 8 caracteres';
    }

    final upper = RegExp(r'[A-Z]');
    final lower = RegExp(r'[a-z]');
    final digit = RegExp(r'\d');
    final special = RegExp(r'[!@#$%^&*()\,.?":{}|<>\[\];_\-=+/]');

    if (!upper.hasMatch(value)) return '⚠️ La contraseña debe tener al menos una letra mayúscula';
    if (!lower.hasMatch(value)) return '⚠️ La contraseña debe tener al menos una letra minúscula';
    if (!digit.hasMatch(value)) return '⚠️ La contraseña debe incluir al menos un número';
    if (!special.hasMatch(value)) return '⚠️ La contraseña debe incluir al menos un carácter especial';

    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠️ Por favor ingresa tu nombre';
    }
    
    // No permitir números en el nombre
    final hasDigits = RegExp(r'\d');
    if (hasDigits.hasMatch(value)) {
      return '⚠️ El nombre no debe contener números';
    }

    if (value.trim().length < 3) {
      return '⚠️ El nombre debe tener al menos 3 caracteres';
    }

    return null;
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      // Si es Miembro, validar que seleccione servicios y ubicaciones
      if (_selectedRole == 'Miembro' && _serviciosSeleccionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Debes seleccionar al menos un servicio turístico'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedRole == 'Miembro' && _ubicacionesSeleccionadas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Debes seleccionar al menos una ubicación'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Crear usuario en Firebase Auth
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Preparar datos del usuario
        Map<String, dynamic> userData = {
          'nombre': _nameController.text.trim(),
          'correo': _emailController.text.trim(),
          'role': _selectedRole,
          'fechaRegistro': DateTime.now(),
        };

        // Si es Miembro, agregar servicios y ubicaciones
        if (_selectedRole == 'Miembro') {
          // Incluir servicios personalizados si los hay
          List<String> serviciosFinal = List.from(_serviciosSeleccionados);
          if (_otroServicioController.text.trim().isNotEmpty) {
            serviciosFinal.add(_otroServicioController.text.trim());
          }

          // Incluir ubicaciones personalizadas si las hay
          List<String> ubicacionesFinal = List.from(_ubicacionesSeleccionadas);
          if (_otroUbicacionController.text.trim().isNotEmpty) {
            ubicacionesFinal.add(_otroUbicacionController.text.trim());
          }

          userData['serviciosAsignados'] = serviciosFinal;
          userData['ubicacionesAsignadas'] = ubicacionesFinal;
        }

        // Guardar información del usuario en Firestore
        await _firestore.collection('usuarios').doc(userCredential.user!.uid).set(userData);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registro exitoso. Por favor inicia sesión'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Esperar 2 segundos y luego navegar al login
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
      } on FirebaseAuthException catch (e) {
        String mensaje = '';
        
        if (e.code == 'email-already-in-use') {
          mensaje = '❌ Este correo electrónico ya está registrado';
        } else if (e.code == 'weak-password') {
          mensaje = '❌ La contraseña es muy débil';
        } else if (e.code == 'invalid-email') {
          mensaje = '❌ El correo electrónico es inválido';
        } else {
          mensaje = '❌ Error al registrarse: ${e.message ?? "Error desconocido"}';
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: ${e.toString()}'),
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
  }

  /// Actualizar ubicaciones filtradas cuando cambian los servicios
  void _actualizarUbicacionesFiltradas() {
    Set<String> ubicacionesFiltradas = {};
    
    for (String servicio in _serviciosSeleccionados) {
      if (servicioUbicacionesMap.containsKey(servicio)) {
        ubicacionesFiltradas.addAll(servicioUbicacionesMap[servicio]!);
      }
    }

    setState(() {
      _ubicacionesFiltradas = ubicacionesFiltradas.toList()..sort();
      // Remover ubicaciones que ya no son válidas
      _ubicacionesSeleccionadas.retainWhere((u) => ubicacionesFiltradas.contains(u));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.teal],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Crear Cuenta",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Nombre completo',
                        hintText: 'Juan Pérez',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.person, color: Colors.teal),
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Correo electrónico',
                        hintText: 'ejemplo@correo.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.teal),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Contraseña',
                        hintText: 'Ingresar Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.teal,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscurePassword = !_isObscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _isObscureConfirm,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Confirmar contraseña',
                        hintText: 'Repite tu contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureConfirm ? Icons.visibility_off : Icons.visibility,
                            color: Colors.teal,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscureConfirm = !_isObscureConfirm;
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ['Miembro', 'Líder'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                      ),
                    ),
                    // Mostrar selectores de servicios y ubicaciones solo para Miembro
                    if (_selectedRole == 'Miembro') ...[
                      const SizedBox(height: 20),
                      // Selector de Servicios Turísticos
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Elegir servicio turístico',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tiposServicioTuristico.map((servicio) {
                                final isSelected = _serviciosSeleccionados.contains(servicio);
                                return FilterChip(
                                  label: Text(servicio),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        _serviciosSeleccionados.add(servicio);
                                      } else {
                                        _serviciosSeleccionados.remove(servicio);
                                      }
                                      _actualizarUbicacionesFiltradas();
                                    });
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: Colors.teal[300],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _otroServicioController,
                              decoration: InputDecoration(
                                hintText: 'Otro servicio (opcional)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.add, color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Selector de Ubicaciones
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Elegir ubicación',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_ubicacionesFiltradas.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Selecciona servicios primero',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _ubicacionesFiltradas.map((ubicacion) {
                                  final isSelected = _ubicacionesSeleccionadas.contains(ubicacion);
                                  return FilterChip(
                                    label: Text(ubicacion, overflow: TextOverflow.ellipsis),
                                    selected: isSelected,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        if (selected) {
                                          _ubicacionesSeleccionadas.add(ubicacion);
                                        } else {
                                          _ubicacionesSeleccionadas.remove(ubicacion);
                                        }
                                      });
                                    },
                                    backgroundColor: Colors.grey[200],
                                    selectedColor: Colors.blue[300],
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _otroUbicacionController,
                              decoration: InputDecoration(
                                hintText: 'Otra ubicación (opcional)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otroServicioController.dispose();
    _otroUbicacionController.dispose();
    super.dispose();
  }
}
