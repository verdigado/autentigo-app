library keycloak_authenticator;

import 'package:keycloak_authenticator/src/dtos/challenge.dart';
import 'package:keycloak_authenticator/src/dtos/authenticator_info.dart';

abstract class Authenticator {
  Future<bool> isRegistered();
  Future<void> setup(String aktivationToken);
  Future<Challenge?> fetchChallenge();
  Future<void> reply({required Challenge challenge, required bool granted});
  Future<void> remove();
  Future<AuthenticatorInfo> getInfo();
}
