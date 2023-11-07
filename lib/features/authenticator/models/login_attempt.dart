import 'package:keycloak_authenticator/keycloak_authenticator.dart';

class LoginAttempt {
  final DateTime loggedInAt;
  final String ipAddress;
  final String browser;
  final String os;
  final Challenge challenge;

  LoginAttempt({
    required this.loggedInAt,
    required this.ipAddress,
    required this.browser,
    required this.os,
    required this.challenge,
  });
}
