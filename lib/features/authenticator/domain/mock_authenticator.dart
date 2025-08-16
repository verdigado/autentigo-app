import 'package:keycloak_authenticator/api.dart';

class MockAuthenticator implements Authenticator {
  @override
  Future<Challenge> fetchChallenge({bool async = false}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
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
      expiresIn: 60,
    );
  }

  @override
  Future<void> reply({required Challenge challenge, required bool granted}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  String getId() {
    return 'id';
  }

  @override
  String? getLabel() {
    return 'Mock';
  }
}
