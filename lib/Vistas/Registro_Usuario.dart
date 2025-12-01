import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();
  String _role = 'Comunidad';
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'id': _idController.text.trim(),
        'phone': _phoneController.text.trim(),
        'community': _communityController.text.trim(),
        'role': _role,
        'uid': userCredential.user!.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Registro')),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.teal],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Nombres completos', Icons.person),
                        validator: (value) => value!.isEmpty ? 'Ingrese su nombre' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration('Correo electrónico', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.contains('@') ? null : 'Correo inválido',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: _passwordInputDecoration(),
                        validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        decoration: _inputDecoration('Dirección', Icons.home),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _idController,
                        decoration: _inputDecoration('Cédula', Icons.document_scanner),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration('Teléfono', Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _communityController,
                        decoration: _inputDecoration('Comunidad a la que pertenece', Icons.group),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        items: ['Líder', 'Comunidad'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value), // Texto a mostrar
                          );
                        }).toList(),
                        decoration: _inputDecoration('Rol', Icons.work),
                        onChanged: (String? newValue) {
                          setState(() => _role = newValue!);
                        },
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    prefixIcon: Icon(icon, color: Colors.teal),
  );
}

InputDecoration _passwordInputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    labelText: 'Contraseña',
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
      onPressed: () => setState(() => _isObscure = !_isObscure),
    ),
  );
}
}