import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  List servicios = [];

  Future<void> obtenerServicios() async {
    final url = Uri.parse('http://192.168.0.120:5000/servicios');
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      setState(() {
        servicios = json.decode(respuesta.body);
      });
    } else {
      debugPrint('Error al obtener servicios: ${respuesta.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerServicios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios disponibles'),
        backgroundColor: Colors.teal,
      ),
      body: servicios.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: servicios.length,
              itemBuilder: (context, index) {
                final servicio = servicios[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.build, color: Colors.teal),
                    title: Text(servicio['nombre_servicio']),
                    subtitle: Text('Costo: \$${servicio['costo_base']}'),
                    trailing: Text(servicio['tipo']),
                  ),
                );
              },
            ),
    );
  }
}
