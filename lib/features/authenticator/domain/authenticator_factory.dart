import 'package:flutter_keycloak_authenticator/flutter_keycloak_authenticator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticatorFactory {
  static AuthenticatorService create() =>
      AuthenticatorService(storage: FlutterSecureStorageAdapter(const FlutterSecureStorage()));
}
