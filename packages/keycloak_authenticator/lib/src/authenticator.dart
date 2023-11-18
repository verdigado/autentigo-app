library keycloak_authenticator;

import 'package:keycloak_authenticator/src/dtos/challenge.dart';
import 'package:keycloak_authenticator/src/dtos/authenticator_info.dart';

abstract class Authenticator {
  String getId();
  String? getLabel();
  Future<Challenge?> fetchChallenge();
  Future<void> reply({required Challenge challenge, required bool granted});
  // AuthenticatorInfo getInfo();
}
