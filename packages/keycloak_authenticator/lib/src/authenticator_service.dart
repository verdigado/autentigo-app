import 'dart:convert';

import 'package:keycloak_authenticator/src/authenticator.dart';
import 'package:keycloak_authenticator/src/dtos/activation_token_dto.dart';
import 'package:keycloak_authenticator/src/enums/enums.dart';
import 'package:keycloak_authenticator/src/keycloak_authenticator.dart';
import 'package:keycloak_authenticator/src/keycloak_client.dart';
import 'package:keycloak_authenticator/src/storage/storage.dart';
import 'package:keycloak_authenticator/src/utils/crypto_utils.dart';
import 'package:keycloak_authenticator/src/utils/device_utils.dart';

class AuthenticatorService {
  final Storage _storage;

  AuthenticatorService({required Storage storage}) : _storage = storage;

  Future<Authenticator> create(
    String aktivationTokenUrl, {
    SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.SHA256withRSA,
  }) async {
    var token = ActivationTokenDto.fromUrl(aktivationTokenUrl);

    var keyAlgorithm = KeyAlgorithm.RSA;
    var keyPair = await CryptoUtils.generateRsaKeyPairAsync(bitLength: 4096);
    var encodedPublicKey =
        base64Encode(CryptoUtils.encodeRsaPublicKeyToPkcs8(keyPair.publicKey));

    var deviceId = DeviceUtils.getDeviceId();
    var devicePushId = DeviceUtils.getDevicePushId();
    DeviceOs deviceOs = DeviceOs.android;

    var client = KeycloakClient(
      baseUrl: token.baseUrl,
      signatureAlgorithm: signatureAlgorithm,
      keyAlgorithm: keyAlgorithm,
      privateKey: keyPair.privateKey,
    );

    await client.register(
      clientId: token.clientId,
      tabId: token.tabId,
      deviceId: deviceId,
      deviceOs: deviceOs,
      key: token.key,
      publicKey: encodedPublicKey,
      keyAlgorithm: keyAlgorithm,
      signatureAlgorithm: signatureAlgorithm,
      devicePushId: devicePushId,
    );
    var authenticatorId = 'authenticator_id';
    var authenticator = KeycloakAuthenticator.fromParams(
      id: authenticatorId,
      baseUrl: token.baseUrl,
      realm: token.realm,
      signatureAlgorithm: signatureAlgorithm,
      keyAlgorithm: keyAlgorithm,
      privateKey: keyPair.privateKey,
    );

    await _storage.write(
        key: _getAuthenticatorStorageKey(authenticatorId),
        value: jsonEncode(authenticator.toJson()));

    return authenticator;
  }

  Future<Authenticator?> get(String authenticatorId) async {
    var serialized =
        await _storage.read(key: _getAuthenticatorStorageKey(authenticatorId));
    if (serialized == null) {
      return null;
    }
    return KeycloakAuthenticator.fromJson(jsonDecode(serialized));
  }

  Future<List<AuthenicatorEntry>> getList() async {
    return [AuthenicatorEntry(id: 'authenticator_id')];
  }

  Future<void> delete(Authenticator authenticator) async {
    _storage.delete(key: authenticator.getId());
    throw UnimplementedError();
  }

  _getAuthenticatorStorageKey(String authenticatorId) {
    return 'auth:$authenticatorId';
  }
}

class AuthenicatorEntry {
  final String id;

  AuthenicatorEntry({required this.id});
}
