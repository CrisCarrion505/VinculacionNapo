import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    
    if (value.length < 6) {
      return '⚠️ La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠️ Por favor ingresa tu nombre';
    }
    
    if (value.length < 3) {
      return '⚠️ El nombre debe tener al menos 3 caracteres';
    }
    
    return null;
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
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

        // Guardar información del usuario en Firestore
        await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
          'nombre': _nameController.text.trim(),
          'correo': _emailController.text.trim(),
          'role': _selectedRole,
          'fechaRegistro': DateTime.now(),
        });

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
                        hintText: 'Mínimo 6 caracteres',
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
    super.dispose();
  }
}
