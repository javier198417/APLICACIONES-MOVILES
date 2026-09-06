import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../pages/login.dart';
import '../pages/register_page.dart';
import '../pages/perfil_page.dart';
import '../pages/historial.dart';
import '../pages/servicios.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final cliente = ref.watch(authProvider);

  return GoRouter(
    initialLocation:
        cliente == null ? '/login' : '/servicios',

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const RegisterPage(),
      ),

      GoRoute(
        path: '/servicios',
        builder: (context, state) =>
            const ServiciosPage(),
      ),

      GoRoute(
        path: '/perfil',
        builder: (context, state) =>
            const PerfilPage(),
      ),

      GoRoute(
        path: '/historial',
        builder: (context, state) {
          if (cliente != null) {
            return HistorialPage(
              idCliente: cliente.idCliente,
            );
          }

          return const LoginScreen();
        },
      ),
    ],

    redirect: (context, state) {
      final loggedIn = cliente != null;

      final currentRoute =
          state.matchedLocation;

      final isLogin =
          currentRoute == '/login';

      final isRegister =
          currentRoute == '/register';

      // Usuario NO autenticado
      if (!loggedIn &&
          !isLogin &&
          !isRegister) {
        return '/login';
      }

      // Usuario autenticado
      if (loggedIn &&
          (isLogin || isRegister)) {
        return '/servicios';
      }

      return null;
    },
  );
});