import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();

  bool cargando = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      cargando = true;
    });

    final success = await ref
        .read(authProvider.notifier)
        .login(
          correoController.text.trim(),
          contrasenaController.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('✅ Inicio de sesión correcto'),
        ),
      );

      context.go('/servicios');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('❌ Credenciales inválidas'),
        ),
      );
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Center(
                  child: Image.asset(
                    'assets/images/logo_flutter.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'CelActive Services',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Reparamos, optimizamos y protegemos tus dispositivos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),

                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller:
                              correoController,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Correo electrónico',
                            border:
                                OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.email,
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Ingrese un correo';
                            }

                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+$',
                            ).hasMatch(
                                value)) {
                              return 'Correo inválido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        TextFormField(
                          controller:
                              contrasenaController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Contraseña',
                            border:
                                OutlineInputBorder(),
                            prefixIcon:
                                Icon(
                              Icons.lock,
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .isEmpty) {
                              return 'Ingrese una contraseña';
                            }

                            if (value
                                    .length <
                                6) {
                              return 'Mínimo 6 caracteres';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 55,
                          child: cargando
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(),
                                )
                              : ElevatedButton(
                                  onPressed:
                                      login,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xFF009688,
                                    ),
                                    foregroundColor:
                                        Colors.white,
                                    elevation: 5,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        14,
                                      ),
                                    ),
                                  ),
                                  child:
                                      const Text(
                                    'INGRESAR',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  '¿Aún no tienes una cuenta?',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  child: const Text(
                    'Regístrate aquí',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'CelActive Services · Versión 1.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}