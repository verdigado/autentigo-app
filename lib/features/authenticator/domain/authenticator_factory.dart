import 'package:get_it/get_it.dart';
import 'package:gruene_auth_app/app/config/config.dart';
import 'package:keycloak_authenticator/keycloak_authenticator.dart';
import 'mock_authenticator.dart';

class AuthenticatorFactory {
  static AuthenticatorInterface create() {
    var config = GetIt.I<AppConfig>();
    return KeycloakAuthenticator(
      client: KeycloakAuthenticatorClient(
        baseUrl: config.keycloakBaseUrl,
        realm: config.keycloakRealm,
      ),
    );
  }

  static AuthenticatorInterface createMock() {
    return MockAuthenticator();
  }
}
