import 'dart:convert';

import 'package:keycloak_authenticator/src/authenticator.dart';
import 'package:keycloak_authenticator/src/dtos/activation_token_dto.dart';
import 'package:keycloak_authenticator/src/dtos/authenticator_entry.dart';
import 'package:keycloak_authenticator/src/enums/enums.dart';
import 'package:keycloak_authenticator/src/keycloak_authenticator.dart';
import 'package:keycloak_authenticator/src/keycloak_client.dart';
import 'package:keycloak_authenticator/src/storage/storage.dart';
import 'package:keycloak_authenticator/src/utils/crypto_utils.dart';
import 'package:keycloak_authenticator/src/utils/device_utils.dart';
import 'package:pointycastle/export.dart';

class AuthenticatorService {
  final Storage _storage;

  AuthenticatorService({required Storage storage}) : _storage = storage;

  Future<Authenticator> create(
    String aktivationTokenUrl, {
    SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.SHA512withRSA,
  }) async {
    var token = ActivationTokenDto.fromUrl(aktivationTokenUrl);

    // TODO: check if combination of keycloak instance an realm is already registered

    var keyAlgorithm =
        _getKeyAlgorithmForSignatureAlgorithm(signatureAlgorithm);

    AsymmetricKeyPair keyPair;
    String encodedPublicKey;
    switch (keyAlgorithm) {
      case KeyAlgorithm.RSA:
        keyPair = await CryptoUtils.generateRsaKeyPairAsync(bitLength: 4096);
        encodedPublicKey = base64Encode(CryptoUtils.encodeRsaPublicKeyToPkcs8(
            keyPair.publicKey as RSAPublicKey));
        break;
      case KeyAlgorithm.ECDSA:
        throw Exception('ECDSA not supported');
    }

    var deviceId = await DeviceUtils.getDeviceId();
    var devicePushId = DeviceUtils.getDevicePushId();
    DeviceOs deviceOs = DeviceUtils.getDeviceOs();

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
    var authenticatorId = CryptoUtils.generateId();
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

    await _addToList(authenticator);

    return authenticator;
  }

  Future<Authenticator?> getById(String authenticatorId) async {
    var serialized =
        await _storage.read(key: _getAuthenticatorStorageKey(authenticatorId));
    if (serialized == null) {
      return null;
    }
    return KeycloakAuthenticator.fromJson(jsonDecode(serialized));
  }

  Future<Authenticator?> getFirst() async {
    var list = await getList();
    var firstEntry = list.firstOrNull;
    return firstEntry != null ? await getById(firstEntry.id) : null;
  }

  Future<List<AuthenticatorEntry>> getList() async {
    List<AuthenticatorEntry> list = [];
    var serialized = await _storage.read(key: 'entries');
    if (serialized != null) {
      List<dynamic> jsonList = jsonDecode(serialized);
      list = jsonList.map((json) => AuthenticatorEntry.fromJson(json)).toList();
    }
    return list;
  }

  Future<void> _saveList(List<AuthenticatorEntry> list) async {
    await _storage.write(
        key: 'entries',
        value: jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<List<AuthenticatorEntry>> _addToList(
      Authenticator authenticator) async {
    var list = await getList();
    list.add(AuthenticatorEntry(id: authenticator.getId()));
    await _saveList(list);
    return list;
  }

  Future<List<AuthenticatorEntry>> _deleteFromList(
      Authenticator authenticator) async {
    var list = await getList();
    list.removeWhere((element) => element.id == authenticator.getId());
    await _saveList(list);
    return list;
  }

  Future<void> delete(Authenticator authenticator) async {
    // TODO: implement authenticator delete on keycloak side

    _storage.delete(key: _getAuthenticatorStorageKey(authenticator.getId()));

    await _deleteFromList(authenticator);
  }

  _getAuthenticatorStorageKey(String authenticatorId) {
    return 'auth:$authenticatorId';
  }

  KeyAlgorithm _getKeyAlgorithmForSignatureAlgorithm(
      SignatureAlgorithm signatureAlgorithm) {
    switch (signatureAlgorithm) {
      case SignatureAlgorithm.SHA256withRSA:
      case SignatureAlgorithm.SHA512withRSA:
        return KeyAlgorithm.RSA;
      case SignatureAlgorithm.SHA512withECDSA:
        return KeyAlgorithm.ECDSA;
    }
  }
}
