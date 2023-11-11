import 'dart:convert';
import "package:pointycastle/export.dart";
import 'dart:math';
import "package:asn1lib/asn1lib.dart";
import 'package:flutter/foundation.dart';

import 'challenge_signer_interface.dart';
import '../dtos/asymmetric_key_dto.dart';

class PointycastleSigner implements ChallengeSigner {
  final _helper = RsaKeyHelper();
  AsymmetricKeyPair<PublicKey, PrivateKey>? _keyPair;

  @override
  Future<AsymmetricKeyDto> exportKey() async {
    if (_keyPair == null) {
      throw Exception('no key pair set');
    }
    var dto = AsymmetricKeyDto(
      type: 'rsa',
      publicKey: _helper
          .encodePublicKeyToPemPKCS1(_keyPair!.publicKey as RSAPublicKey),
      privateKey: _helper
          .encodePrivateKeyToPemPKCS1(_keyPair!.privateKey as RSAPrivateKey),
    );
    return dto;
  }

  @override
  Future<void> generateKey() async {
    _keyPair = _generateRSAkeyPair();
    _keyPair = await _helper.computeRSAKeyPair(_helper.getSecureRandom());
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRSAkeyPair({
    int bitLength = 2048,
  }) {
    // Create an RSA key generator and initialize it

    // final keyGen = KeyGenerator('RSA'); // Get using registry
    final keyGen = RSAKeyGenerator();

    var secureRandom = _getSecureRandom();

    keyGen.init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandom,
      ),
    );

    // Use the generator
    final pair = keyGen.generateKeyPair();

    // Cast the generated key pair into the RSA key types
    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  SecureRandom _getSecureRandom() {
    // final secureRandom = SecureRandom('Fortuna')
    //   ..seed(KeyParameter(
    //       Platform.instance.platformEntropySource().getBytes(32)));
    // return secureRandom;

    var secureRandom = FortunaRandom();
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  // _generateECDSAKeyPair() {
  //   final keyParams = ECDomainParameters('secp256k1');
  //   final keyGenerator = ECKeyGenerator()
  //     ..init(ParametersWithRandom(keyParams, Random.secure()));

  //   final secureRandom = SecureRandom('Fortuna')
  //     ..seed(
  //         KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
  //   keyGenerator.init(ParametersWithRandom(
  //       RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
  //       secureRandom));

  //   return keyGenerator.generateKeyPair();
  // }

  @override
  Future<void> importKey(AsymmetricKeyDto keyPair) async {
    var publicKey = _helper.parsePublicKeyFromPem(keyPair.publicKey);
    var privateKey = _helper.parsePrivateKeyFromPem(keyPair.privateKey);
    _keyPair = AsymmetricKeyPair(publicKey, privateKey);
  }

  @override
  Future<String> sign(String value) async {
    var signature = _helper.signSHA256withRSA(
      _helper.createUint8ListFromString(value),
      _keyPair!.privateKey as RSAPrivateKey,
    );
    return base64.encode(signature);
  }

  @override
  Future<String> getPublicKey() async {
    return _helper
        .encodePublicKeyToPemPKCS8_2(_keyPair!.publicKey as RSAPublicKey);
  }
}

// class PointycastleSomething {
//   AsymmetricKeyPair _generateECDSAKeyPair() {
//     final keyParams = ECDomainParameters('secp256k1');
//     final keyGenerator = ECKeyGenerator()
//       ..init(ParametersWithRandom(keyParams, Random.secure()));

//     final secureRandom = SecureRandom('Fortuna')
//       ..seed(
//           KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
//     keyGenerator.init(ParametersWithRandom(
//         RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
//         secureRandom));

//     return keyGenerator.generateKeyPair();
//   }

//   signData() {
//     // Generate the ECDSA key pair
//     final keyPair = _generateECDSAKeyPair();

//     // Convert the string to Uint8List
//     final stringToSign = 'Some string to sign';
//     final stringBytes = utf8.encode(stringToSign) as Uint8List;

//     // Create a suitable random number generator - create it just once and reuse
//     final rand = Random.secure();
//     final fortunaPrng = FortunaRandom()
//       ..seed(KeyParameter(Uint8List.fromList(List<int>.generate(
//         32,
//         (_) => rand.nextInt(256),
//       ))));

//     // Initialize the ECDSA signer using SHA-256
//     final signer = ECDSASigner(SHA256Digest())
//       ..init(
//         true,
//         ParametersWithRandom(
//           PrivateKeyParameter(keyPair.privateKey),
//           fortunaPrng,
//         ),
//       );

//     // Sign the bytes
//     final ecSignature = signer.generateSignature(stringBytes) as ECSignature;

//     // Encode the two signature values in a common format

//     // final seq = ASN1Sequence()
//     //   ..add(ASN1Integer(ecSignature.r))
//     //   ..add(ASN1Integer(ecSignature.s));
//     final encoded = ASN1Sequence(elements: [
//       ASN1Integer(ecSignature.r),
//       ASN1Integer(ecSignature.s),
//     ]).encode();
//     // And finally base 64 encode it
//     final signature = base64UrlEncode(encoded);
//   }
// }

// https://medium.com/flutter-community/asymmetric-key-generation-in-flutter-ad2b912f3309
// https://github.com/Vanethos/flutter_rsa_generator_example
// https://gist.github.com/proteye/982d9991922276ccfb011dfc55443d74

/// Helper class to handle RSA key generation and encoding
class RsaKeyHelper {
  /// Generate a [PublicKey] and [PrivateKey] pair
  ///
  /// Returns a [AsymmetricKeyPair] based on the [RSAKeyGenerator] with custom parameters,
  /// including a [SecureRandom]
  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> computeRSAKeyPair(
      SecureRandom secureRandom) async {
    return await compute(getRsaKeyPair, secureRandom);
  }

