import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

class OrdenesPage extends ConsumerWidget {
  const OrdenesPage({super.key});

  Future<List<dynamic>> fetchOrdenes(String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.0.133:5000/ordenes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar órdenes');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Órdenes del Cliente")),
      body: user == null || user.token == null
          ? const Center(child: Text("Debes iniciar sesión"))
          : FutureBuilder<List<dynamic>>(
              future: fetchOrdenes(user.token!), // ✅ token no nulo
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay órdenes disponibles"));
                }

                final ordenes = snapshot.data!;
                return ListView.builder(
                  itemCount: ordenes.length,
                  itemBuilder: (context, index) {
                    final orden = ordenes[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text("Orden #${orden['id_orden']} - ${orden['estado']}"),
                        subtitle: Text(
                          "Servicio: ${orden['servicio']}\n"
                          "Cliente: ${orden['cliente']}\n"
                          "Fecha: ${orden['fecha']}\n"
                          "Costo: ${orden['costo']}",
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
