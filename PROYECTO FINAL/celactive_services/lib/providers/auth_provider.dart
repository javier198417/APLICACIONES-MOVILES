import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/cliente.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<Cliente?> {
  AuthNotifier() : super(null);

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  final AuthService _authService = AuthService(
    baseUrl: 'http://192.168.0.133:5000',
  );

  /// LOGIN
  Future<bool> login(
    String correo,
    String contrasena,
  ) async {
    try {
      final data = await _authService.login(
        correo,
        contrasena,
      );

      final cliente = Cliente(
        idCliente: data['id_cliente'],
        nombre: data['user'],
        correo: correo,
        telefono: data['telefono'] ?? '',
      );

      state = cliente;

      await _storage.write(
        key: 'token',
        value: data['token'],
      );

      await _storage.write(
        key: 'id_cliente',
        value: cliente.idCliente.toString(),
      );

      await _storage.write(
        key: 'nombre',
        value: cliente.nombre,
      );

      await _storage.write(
        key: 'correo',
        value: cliente.correo,
      );

      await _storage.write(
        key: 'telefono',
        value: cliente.telefono,
      );

      print('✅ Login exitoso');
      print('Usuario: ${cliente.nombre}');

      return true;
    } catch (e) {
      print('❌ Error en login: $e');
      return false;
    }
  }

  /// REGISTRO
  Future<bool> register(
    String nombre,
    String correo,
    String telefono,
    String contrasena,
  ) async {
    try {
      final response = await _authService.register(
        nombre,
        correo,
        telefono,
        contrasena,
      );

      return response['status'] == 'ok';
    } catch (e) {
      print('❌ Error en registro: $e');
      return false;
    }
  }

  /// CARGAR SESIÓN GUARDADA
  Future<void> loadSession() async {
    try {
      final token = await _storage.read(key: 'token');

      if (token == null) return;

      final idCliente =
          await _storage.read(key: 'id_cliente');
      final nombre =
          await _storage.read(key: 'nombre');
      final correo =
          await _storage.read(key: 'correo');
      final telefono =
          await _storage.read(key: 'telefono');

      if (idCliente != null &&
          nombre != null &&
          correo != null) {
        state = Cliente(
          idCliente: int.parse(idCliente),
          nombre: nombre,
          correo: correo,
          telefono: telefono ?? '',
        );
      }
    } catch (e) {
      print('Error cargando sesión: $e');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    state = null;
    await _storage.deleteAll();
    print('✅ Sesión cerrada');
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, Cliente?>(
  (ref) => AuthNotifier(),
);