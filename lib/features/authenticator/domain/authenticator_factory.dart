import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:authenticator_app/app/config/config.dart';
import 'package:keycloak_authenticator/api.dart';
import 'mock_authenticator.dart';

class AuthenticatorFactory {
  static AuthenticatorService create() {
    var config = GetIt.I<AppConfig>();
    return AuthenticatorService(
      storage: FlutterSecureStorageAdapter(const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      )),
    );
  }

  static Authenticator createMock() {
    return MockAuthenticator();
  }
}
