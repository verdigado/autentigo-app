import '../dtos/asymmetric_key_dto.dart';

abstract class ChallengeSigner {
  Future<void> generateKey();
  Future<AsymmetricKeyDto> exportKey();
  Future<void> importKey(AsymmetricKeyDto keyPair);
  Future<String> getPublicKey();
  Future<String> sign(String value);
}
