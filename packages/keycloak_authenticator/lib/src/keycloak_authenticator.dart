import 'dart:convert';

import 'package:keycloak_authenticator/src/authenticator.dart';
import 'package:keycloak_authenticator/src/keycloak_client.dart';
import 'package:keycloak_authenticator/src/dtos/challenge.dart';
import 'package:keycloak_authenticator/src/enums/enums.dart';
import 'package:keycloak_authenticator/src/utils/crypto_utils.dart';
import 'package:pointycastle/export.dart';

class KeycloakAuthenticator implements Authenticator {
  final _Data _data;
  final String _deviceId;
  final KeycloakClient _client;

  KeycloakAuthenticator._({
    required _Data data,
    required KeycloakClient client,
    required String deviceId,
  })  : _data = data,
        _deviceId = deviceId,
        _client = client;

  factory KeycloakAuthenticator.fromParams({
    required String id,
    required String deviceId,
    required String baseUrl,
    required String realm,
    required SignatureAlgorithm signatureAlgorithm,
    required KeyAlgorithm keyAlgorithm,
    required PrivateKey privateKey,
  }) {
    return KeycloakAuthenticator._(
      data: _Data(
        id: id,
        baseUrl: baseUrl,
        realm: realm,
        registeredAt: DateTime.now(),
        signatureAlgorithm: signatureAlgorithm,
        keyAlgorithm: keyAlgorithm,
        privateKey: privateKey,
      ),
      deviceId: deviceId,
      client: KeycloakClient(
        baseUrl: baseUrl,
        privateKey: privateKey,
        signatureAlgorithm: signatureAlgorithm,
        keyAlgorithm: keyAlgorithm,
      ),
    );
  }

  factory KeycloakAuthenticator.fromJson(Map<String, dynamic> json,
      {required String deviceId}) {
    var data = _Data.fromJson(json);
    return KeycloakAuthenticator._(
      data: data,
      deviceId: deviceId,
      client: KeycloakClient(
        baseUrl: data.baseUrl,
        privateKey: data.privateKey,
        signatureAlgorithm: data.signatureAlgorithm,
        keyAlgorithm: data.keyAlgorithm,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return _data.toJson();
  }

  @override
  Future<Challenge?> fetchChallenge() async {
    var challanges = await _client.getChallenges(_deviceId);
    return challanges.firstOrNull;
  }

  @override
  Future<void> reply({
    required Challenge challenge,
    required bool granted,
  }) async {
    final uri = Uri.parse(challenge.targetUrl);

    await _client.completeChallenge(
      deviceId: _deviceId,
      clientId: uri.queryParameters['client_id']!,
      tabId: uri.queryParameters['tab_id']!,
      key: uri.queryParameters['key']!,
      value: challenge.secret,
      granted: granted,
      timestamp: challenge.updatedTimestamp,
    );
  }

  @override
  String getId() {
    return _data.id;
  }
}

class _Data {
  final String id;
  final String baseUrl;
  final String realm;
  final SignatureAlgorithm signatureAlgorithm;
  final KeyAlgorithm keyAlgorithm;
  final PrivateKey privateKey;
  final DateTime registeredAt;

  _Data({
    required this.id,
    required this.baseUrl,
    required this.realm,
    required this.signatureAlgorithm,
    required this.keyAlgorithm,
    required this.privateKey,
    required this.registeredAt,
  });

  static PrivateKey _decodePrivateKey(
    KeyAlgorithm keyAlgorithm,
    String encodedKey,
  ) {
    switch (keyAlgorithm) {
      case KeyAlgorithm.RSA:
        return CryptoUtils.decodeRsaPrivateKeyFromPkcs8(
            base64Decode(encodedKey));
      case KeyAlgorithm.ECDSA:
        throw Exception('Unsupported KeyAlgorithm');
    }
  }

  static String _encodePrivateKey(
    KeyAlgorithm keyAlgorithm,
    PrivateKey privateKey,
  ) {
    switch (keyAlgorithm) {
      case KeyAlgorithm.RSA:
        return base64Encode(CryptoUtils.encodeRsaPrivateKeyToPkcs8(
            privateKey as RSAPrivateKey));
      case KeyAlgorithm.ECDSA:
        throw Exception('Unsupported Key Algorithm');
    }
  }

  factory _Data.fromJson(Map<String, dynamic> json) {
    var keyAlgorithm = KeyAlgorithm.values.byName(json['keyAlgorithm']);
    return _Data(
      id: json['id'],
      baseUrl: json['baseUrl'],
      realm: json['realm'],
      signatureAlgorithm:
          SignatureAlgorithm.values.byName(json['signatureAlgorithm']),
      keyAlgorithm: keyAlgorithm,
      privateKey: _decodePrivateKey(keyAlgorithm, json['privateKey']),
      registeredAt: DateTime.fromMillisecondsSinceEpoch(
        json['registeredAt'],
        isUtc: true,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseUrl': baseUrl,
      'realm': realm,
      'signatureAlgorithm': signatureAlgorithm.name,
      'keyAlgorithm': keyAlgorithm.name,
      'privateKey': _encodePrivateKey(keyAlgorithm, privateKey),
      'registeredAt': registeredAt.millisecondsSinceEpoch,
    };
  }
}
