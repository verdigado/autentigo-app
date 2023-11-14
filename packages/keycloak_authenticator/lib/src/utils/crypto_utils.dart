import 'package:pointycastle/export.dart';
import "package:pointycastle/pointycastle.dart";
import 'dart:math';
import 'package:flutter/foundation.dart';

class CryptoUtils {
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRsaKeyPair({
    int bitLength = 2048,
  }) {
    var keyGenerator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(
            BigInt.from(65537),
            bitLength,
            64,
          ),
          _getSecureRandom(),
        ),
      );

    var keyPair = keyGenerator.generateKeyPair();
    // Cast the keyPair key pair into the RSA key types
    final myPublic = keyPair.publicKey as RSAPublicKey;
    final myPrivate = keyPair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
      generateRsaKeyPairAsync({
    int bitLength = 2048,
  }) {
    return compute((_) => generateRsaKeyPair(bitLength: bitLength), null);
  }

  ///
  /// Signing the given [data] with the given [privateKey].
  ///
  /// The default [algorithm] used is **SHA-256/RSA**. All supported algorihms are :
  ///
  /// * MD2/RSA
  /// * MD4/RSA
  /// * MD5/RSA
  /// * RIPEMD-128/RSA
  /// * RIPEMD-160/RSA
  /// * RIPEMD-256/RSA
  /// * SHA-1/RSA
  /// * SHA-224/RSA
  /// * SHA-256/RSA
  /// * SHA-384/RSA
  /// * SHA-512/RSA
  ///
  static Uint8List rsaSign(
    RSAPrivateKey privateKey,
    Uint8List data, {
    String algorithmName = 'SHA-256/RSA',
  }) {
    var signer = Signer(algorithmName) as RSASigner;

    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    var signature = signer.generateSignature(data);

    return signature.bytes;
  }

  ///
  /// Verifying the given [signedData] with the given [publicKey] and the given [signature].
  /// Will return **true** if the given [signature] matches the [signedData].
  ///
  /// The default [algorithm] used is **SHA-256/RSA**. All supported algorihms are :
  ///
  /// * MD2/RSA
  /// * MD4/RSA
  /// * MD5/RSA
  /// * RIPEMD-128/RSA
  /// * RIPEMD-160/RSA
  /// * RIPEMD-256/RSA
  /// * SHA-1/RSA
  /// * SHA-224/RSA
  /// * SHA-256/RSA
  /// * SHA-384/RSA
  /// * SHA-512/RSA
  ///
  static bool rsaVerify(
    RSAPublicKey publicKey,
    Uint8List signedData,
    Uint8List signature, {
    String algorithm = 'SHA-256/RSA',
  }) {
    final sig = RSASignature(signature);

    final verifier = Signer(algorithm);

    verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

    try {
      return verifier.verifySignature(signedData, sig);
    } on ArgumentError {
      return false;
    }
  }

  static SecureRandom _getSecureRandom() {
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255 + 1));
    }

    return FortunaRandom()..seed(KeyParameter(Uint8List.fromList(seeds)));
  }

  static Uint8List encodeRsaPublicKeyToPkcs8(RSAPublicKey publicKey) {
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    var algorithmSeq = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromName('rsaEncryption'))
      ..add(paramsAsn1Obj);

    var publicKeySeq = ASN1Sequence()
      ..add(ASN1Integer(publicKey.modulus))
      ..add(ASN1Integer(publicKey.exponent));
    var publicKeySeqBitString =
        ASN1BitString(stringValues: Uint8List.fromList(publicKeySeq.encode()));

    var topLevelSeq = ASN1Sequence()
      ..add(algorithmSeq)
      ..add(publicKeySeqBitString);
    return topLevelSeq.encode();
  }

  static Uint8List encodeRsaPrivateKeyToPkcs8(RSAPrivateKey privateKey) {
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    var algorithmSeq = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromName('rsaEncryption'))
      ..add(paramsAsn1Obj);

    var dP = privateKey.privateExponent! % (privateKey.p! - BigInt.one);
    var exp1 = ASN1Integer(dP);
    var dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.one);
    var exp2 = ASN1Integer(dQ);
    var iQ = privateKey.q!.modInverse(privateKey.p!);
    var co = ASN1Integer(iQ);
    var version = ASN1Integer(BigInt.zero);
    var privateKeySeq = ASN1Sequence()
      ..add(version)
      ..add(ASN1Integer(privateKey.n))
      ..add(ASN1Integer(privateKey.publicExponent))
      ..add(ASN1Integer(privateKey.privateExponent))
      ..add(ASN1Integer(privateKey.p))
      ..add(ASN1Integer(privateKey.q))
      ..add(exp1)
      ..add(exp2)
      ..add(co);

    var publicKeySeqOctetString =
        ASN1OctetString(octets: Uint8List.fromList(privateKeySeq.encode()));

    var topLevelSeq = ASN1Sequence()
      ..add(version)
      ..add(algorithmSeq)
      ..add(publicKeySeqOctetString);

    return topLevelSeq.encode();
  }

  static RSAPrivateKey decodeRsaPrivateKeyFromPkcs8(Uint8List bytes) {
    var asn1Parser = ASN1Parser(bytes);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    //ASN1Object version = topLevelSeq.elements[0];
    //ASN1Object algorithm = topLevelSeq.elements[1];
    var privateKey = topLevelSeq.elements![2];

    asn1Parser = ASN1Parser(privateKey.valueBytes);
    var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

    var modulus = pkSeq.elements![1] as ASN1Integer;
    //ASN1Integer publicExponent = pkSeq.elements[2] as ASN1Integer;
    var privateExponent = pkSeq.elements![3] as ASN1Integer;
    var p = pkSeq.elements![4] as ASN1Integer;
    var q = pkSeq.elements![5] as ASN1Integer;
    //ASN1Integer exp1 = pkSeq.elements[6] as ASN1Integer;
    //ASN1Integer exp2 = pkSeq.elements[7] as ASN1Integer;
    //ASN1Integer co = pkSeq.elements[8] as ASN1Integer;

    var rsaPrivateKey = RSAPrivateKey(
      modulus.integer!,
      privateExponent.integer!,
      p.integer,
      q.integer,
    );

    return rsaPrivateKey;
  }
}
