import 'dart:convert';

import 'package:keycloak_authenticator/src/authenticator.dart';
import 'package:keycloak_authenticator/src/keycloak_client.dart';
import 'package:keycloak_authenticator/src/dtos/challenge.dart';
import 'package:keycloak_authenticator/src/dtos/authenticator_info.dart';
import 'package:keycloak_authenticator/src/enums/enums.dart';
import 'package:keycloak_authenticator/src/storage/storage.dart';

class KeycloakAuthenticator implements Authenticator {
  static const keyKeyPair = 'authenticator_key_pair';
  final Storage _storage;
  late KeycloakClient _client;
  final SignatureAlgorithm _defaultAlgorithm;

  KeycloakAuthenticator({
    required Storage storage,
    required String baseUrl,
    required String realm,
    SignatureAlgorithm defaultAlgorithm = SignatureAlgorithm.SHA512withRSA,
  })  : _storage = storage,
        _defaultAlgorithm = defaultAlgorithm {
    _client = KeycloakClient(baseUrl: baseUrl, realm: realm);
  }

  Future<String> _sign(String value) async {
    throw UnimplementedError();
  }

  @override
  Future<Challenge?> fetchChallenge() {
    // TODO: implement fetchChallenge
    throw UnimplementedError();
  }

  @override
  Future<AuthenticatorInfo> getInfo() {
    // TODO: implement getInfo
    throw UnimplementedError();
  }

  @override
  Future<bool> isRegistered() {
    // TODO: implement isRegistered
    throw UnimplementedError();
  }

  @override
  Future<void> remove() {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<void> reply({required Challenge challenge, required bool granted}) {
    // TODO: implement reply
    throw UnimplementedError();
  }

  @override
  Future<void> setup(String aktivationToken) {
    // TODO: implement setup
    throw UnimplementedError();
  }
}
