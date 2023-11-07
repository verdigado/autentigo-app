import 'package:keycloak_authenticator/keycloak_authenticator.dart';

class MockAuthenticator implements AuthenticatorInterface {
  @override
  Future<void> confirm(Challenge challenge) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> deny(Challenge challenge) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<Challenge> fetchChallenge() async {
    await Future.delayed(const Duration(seconds: 1));
    return Challenge(
      browser: 'Firefox',
      device: 'device',
      ipAddress: '154.612.134.124',
      os: 'Ubuntu',
      osVersion: 'osVersion',
      secret: 'Secret',
      targetUrl: 'targetUrl',
      updatedTimestamp: 1699304742628,
      userFirstName: 'Bob',
      userLastName: 'Doe',
      userName: 'Bob',
    );
  }

  @override
  Future<void> register(String activationToken) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> unregister() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool> isRegistered() async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }
}
