import 'package:keycloak_authenticator/api.dart';

class MockAuthenticator implements Authenticator {
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
  Future<void> setup(String activationToken) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> remove() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool> isRegistered() async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }

  @override
  Future<AuthenticatorInfo> getInfo() {
    // TODO: implement getInfo
    throw UnimplementedError();
  }

  @override
  Future<void> reply(
      {required Challenge challenge, required bool granted}) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
