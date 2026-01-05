import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Registro_Usuario.dart';
import 'dashboard_miembro.dart';
import 'dashboard_lider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  // Validación mejorada de correo electrónico
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠️ Por favor ingresa tu correo electrónico';
    }
    
    // Eliminar espacios en blanco
    value = value.trim();
    
    // Regex para validar formato de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return '⚠️ Ingresa un correo válido (ejemplo: usuario@dominio.com)';
    }
    
    // Verificar que tenga un dominio válido (al menos 2 caracteres después del punto)
    final parts = value.split('@');
    if (parts.length != 2) {
      return '⚠️ El correo debe contener un solo @';
    }
    
    final domain = parts[1];
    if (!domain.contains('.') || domain.endsWith('.')) {
      return '⚠️ El dominio del correo no es válido';
    }
    
    // Verificar que el dominio tenga una extensión válida
    final domainParts = domain.split('.');
    final extension = domainParts.last;
    if (extension.length < 2) {
      return '⚠️ La extensión del dominio debe tener al menos 2 caracteres';
    }
    
    return null;
  }

  // Validación mejorada de contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '⚠️ Por favor ingresa tu contraseña';
    }
    
    if (value.length < 6) {
      return '⚠️ La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        route();
      } on FirebaseAuthException catch (e) {
        String mensaje = '';
        Color backgroundColor = Colors.red;
        
        switch (e.code) {
          case 'wrong-password':
          case 'invalid-credential':
            mensaje = '❌ Contraseña incorrecta. Por favor verifica e intenta nuevamente.';
            break;
          case 'user-not-found':
            mensaje = '❌ No existe una cuenta con este correo electrónico.';
            break;
          case 'invalid-email':
            mensaje = '❌ El formato del correo electrónico es inválido.';
            break;
          case 'user-disabled':
            mensaje = '🚫 Esta cuenta ha sido deshabilitada. Contacta al administrador.';
            break;
          case 'too-many-requests':
            mensaje = '⏱️ Demasiados intentos fallidos. Por favor espera unos minutos e intenta de nuevo.';
            backgroundColor = Colors.orange;
            break;
          case 'network-request-failed':
            mensaje = '📡 Error de conexión. Verifica tu conexión a internet.';
            backgroundColor = Colors.orange;
            break;
          default:
            mensaje = '❌ Error al iniciar sesión: ${e.message ?? "Error desconocido"}';
        }
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  void _resetPassword() async {
    final email = _emailController.text.trim();
    
    // Validar email antes de enviar
    final emailError = _validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Correo enviado exitosamente. Revisa tu bandeja de entrada y spam.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = '';
      
      switch (e.code) {
        case 'user-not-found':
          mensaje = '❌ No existe una cuenta registrada con este correo electrónico.';
          break;
        case 'invalid-email':
          mensaje = '❌ El formato del correo electrónico es inválido.';
          break;
        default:
          mensaje = '❌ Error al enviar correo: ${e.message ?? "Error desconocido"}';
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_reset, color: Colors.teal),
              SizedBox(width: 10),
              Text('Recuperar Contraseña'),
            ],
          ),
          content: Text(
            _emailController.text.trim().isEmpty
                ? 'Por favor ingresa tu correo electrónico en el campo de correo antes de continuar.'
                : '¿Deseas enviar un correo de recuperación a:\n\n${_emailController.text.trim()}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetPassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('Enviar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).get().then(
      (DocumentSnapshot documentSnapshot) {
        if (!mounted) return;
        
        if (documentSnapshot.exists) {
          if (documentSnapshot.get('role') == "Líder") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardLider()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardMiembro()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ El usuario no existe en la base de datos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    ).catchError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener datos del usuario: $error'),
          backgroundColor: Colors.red,
        ),
      );
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/imagenes/escudo.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint("Error al cargar la imagen: $error");
                          return const Icon(Icons.error, color: Colors.red, size: 50);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
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
                      obscureText: _isObscure,
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
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.teal,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showResetPasswordDialog,
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: const Text(
                        '¿No tienes cuenta? Regístrate',
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
}