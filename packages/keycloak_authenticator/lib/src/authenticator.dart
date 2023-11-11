import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:keycloak_authenticator/src/authenticator_interface.dart';
import 'package:keycloak_authenticator/src/challenge_signer/challenge_signer_interface.dart';
import 'package:keycloak_authenticator/src/challenge_signer/pointy_castle_signer.dart';
import 'package:keycloak_authenticator/src/client.dart';
import 'package:keycloak_authenticator/src/dtos/asymmetric_key_dto.dart';
import 'package:keycloak_authenticator/src/dtos/challenge.dart';
import 'package:keycloak_authenticator/src/enums/enums.dart';

class KeycloakAuthenticator implements AuthenticatorInterface {
  static const keyKeyPair = 'authenticator_key_pair';

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  final KeycloakAuthenticatorClient _client;

  final ChallengeSigner _signer = PointycastleSigner();

  KeycloakAuthenticator({
    required KeycloakAuthenticatorClient client,
  }) : _client = client;

  _saveKeyPair(AsymmetricKeyDto keyPair) async {
    var serialized = json.encode(keyPair.toJson());
    await _secureStorage.write(
      key: keyKeyPair,
      value: serialized,
    );
  }

  Future<AsymmetricKeyDto?> _getKeyPair() async {
    var encodedKeyPair = await _secureStorage.read(key: keyKeyPair);
    if (encodedKeyPair == null) {
      return null;
    }
    return AsymmetricKeyDto.fromJson(json.decode(encodedKeyPair));
  }

  Future<bool> _hasKeyPair() async {
    var keyPair = await _getKeyPair();
    return keyPair != null;
  }

  Future<void> _deleteKeyPair() {
    return _secureStorage.delete(key: keyKeyPair);
  }

  // String _removePemHeader(String key) {
  //   List<int> keyData =
  //       PemCodec(PemLabel.publicKey).decode(key.replaceAll(r'RSA ', ''));
  //   return base64Encode(keyData);
  //   // return base64Url.encode(keyData);
  // }

  @override
  Future<void> register(String activationToken) async {
    // check if already registed
    if (await _hasKeyPair()) {
      throw Exception('key already exists');
    }

    // generate key pair
    await _signer.generateKey();
    var keyPair = await _signer.exportKey();

    // save key pair
    await _saveKeyPair(keyPair);

    // var publicKey = _removePemHeader(keyPair.publicKey);
    var publicKey = await _signer.getPublicKey();

    // send request
    final uri = Uri.parse(activationToken);
    await _client.register(
      clientId: uri.queryParameters['client_id']!,
      tabId: uri.queryParameters['tab_id']!,
      oneTimeJwt: uri.queryParameters['key']!,
      deviceId: _getDeviceId(),
      deviceOs: DeviceOs.android,
      keyAlgorithm: KeyAlgorithm.RSA,
      signatureAlgorithm: SignatureAlgorithm.SHA256withRSA,
      publicKey: publicKey,
      signFn: (String p0) => _signer.sign(p0),
    );
  }

  @override
  Future<void> unregister() {
    return _deleteKeyPair();
  }

  String _getDeviceId() {
    // return PlatformDeviceId.getDeviceId;
    return 'device_id';
  }

  @override
  Future<Challenge> fetchChallenge() async {
    var keyPair = await _getKeyPair();
    if (keyPair == null) {
      throw Exception('No key pair');
    }
    await _signer.importKey(keyPair);
    var deviceId = _getDeviceId();
    var challanges =
        await _client.getChallenges(deviceId, (String p0) => _signer.sign(p0));
    return challanges[0];
  }

  @override
  confirm(Challenge challenge) async {
    return _sendResponse(challenge, true);
  }

  @override
  deny(Challenge challenge) async {
    return _sendResponse(challenge, false);
  }

  _sendResponse(Challenge challenge, bool granted) async {
    var keyPair = await _getKeyPair();
    if (keyPair == null) {
      throw Exception('No key pair');
    }
    await _signer.importKey(keyPair);

    final uri = Uri.parse(challenge.targetUrl);

    await _client.completeChallenge(
      deviceId: _getDeviceId(),
      clientId: uri.queryParameters['client_id']!,
      tabId: uri.queryParameters['tab_id']!,
      oneTimeJwt: uri.queryParameters['key']!,
      value: challenge.secret,
      granted: granted,
      timestamp: challenge.updatedTimestamp,
      signFn: (String p0) => _signer.sign(p0),
    );
  }

  @override
  Future<bool> isRegistered() {
    return _hasKeyPair();
  }
}
