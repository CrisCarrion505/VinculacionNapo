import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'package:proyecto_vinculacion/Vistas/admin_comunitaria.dart';
import 'package:proyecto_vinculacion/Vistas/GestionTuristica.dart';
import 'package:proyecto_vinculacion/Vistas/admin_eco_familiar.dart';
import 'package:proyecto_vinculacion/Vistas/derecho_laboral.dart';  // ← NUEVO
import 'package:proyecto_vinculacion/Vistas/liderazgo_Comunitario.dart';  // ← NUEVO

class LiderComunidad extends StatefulWidget {
  const LiderComunidad({super.key});

  @override
  State<LiderComunidad> createState() => _LiderComunidadState();
}

class _LiderComunidadState extends State<LiderComunidad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Líder comunidad"),
        actions: [
          IconButton(
            onPressed: () {
              _mostrarInfoApp(context);
            },
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.60,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Servicios ofrecidos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.2,
                            children: [
                              _crearBoton(context, 'Administración comunitaria', Icons.business, const AdminComunitaria()),
                              _crearBoton(context, 'Técnicas tributarias', Icons.account_balance, null),  // ← Por hacer
                              _crearBoton(context, 'Liderazgo comunitario', Icons.group_work, const LiderazgoComunitario()),  // ← ACTUALIZADO
                              _crearBoton(context, 'Derecho laboral', Icons.gavel, const DerechoLaboral()),  // ← ACTUALIZADO
                              _crearBoton(context, 'Eco. familiar', Icons.monetization_on, const AdminEcoFamiliar()),
                              _crearBoton(context, 'Gestión turística', Icons.hotel, const TurismoComunitario()),
                            ],
                          ),
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
    );
  }

  Widget _crearBoton(BuildContext context, String texto, IconData icono, Widget? paginaDestino) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            if (paginaDestino != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => paginaDestino),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, color: Colors.teal, size: 40),
                const SizedBox(height: 5),
                Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _mostrarInfoApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Descripción de la Aplicación"),
          content: const Text(
              "Modelo de gestión de servicios que ayuda a los líderes comunitarios a identificar las necesidades de los miembros de las comunidades, promoviendo un enfoque integral para fortalecer la organización y la gestión comunitaria."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LiderComunidad(),
  ));
}