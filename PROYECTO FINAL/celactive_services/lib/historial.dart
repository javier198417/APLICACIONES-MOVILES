import 'package:flutter/material.dart'; // 👈 Import esencial
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistorialScreen extends StatefulWidget {
  final int idCliente; // Recibe el ID del cliente

  const HistorialScreen({super.key, required this.idCliente});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List historial = [];

  @override
  void initState() {
    super.initState();
    obtenerHistorial(widget.idCliente); // Llamada al cargar la pantalla
  }

  Future<void> obtenerHistorial(int idCliente) async {
    final url = Uri.parse('http://192.168.0.120:5000/historial/$idCliente');
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      setState(() {
        historial = json.decode(respuesta.body);
      });
    } else {
      debugPrint('Error al obtener historial: ${respuesta.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de servicios'),
        backgroundColor: Colors.teal,
      ),
      body: historial.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final item = historial[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.teal),
                    title: Text(item['nombre_servicio']),
                    subtitle: Text('Estado: ${item['estado']} - Fecha: ${item['fecha']}'),
                    trailing: Text('\$${item['costo']}'),
                  ),
                );
              },
            ),
    );
  }
}
