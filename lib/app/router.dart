import 'package:autentigo_app/app/screens/home_screen.dart';
import 'package:autentigo_app/features/authenticator/screens/authenticator_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/authenticator',
    routes: [
      GoRoute(path: '/', name: 'home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/authenticator', name: 'authenticator', builder: (context, state) => const AuthenticatorScreen()),
    ],
  );
}
