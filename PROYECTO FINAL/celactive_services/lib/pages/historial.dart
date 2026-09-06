import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class HistorialPage extends ConsumerStatefulWidget {
  final int idCliente;

  const HistorialPage({
    super.key,
    required this.idCliente,
  });

  @override
  ConsumerState<HistorialPage> createState() =>
      _HistorialPageState();
}

class _HistorialPageState
    extends ConsumerState<HistorialPage> {
  List historial = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    obtenerHistorial(widget.idCliente);
  }

  Future<void> obtenerHistorial(int idCliente) async {
    try {
      final url = Uri.parse(
        'http://192.168.0.133:5000/historial/$idCliente',
      );

      print(
        'URL HISTORIAL: http://192.168.0.133:5000/historial/$idCliente',
      );

      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        setState(() {
          historial = json.decode(respuesta.body);
          cargando = false;
        });
      } else {
        setState(() {
          error =
              'Error al obtener historial: ${respuesta.statusCode}';
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

  Future<void> cerrarSesion() async {
    await ref.read(authProvider.notifier).logout();

    if (!mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de servicios'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Servicios',
            onPressed: () {
              context.go('/servicios');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              context.go('/perfil');
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
                  child: Text(error!),
                )
              : historial.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay servicios en el historial',
                      ),
                    )
                  : ListView.builder(
                      itemCount: historial.length,
                      itemBuilder: (context, index) {
                        final item = historial[index];

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.assignment,
                              color: Colors.teal,
                            ),
                            title: Text(
                              item['nombre_servicio'] ??
                                  'Servicio',
                            ),
                            subtitle: Text(
                              'Estado: ${item['estado'] ?? 'N/A'}\n'
                              'Fecha: ${item['fecha'] ?? 'N/A'}',
                            ),
                            trailing: Text(
                              '\$${item['costo'] ?? '0'}',
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}