  /// Generates a [SecureRandom]
  ///
  /// Returns [FortunaRandom] to be used in the [AsymmetricKeyPair] generation
  SecureRandom getSecureRandom() {
    var secureRandom = FortunaRandom();
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  /// Decode Public key from PEM Format
  ///
  /// Given a base64 encoded PEM [String] with correct headers and footers, return a
  /// [RSAPublicKey]
  ///
  /// *PKCS1*
  /// RSAPublicKey ::= SEQUENCE {
  ///    modulus           INTEGER,  -- n
  ///    publicExponent    INTEGER   -- e
  /// }
  ///
  /// *PKCS8*
  /// PublicKeyInfo ::= SEQUENCE {
  ///   algorithm       AlgorithmIdentifier,
  ///   PublicKey       BIT STRING
  /// }
  ///
  /// AlgorithmIdentifier ::= SEQUENCE {
  ///   algorithm       OBJECT IDENTIFIER,
  ///   parameters      ANY DEFINED BY algorithm OPTIONAL
  /// }
  RSAPublicKey parsePublicKeyFromPem(pemString) {
    List<int> publicKeyDER = decodePEM(pemString);
    var asn1Parser = ASN1Parser(Uint8List.fromList(publicKeyDER));
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    ASN1Integer modulus, exponent;
    // Depending on the first element type, we either have PKCS1 or 2
    if (topLevelSeq.elements[0].runtimeType == ASN1Integer) {
      modulus = topLevelSeq.elements[0] as ASN1Integer;
      exponent = topLevelSeq.elements[1] as ASN1Integer;
    } else {
      var publicKeyBitString = topLevelSeq.elements[1];

      var publicKeyAsn = ASN1Parser(publicKeyBitString.contentBytes());
      var publicKeySeq = publicKeyAsn.nextObject();
      modulus = publicKeySeq.encodedBytes[0] as ASN1Integer;
      exponent = publicKeySeq.encodedBytes[1] as ASN1Integer;
    }

    RSAPublicKey rsaPublicKey =
        RSAPublicKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger);

    return rsaPublicKey;
  }

