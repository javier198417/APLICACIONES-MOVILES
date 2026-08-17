import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestConnection extends StatefulWidget {
  const TestConnection({super.key});

  @override
  State<TestConnection> createState() => _TestConnectionState();
}

class _TestConnectionState extends State<TestConnection> {
  String result = 'Presiona el botón para probar conexión';

  Future<void> testBackend() async {
    final url = Uri.parse('http://192.168.0.120:5000/servicios'); // IP local de tu PC
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('admin:celactive123'))}',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          result = '✅ Conexión exitosa:\n${response.body}';
        });
      } else if (response.statusCode == 401) {
        setState(() {
          result = '❌ Error 401: Credenciales incorrectas o faltantes';
        });
      } else {
        setState(() {
          result = '⚠️ Error: Código ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        result = '🚫 Falló la conexión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de conexión Flask'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: testBackend,
                icon: const Icon(Icons.cloud),
                label: const Text('Probar conexión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}