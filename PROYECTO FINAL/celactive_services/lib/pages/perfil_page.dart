import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class PerfilPage extends ConsumerWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Cliente'),
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
            icon: const Icon(Icons.history),
            tooltip: 'Historial',
            onPressed: () {
              context.go('/historial');
            },
          ),
        ],
      ),
      body: cliente == null
          ? const Center(
              child: Text('Debes iniciar sesión'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del usuario:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    '👤 Nombre: ${cliente.nombre}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '📧 Correo: ${cliente.correo}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '📱 Teléfono: ${cliente.telefono}',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    onPressed: () async {
                      await ref
                          .read(authProvider.notifier)
                          .logout();

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Sesión cerrada'),
                        ),
                      );

                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

