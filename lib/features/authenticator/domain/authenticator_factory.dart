import 'package:authenticator_app/features/authenticator/domain/mock_authenticator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:keycloak_authenticator/api.dart';

class AuthenticatorFactory {
  static AuthenticatorService create() {
    return AuthenticatorService(
      storage: FlutterSecureStorageAdapter(
        const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        ),
      ),
    );
  }

  static Authenticator createMock() {
    return MockAuthenticator();
  }
}
