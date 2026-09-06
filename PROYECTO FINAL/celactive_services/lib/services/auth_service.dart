import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<Map<String, dynamic>> login(
    String correo,
    String contrasena,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    print('Status Code Login: ${response.statusCode}');
    print('Body Login: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['status'] == 'ok') {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Credenciales inválidas',
    );
  }

  Future<Map<String, dynamic>> register(
    String nombre,
    String correo,
    String telefono,
    String contrasena,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'contrasena': contrasena,
      }),
    );

    print('Status Code Register: ${response.statusCode}');
    print('Body Register: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Error al registrar usuario',
    );
  }
}