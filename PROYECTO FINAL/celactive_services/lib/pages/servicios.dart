import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class ServiciosPage extends ConsumerStatefulWidget {
  const ServiciosPage({super.key});

  @override
  ConsumerState<ServiciosPage> createState() =>
      _ServiciosPageState();
}

class _ServiciosPageState
    extends ConsumerState<ServiciosPage> {
  List servicios = [];
  bool cargando = true;
  String? error;

  Future<void> obtenerServicios() async {
    try {
      final url = Uri.parse(
        'http://192.168.0.133:5000/servicios',
      );

      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        setState(() {
          servicios = json.decode(respuesta.body);
          cargando = false;
        });
      } else {
        setState(() {
          error =
              'Error al obtener servicios: ${respuesta.statusCode}';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Excepción: $e';
        cargando = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerServicios();
  }

  Future<void> cerrarSesion() async {
    await ref.read(authProvider.notifier).logout();

    if (!mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios disponibles'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              context.go('/perfil');
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
            onPressed: () {
              context.go('/historial');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
          ),
        ],
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                )
              : servicios.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay servicios disponibles',
                      ),
                    )
                  : ListView.builder(
                      itemCount: servicios.length,
                      itemBuilder: (context, index) {
                        final servicio = servicios[index];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.build,
                              color: Colors.teal,
                              size: 32,
                            ),
                            title: Text(
                              servicio['nombre_servicio'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Costo: \$${servicio['costo_base']}',
                            ),
                            trailing: Text(
                              servicio['tipo'],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

