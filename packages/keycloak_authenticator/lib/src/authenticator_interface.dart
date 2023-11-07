library keycloak_authenticator;

import 'package:keycloak_authenticator/src/dtos/challenge.dart';

abstract class AuthenticatorInterface {
  Future<Challenge> fetchChallenge();
  Future<void> register(String aktivationToken);
  Future<void> unregister();
  Future<bool> isRegistered();
  Future<void> confirm(Challenge challenge);
  Future<void> deny(Challenge challenge);
}
