import 'package:go_router/go_router.dart';
import 'package:kc_auth_app/features/authenticator/screens/authenticator_screen.dart';
import 'package:kc_auth_app/app/screens/home_screen.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/authenticator',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/authenticator',
        name: 'authenticator',
        builder: (context, state) => const AuthenticatorScreen(),
      ),
    ],
  );
}