  /// Sign plain text with Private Key
  ///
  /// Given a plain text [String] and a [RSAPrivateKey], decrypt the text using
  /// a [RSAEngine] cipher
  String sign(String plainText, RSAPrivateKey privateKey) {
    var signer = RSASigner(SHA256Digest(), "0609608648016503040201");
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    return base64Encode(
        signer.generateSignature(createUint8ListFromString(plainText)).bytes);
  }

  Uint8List signSHA256withRSA(Uint8List dataToSign, RSAPrivateKey privateKey) {
    // final signer = Signer('SHA-256/RSA'); // Get using registry
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    // initialize with true, which means sign
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final sig = signer.generateSignature(dataToSign);

    return sig.bytes;
  }

  /// Creates a [Uint8List] from a string to be signed
  Uint8List createUint8ListFromString(String s) {
    var codec = const Utf8Codec(allowMalformed: true);
    return Uint8List.fromList(codec.encode(s));
  }

  /// Decode Private key from PEM Format
  ///
  /// Given a base64 encoded PEM [String] with correct headers and footers, return a
  /// [RSAPrivateKey]
  RSAPrivateKey parsePrivateKeyFromPem(pemString) {
    List<int> privateKeyDER = decodePEM(pemString);
    var asn1Parser = ASN1Parser(Uint8List.fromList(privateKeyDER));
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    ASN1Integer modulus, privateExponent, p, q;
    // Depending on the number of elements, we will either use PKCS1 or PKCS8
    if (topLevelSeq.elements.length == 3) {
      var privateKey = topLevelSeq.elements[2];

      asn1Parser = ASN1Parser(privateKey.contentBytes());
      var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

      modulus = pkSeq.elements[1] as ASN1Integer;
      privateExponent = pkSeq.elements[3] as ASN1Integer;
      p = pkSeq.elements[4] as ASN1Integer;
      q = pkSeq.elements[5] as ASN1Integer;
    } else {
      modulus = topLevelSeq.elements[1] as ASN1Integer;
      privateExponent = topLevelSeq.elements[3] as ASN1Integer;
      p = topLevelSeq.elements[4] as ASN1Integer;
      q = topLevelSeq.elements[5] as ASN1Integer;
    }

    RSAPrivateKey rsaPrivateKey = RSAPrivateKey(
        modulus.valueAsBigInteger,
        privateExponent.valueAsBigInteger,
        p.valueAsBigInteger,
        q.valueAsBigInteger);

    return rsaPrivateKey;
  }

  List<int> decodePEM(String pem) {
    return base64.decode(removePemHeaderAndFooter(pem));
  }

  String removePemHeaderAndFooter(String pem) {
    var startsWith = [
      "-----BEGIN PUBLIC KEY-----",
      "-----BEGIN RSA PRIVATE KEY-----",
      "-----BEGIN RSA PUBLIC KEY-----",
      "-----BEGIN PRIVATE KEY-----",
      "-----BEGIN PGP PUBLIC KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n",
      "-----BEGIN PGP PRIVATE KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n",
    ];
    var endsWith = [
      "-----END PUBLIC KEY-----",
      "-----END PRIVATE KEY-----",
      "-----END RSA PRIVATE KEY-----",
      "-----END RSA PUBLIC KEY-----",
      "-----END PGP PUBLIC KEY BLOCK-----",
      "-----END PGP PRIVATE KEY BLOCK-----",
    ];
    bool isOpenPgp = pem.contains('BEGIN PGP');

    pem = pem.replaceAll(' ', '');
    pem = pem.replaceAll('\n', '');
    pem = pem.replaceAll('\r', '');

    for (var s in startsWith) {
      s = s.replaceAll(' ', '');
      if (pem.startsWith(s)) {
        pem = pem.substring(s.length);
      }
    }

    for (var s in endsWith) {
      s = s.replaceAll(' ', '');
      if (pem.endsWith(s)) {
        pem = pem.substring(0, pem.length - s.length);
      }
    }

    if (isOpenPgp) {
      var index = pem.indexOf('\r\n');
      pem = pem.substring(0, index);
    }

    return pem;
  }

  /// Encode Private key to PEM Format
  ///
  /// Given [RSAPrivateKey] returns a base64 encoded [String]
  String encodePrivateKeyToPemPKCS1(RSAPrivateKey privateKey) {
    var topLevel = ASN1Sequence();

    topLevel.add(ASN1Integer(BigInt.from(0)));
    topLevel.add(ASN1Integer(privateKey.n!));
    topLevel.add(ASN1Integer(privateKey.exponent!));
    topLevel.add(ASN1Integer(privateKey.privateExponent!));
    topLevel.add(ASN1Integer(privateKey.p!));
    topLevel.add(ASN1Integer(privateKey.q!));
    var dP = privateKey.privateExponent! % (privateKey.p! - BigInt.from(1));
    topLevel.add(ASN1Integer(dP));
    var dQ = privateKey.privateExponent! % (privateKey.q! - BigInt.from(1));
    topLevel.add(ASN1Integer(dQ));
    var iQ = privateKey.q!.modInverse(privateKey.p!);
    topLevel.add(ASN1Integer(iQ));

    return base64.encode(topLevel.encodedBytes);
  }

  /// Encode Public key to PEM Format
  ///
  /// Given [RSAPublicKey] returns a base64 encoded [String]
  String encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
    var topLevel = ASN1Sequence();

    topLevel.add(ASN1Integer(publicKey.modulus!));
    topLevel.add(ASN1Integer(publicKey.exponent!));

    return base64.encode(topLevel.encodedBytes);
  }

  String encodePublicKeyToPemPKCS8_2(RSAPublicKey publicKey) {
    ASN1ObjectIdentifier.registerFrequentNames();
    var algorithmSeq = ASN1Sequence();
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(ASN1ObjectIdentifier.fromName('rsaEncryption'));
    algorithmSeq.add(paramsAsn1Obj);

    var publicKeySeq = ASN1Sequence();
    publicKeySeq.add(ASN1Integer(publicKey.modulus!));
    publicKeySeq.add(ASN1Integer(publicKey.exponent!));
    var publicKeySeqBitString =
        ASN1BitString(Uint8List.fromList(publicKeySeq.encodedBytes));

    var topLevelSeq = ASN1Sequence();
    topLevelSeq.add(algorithmSeq);
    topLevelSeq.add(publicKeySeqBitString);
    return base64.encode(topLevelSeq.encodedBytes);
  }

  String encodePublicKeyToPemPKCS8(RSAPublicKey publicKey) {
    // Encode the public key in PKCS#8 format
    final publicKeyASN1 = ASN1Sequence();
    publicKeyASN1.add(ASN1Integer(publicKey.modulus!));
    publicKeyASN1.add(ASN1Integer(publicKey.exponent!));

    final publicKeyInfo = ASN1Sequence();
    ASN1ObjectIdentifier.registerFrequentNames();
    publicKeyInfo.add(ASN1ObjectIdentifier.fromName('rsaEncryption'));
    publicKeyInfo.add(ASN1Null());
    publicKeyInfo.add(publicKeyASN1);

    final publicKeyBytes = publicKeyInfo.encodedBytes;
    return base64Encode(publicKeyBytes);
  }
}

/// Generate a [PublicKey] and [PrivateKey] pair
///
/// Returns a [AsymmetricKeyPair] based on the [RSAKeyGenerator] with custom parameters,
/// including a [SecureRandom]
AsymmetricKeyPair<PublicKey, PrivateKey> getRsaKeyPair(
    SecureRandom secureRandom) {
  var rsapars = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 5);
  var params = ParametersWithRandom(rsapars, secureRandom);
  var keyGenerator = RSAKeyGenerator();
  keyGenerator.init(params);
  return keyGenerator.generateKeyPair();
}
