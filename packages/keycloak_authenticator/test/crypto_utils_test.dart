import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:keycloak_authenticator/src/utils/crypto_utils.dart';
import 'package:pointycastle/export.dart';

void main() {
  test('RSA keypair can be generated', () {
    var keyPair = CryptoUtils.generateRsaKeyPair(bitLength: 1024);
    expect(keyPair.publicKey.exponent?.isValidInt, true);
    expect(keyPair.publicKey.modulus?.bitLength, 1024);
    expect(keyPair.privateKey.p, isNotNull);
    expect(keyPair.privateKey.q, isNotNull);
    expect(keyPair.privateKey.exponent, isNotNull);
    expect(keyPair.privateKey.modulus, isNotNull);
  });

  test('RSA keypair can be generated async', () async {
    var keyPair = await CryptoUtils.generateRsaKeyPairAsync(bitLength: 2048);
    expect(keyPair.publicKey, isNotNull);
    expect(keyPair.publicKey.modulus?.bitLength, 2048);
    expect(keyPair.privateKey, isNotNull);
  });

  test('can sign with RSA', () async {
    var privateKey = RSAPrivateKey(
      BigInt.parse(
        '81b04edc5f624440df320bc28318e2d110413bee9c72e61b9add43378fb147dcde70ff57f28dc7d9e3ce36ee8ad5dbf01046608cc6e03557e8102e5947779f671993e5d4c1e4b6ddc4d920a3f8f66c19daf51c652292c701fd4d4cde07e8be6d0967a2b9f6f94fa47f687f4ed41ca9b868cbda63abf272109cd57f7cc91f5d27403577a0a468948460afbf6dfda77ce794cf2ef22632063c3cfc2d434f2b2983b683d105ad5f64a2691c5dd00c16ca3ab8d8b7787b4f5a5b50dc4cb7f01355e2cb0bcea92185fef59659a04e94ec1a6755688113878a7db5c1a554140110181eae5e5ef53aa62d712b29a9bb3424e86452170d63e13dcd71db9655bc36781425',
        radix: 16,
      ),
      BigInt.parse(
        '5720171abd89cac8ba2968f5181593eb57bc3b8325df9aef58aee50562a77adbcb24a6a672f1051e4088bd26ac66d8070328049d0ece7987c1037ddfc4bf7c7b4b17ad03adeef55b2f6f9f1a099ba32c0b8937b649efc97a70ad89c27015d0387865035163b641e7052132c5c6822b1314743f174ee0e5f87b24832d560098175d33a3294fd985426f58c2335b2120a733da9ec91846767105a652bb3a89f0c99586ba45c09fc9a3718a0189bd10b599107f61837862efadbec9f26473bf95189ab2aae12153864ef64a31d08f74b3045013ab7aa9ad14e9fb6f367ec7a73d162a12a09a694e02531a41c9195518ce5d28187ee998f847b194ac0a8b1922fe81',
        radix: 16,
      ),
      BigInt.parse(
        'c1185131d1b2d08e24612e2a98e8fbcc6e5ae8c1c0ed7541b91fe74c05da9183268a5ed256c6b91b0c35c89d06ce24e28c0498cb2bd1c761021da3c3bb8caaf1abfa1bf8c05ed6ae5cb2251d0da81269f0f9f25ecc7956422e5fd3a2a1dd63473c3599e47825926e7eefeb4b09e6b5af096b8ddddcbff86116f7ef630f971429',
        radix: 16,
      ),
      BigInt.parse(
        'abf00d079c334240ae408ea26aed8e6e514ed63a1f733aabe126dbf877146205f7d1b904a48c489e055975860356d1568ee1a4edad6a50f1cdd9e35d27df9fd8c581d0b75519fed765ca81ce5370943aaea5e400a34c843b97678a44f5c21654a5f336e82fd5df088dbab088f7ec731911bf9353bc0e30bcc81322c9fa59df9d',
        radix: 16,
      ),
    );
    var signature = CryptoUtils.rsaSign(
      privateKey,
      Uint8List.fromList('value'.codeUnits),
      algorithmName: 'SHA-256/RSA',
    );
    expect(
      base64Encode(signature),
      'L6YaTswLPNkq/FeBf3maGrbRMSUParKcDLEYDYWwj0g9EnmNZ6+jkaNFc/Cqzi7+F12SBNeThYsj+CaYOMzKS/enXV5rbHAHTvgNcVCrSzSSlnWY4WVFJRGd8fgMSE2+Qy79kfLKCMoxjg5G+IM9JFRa8IjhT8kqGmpf/gsaWJbJXyaWOh6CmLXa0rRpyNXfXIBAi02sFU/DvSD1GqY3Y6p02zfJRp5kAo68xSIJZT3eXhH97c/LOwx7FFVeMjdiXHconeKU64OcRlmaPm7PJyMczKKLYlMsBsZjS7EjoSuYUG4CrCmd6xEFwKSiqF+AzCBGspD7wEV0oSMSa+t+FQ==',
    );
  });

  test('can verify rsa signature', () async {
    var publicKey = RSAPublicKey(
      BigInt.parse(
        '81b04edc5f624440df320bc28318e2d110413bee9c72e61b9add43378fb147dcde70ff57f28dc7d9e3ce36ee8ad5dbf01046608cc6e03557e8102e5947779f671993e5d4c1e4b6ddc4d920a3f8f66c19daf51c652292c701fd4d4cde07e8be6d0967a2b9f6f94fa47f687f4ed41ca9b868cbda63abf272109cd57f7cc91f5d27403577a0a468948460afbf6dfda77ce794cf2ef22632063c3cfc2d434f2b2983b683d105ad5f64a2691c5dd00c16ca3ab8d8b7787b4f5a5b50dc4cb7f01355e2cb0bcea92185fef59659a04e94ec1a6755688113878a7db5c1a554140110181eae5e5ef53aa62d712b29a9bb3424e86452170d63e13dcd71db9655bc36781425',
        radix: 16,
      ),
      BigInt.from(0x10001),
    );
    var signature =
        'L6YaTswLPNkq/FeBf3maGrbRMSUParKcDLEYDYWwj0g9EnmNZ6+jkaNFc/Cqzi7+F12SBNeThYsj+CaYOMzKS/enXV5rbHAHTvgNcVCrSzSSlnWY4WVFJRGd8fgMSE2+Qy79kfLKCMoxjg5G+IM9JFRa8IjhT8kqGmpf/gsaWJbJXyaWOh6CmLXa0rRpyNXfXIBAi02sFU/DvSD1GqY3Y6p02zfJRp5kAo68xSIJZT3eXhH97c/LOwx7FFVeMjdiXHconeKU64OcRlmaPm7PJyMczKKLYlMsBsZjS7EjoSuYUG4CrCmd6xEFwKSiqF+AzCBGspD7wEV0oSMSa+t+FQ==';

    var valid = CryptoUtils.rsaVerify(
      publicKey,
      Uint8List.fromList('value'.codeUnits),
      base64Decode(signature),
      algorithm: 'SHA-256/RSA',
    );
    expect(
      valid,
      true,
    );
  });

  test('RSA public key can be encoded to PKCS#8', () {
    var publicKey = RSAPublicKey(
      BigInt.parse(
        '00acc80f4eaa1052bc777df9601a51cffd97056075dcdcd1de10caac6f42409f01232bb541259e0f31d4d499dbc4ee9d180f75f6514f9e8a437fe8b146ac9174c274f59ab835ad0b9b59f0628d7ef99b40a5884c4e90650397dde54cac28ec703367e5fe37db2d4a1f57cb79bd7c45a11f7f90be0f8569a03ae162a105547c4663cd9ce3cc227bd7df1431b8fbb14d3d03118df7e0089405a87be3ca4dbb1f37c9e27cb84a348e2670a3125518b8b8473ddc7d20934070c9fc130e8fc337e6d9287da0b8a2877f9bb00f3367aefd86c0bf24fbf0f8b00fcb36838667f6692afde5fe2ee32685908eb59597d595e3dc68000cfa220f34908288e6725869de96a5f3',
        radix: 16,
      ),
      BigInt.from(0x10001),
    );

    var encoded = CryptoUtils.encodeRsaPublicKeyToPkcs8(publicKey);
    expect(
      base64Encode(encoded),
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArMgPTqoQUrx3fflgGlHP/ZcFYHXc3NHeEMqsb0JAnwEjK7VBJZ4PMdTUmdvE7p0YD3X2UU+eikN/6LFGrJF0wnT1mrg1rQubWfBijX75m0CliExOkGUDl93lTKwo7HAzZ+X+N9stSh9Xy3m9fEWhH3+Qvg+FaaA64WKhBVR8RmPNnOPMInvX3xQxuPuxTT0DEY334AiUBah748pNux83yeJ8uEo0jiZwoxJVGLi4Rz3cfSCTQHDJ/BMOj8M35tkofaC4ood/m7APM2eu/YbAvyT78PiwD8s2g4Zn9mkq/eX+LuMmhZCOtZWX1ZXj3GgADPoiDzSQgojmclhp3pal8wIDAQAB',
    );
  });

  test('RSA private key can be encoded to PKCS#8', () {
    var privateKey = RSAPrivateKey(
      BigInt.parse(
        '81b04edc5f624440df320bc28318e2d110413bee9c72e61b9add43378fb147dcde70ff57f28dc7d9e3ce36ee8ad5dbf01046608cc6e03557e8102e5947779f671993e5d4c1e4b6ddc4d920a3f8f66c19daf51c652292c701fd4d4cde07e8be6d0967a2b9f6f94fa47f687f4ed41ca9b868cbda63abf272109cd57f7cc91f5d27403577a0a468948460afbf6dfda77ce794cf2ef22632063c3cfc2d434f2b2983b683d105ad5f64a2691c5dd00c16ca3ab8d8b7787b4f5a5b50dc4cb7f01355e2cb0bcea92185fef59659a04e94ec1a6755688113878a7db5c1a554140110181eae5e5ef53aa62d712b29a9bb3424e86452170d63e13dcd71db9655bc36781425',
        radix: 16,
      ),
      BigInt.parse(
        '5720171abd89cac8ba2968f5181593eb57bc3b8325df9aef58aee50562a77adbcb24a6a672f1051e4088bd26ac66d8070328049d0ece7987c1037ddfc4bf7c7b4b17ad03adeef55b2f6f9f1a099ba32c0b8937b649efc97a70ad89c27015d0387865035163b641e7052132c5c6822b1314743f174ee0e5f87b24832d560098175d33a3294fd985426f58c2335b2120a733da9ec91846767105a652bb3a89f0c99586ba45c09fc9a3718a0189bd10b599107f61837862efadbec9f26473bf95189ab2aae12153864ef64a31d08f74b3045013ab7aa9ad14e9fb6f367ec7a73d162a12a09a694e02531a41c9195518ce5d28187ee998f847b194ac0a8b1922fe81',
        radix: 16,
      ),
      BigInt.parse(
        'c1185131d1b2d08e24612e2a98e8fbcc6e5ae8c1c0ed7541b91fe74c05da9183268a5ed256c6b91b0c35c89d06ce24e28c0498cb2bd1c761021da3c3bb8caaf1abfa1bf8c05ed6ae5cb2251d0da81269f0f9f25ecc7956422e5fd3a2a1dd63473c3599e47825926e7eefeb4b09e6b5af096b8ddddcbff86116f7ef630f971429',
        radix: 16,
      ),
      BigInt.parse(
        'abf00d079c334240ae408ea26aed8e6e514ed63a1f733aabe126dbf877146205f7d1b904a48c489e055975860356d1568ee1a4edad6a50f1cdd9e35d27df9fd8c581d0b75519fed765ca81ce5370943aaea5e400a34c843b97678a44f5c21654a5f336e82fd5df088dbab088f7ec731911bf9353bc0e30bcc81322c9fa59df9d',
        radix: 16,
      ),
    );

    var encoded = CryptoUtils.encodeRsaPrivateKeyToPkcs8(privateKey);

    expect(
      base64Encode(encoded),
      'MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCBsE7cX2JEQN8yC8KDGOLREEE77pxy5hua3UM3j7FH3N5w/1fyjcfZ48427orV2/AQRmCMxuA1V+gQLllHd59nGZPl1MHktt3E2SCj+PZsGdr1HGUikscB/U1M3gfovm0JZ6K59vlPpH9of07UHKm4aMvaY6vychCc1X98yR9dJ0A1d6CkaJSEYK+/bf2nfOeUzy7yJjIGPDz8LUNPKymDtoPRBa1fZKJpHF3QDBbKOrjYt3h7T1pbUNxMt/ATVeLLC86pIYX+9ZZZoE6U7BpnVWiBE4eKfbXBpVQUARAYHq5eXvU6pi1xKympuzQk6GRSFw1j4T3NcduWVbw2eBQlAgMBAAECggEAVyAXGr2Jysi6KWj1GBWT61e8O4Ml35rvWK7lBWKnetvLJKamcvEFHkCIvSasZtgHAygEnQ7OeYfBA33fxL98e0sXrQOt7vVbL2+fGgmboywLiTe2Se/JenCticJwFdA4eGUDUWO2QecFITLFxoIrExR0PxdO4OX4eySDLVYAmBddM6MpT9mFQm9YwjNbISCnM9qeyRhGdnEFplK7OonwyZWGukXAn8mjcYoBib0QtZkQf2GDeGLvrb7J8mRzv5UYmrKq4SFThk72SjHQj3SzBFATq3qprRTp+282fsenPRYqEqCaaU4CUxpByRlVGM5dKBh+6Zj4R7GUrAqLGSL+gQKBgQDBGFEx0bLQjiRhLiqY6PvMblrowcDtdUG5H+dMBdqRgyaKXtJWxrkbDDXInQbOJOKMBJjLK9HHYQIdo8O7jKrxq/ob+MBe1q5csiUdDagSafD58l7MeVZCLl/ToqHdY0c8NZnkeCWSbn7v60sJ5rWvCWuN3dy/+GEW9+9jD5cUKQKBgQCr8A0HnDNCQK5AjqJq7Y5uUU7WOh9zOqvhJtv4dxRiBffRuQSkjEieBVl1hgNW0VaO4aTtrWpQ8c3Z410n35/YxYHQt1UZ/tdlyoHOU3CUOq6l5ACjTIQ7l2eKRPXCFlSl8zboL9XfCI26sIj37HMZEb+TU7wOMLzIEyLJ+lnfnQKBgAG2+5GbsSDVAlGynUI6X3ITUM9cWSBCuFCyjdVJAAXmykLUUL3giehJlXiwnEzcWv6vU8QKIZTJscEdoTFbMHFw+4mgDeVJtsav9lBpvKJdOnydwGXEdhWkX8l7WkCjDxDj0PgMcRj5zjrHNiViXR6u0LuzyrARvpr7nK6ehtLxAoGAQWLR4bICQFDOs5hKpfVfdA6Rt6B082I9mSso/i1y3/A7FVOSM21x9D4+jhX/0RVdIIspKIYJZ2z9hr4TYCWH6Wz6+D+wKmmiyoAfqzJKHuTOJCI4J+Hia7MhWhDtkPjjChUbLWN7pwzesT+PZxFRmBgKzeFLI+5e7ItycHM3mHUCgYAMOrVlqZvyWP2B3X7zDpr3YZbz+Cc7CijAqWfv7I4AGL+602qABc2ZCJ4x+rblfddQ4LzVojSbJfWIY09Emc8ZiWJUJf7aZNkHImj7DosRL19qnjXdXH1hSTOf7db23hkXyVzLYivglHQPtmwUvzFdSyNmXG9cN+EebYaHyX8w0Q==',
    );
  });
  test('RSA private key can be decoded from PKCS#8', () {
    var encoded =
        'MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCBsE7cX2JEQN8yC8KDGOLREEE77pxy5hua3UM3j7FH3N5w/1fyjcfZ48427orV2/AQRmCMxuA1V+gQLllHd59nGZPl1MHktt3E2SCj+PZsGdr1HGUikscB/U1M3gfovm0JZ6K59vlPpH9of07UHKm4aMvaY6vychCc1X98yR9dJ0A1d6CkaJSEYK+/bf2nfOeUzy7yJjIGPDz8LUNPKymDtoPRBa1fZKJpHF3QDBbKOrjYt3h7T1pbUNxMt/ATVeLLC86pIYX+9ZZZoE6U7BpnVWiBE4eKfbXBpVQUARAYHq5eXvU6pi1xKympuzQk6GRSFw1j4T3NcduWVbw2eBQlAgMBAAECggEAVyAXGr2Jysi6KWj1GBWT61e8O4Ml35rvWK7lBWKnetvLJKamcvEFHkCIvSasZtgHAygEnQ7OeYfBA33fxL98e0sXrQOt7vVbL2+fGgmboywLiTe2Se/JenCticJwFdA4eGUDUWO2QecFITLFxoIrExR0PxdO4OX4eySDLVYAmBddM6MpT9mFQm9YwjNbISCnM9qeyRhGdnEFplK7OonwyZWGukXAn8mjcYoBib0QtZkQf2GDeGLvrb7J8mRzv5UYmrKq4SFThk72SjHQj3SzBFATq3qprRTp+282fsenPRYqEqCaaU4CUxpByRlVGM5dKBh+6Zj4R7GUrAqLGSL+gQKBgQDBGFEx0bLQjiRhLiqY6PvMblrowcDtdUG5H+dMBdqRgyaKXtJWxrkbDDXInQbOJOKMBJjLK9HHYQIdo8O7jKrxq/ob+MBe1q5csiUdDagSafD58l7MeVZCLl/ToqHdY0c8NZnkeCWSbn7v60sJ5rWvCWuN3dy/+GEW9+9jD5cUKQKBgQCr8A0HnDNCQK5AjqJq7Y5uUU7WOh9zOqvhJtv4dxRiBffRuQSkjEieBVl1hgNW0VaO4aTtrWpQ8c3Z410n35/YxYHQt1UZ/tdlyoHOU3CUOq6l5ACjTIQ7l2eKRPXCFlSl8zboL9XfCI26sIj37HMZEb+TU7wOMLzIEyLJ+lnfnQKBgAG2+5GbsSDVAlGynUI6X3ITUM9cWSBCuFCyjdVJAAXmykLUUL3giehJlXiwnEzcWv6vU8QKIZTJscEdoTFbMHFw+4mgDeVJtsav9lBpvKJdOnydwGXEdhWkX8l7WkCjDxDj0PgMcRj5zjrHNiViXR6u0LuzyrARvpr7nK6ehtLxAoGAQWLR4bICQFDOs5hKpfVfdA6Rt6B082I9mSso/i1y3/A7FVOSM21x9D4+jhX/0RVdIIspKIYJZ2z9hr4TYCWH6Wz6+D+wKmmiyoAfqzJKHuTOJCI4J+Hia7MhWhDtkPjjChUbLWN7pwzesT+PZxFRmBgKzeFLI+5e7ItycHM3mHUCgYAMOrVlqZvyWP2B3X7zDpr3YZbz+Cc7CijAqWfv7I4AGL+602qABc2ZCJ4x+rblfddQ4LzVojSbJfWIY09Emc8ZiWJUJf7aZNkHImj7DosRL19qnjXdXH1hSTOf7db23hkXyVzLYivglHQPtmwUvzFdSyNmXG9cN+EebYaHyX8w0Q==';

    var privateKey =
        CryptoUtils.decodeRsaPrivateKeyFromPkcs8(base64Decode(encoded));
    expect(
      privateKey.modulus,
      BigInt.parse(
        '81b04edc5f624440df320bc28318e2d110413bee9c72e61b9add43378fb147dcde70ff57f28dc7d9e3ce36ee8ad5dbf01046608cc6e03557e8102e5947779f671993e5d4c1e4b6ddc4d920a3f8f66c19daf51c652292c701fd4d4cde07e8be6d0967a2b9f6f94fa47f687f4ed41ca9b868cbda63abf272109cd57f7cc91f5d27403577a0a468948460afbf6dfda77ce794cf2ef22632063c3cfc2d434f2b2983b683d105ad5f64a2691c5dd00c16ca3ab8d8b7787b4f5a5b50dc4cb7f01355e2cb0bcea92185fef59659a04e94ec1a6755688113878a7db5c1a554140110181eae5e5ef53aa62d712b29a9bb3424e86452170d63e13dcd71db9655bc36781425',
        radix: 16,
      ),
    );
    expect(
      privateKey.exponent,
      BigInt.parse(
        '5720171abd89cac8ba2968f5181593eb57bc3b8325df9aef58aee50562a77adbcb24a6a672f1051e4088bd26ac66d8070328049d0ece7987c1037ddfc4bf7c7b4b17ad03adeef55b2f6f9f1a099ba32c0b8937b649efc97a70ad89c27015d0387865035163b641e7052132c5c6822b1314743f174ee0e5f87b24832d560098175d33a3294fd985426f58c2335b2120a733da9ec91846767105a652bb3a89f0c99586ba45c09fc9a3718a0189bd10b599107f61837862efadbec9f26473bf95189ab2aae12153864ef64a31d08f74b3045013ab7aa9ad14e9fb6f367ec7a73d162a12a09a694e02531a41c9195518ce5d28187ee998f847b194ac0a8b1922fe81',
        radix: 16,
      ),
    );
    expect(
      privateKey.p,
      BigInt.parse(
        'c1185131d1b2d08e24612e2a98e8fbcc6e5ae8c1c0ed7541b91fe74c05da9183268a5ed256c6b91b0c35c89d06ce24e28c0498cb2bd1c761021da3c3bb8caaf1abfa1bf8c05ed6ae5cb2251d0da81269f0f9f25ecc7956422e5fd3a2a1dd63473c3599e47825926e7eefeb4b09e6b5af096b8ddddcbff86116f7ef630f971429',
        radix: 16,
      ),
    );
    expect(
      privateKey.q,
      BigInt.parse(
        'abf00d079c334240ae408ea26aed8e6e514ed63a1f733aabe126dbf877146205f7d1b904a48c489e055975860356d1568ee1a4edad6a50f1cdd9e35d27df9fd8c581d0b75519fed765ca81ce5370943aaea5e400a34c843b97678a44f5c21654a5f336e82fd5df088dbab088f7ec731911bf9353bc0e30bcc81322c9fa59df9d',
        radix: 16,
      ),
    );
    expect(
      privateKey.publicExponent,
      BigInt.from(0x10001),
    );
  });

  test('EC key can be generated', () {
    var keyPair = CryptoUtils.generateEcKeyPair();
    expect(keyPair.publicKey.Q, isNotNull);
    expect(keyPair.privateKey.d, isNotNull);
  });

  test('EC key can be generated async', () async {
    var keyPair = await CryptoUtils.generateEcKeyPairAsync();
    expect(keyPair.publicKey.Q, isNotNull);
    expect(keyPair.privateKey.d, isNotNull);
  });

  test('can sign with EC', () {
    var privateKey = ECPrivateKey(
      BigInt.parse(
        '27ec05f125bac34b1c9e4afe2dc8b454506f8689c3f6547737be7a01036bb24e',
        radix: 16,
      ),
      ECDomainParameters('prime256v1'),
    );

    var signature = CryptoUtils.ecSign(
      privateKey,
      Uint8List.fromList('value'.codeUnits),
    );

    expect(
      signature,
      isNotEmpty,
    );
  });

  test('EC private key can be encoded to PKCS#8', () {
    var privateKey = ECPrivateKey(
      BigInt.parse(
        '27ec05f125bac34b1c9e4afe2dc8b454506f8689c3f6547737be7a01036bb24e',
        radix: 16,
      ),
      ECDomainParameters('prime256v1'),
    );

    var encoded = CryptoUtils.encodeEcPrivateKeyToPkcs8(privateKey);
    expect(
      base64Encode(encoded),
      'MHcCAQEEICfsBfElusNLHJ5K/i3ItFRQb4aJw/ZUdze+egEDa7JOoAoGCCqGSM49AwEHoUQDQgAEjI8qbJl+d+4IytlrBt+J2oHo4IC4VR2kFLImpcJPusfk1Ucs/HBqeNYSr8sAP51LBuEQFa3Saj22KtyUZlharA==',
    );
  });

  test('EC private key can be decoded from PKCS#8', () {
    var decoded =
        'MHcCAQEEICfsBfElusNLHJ5K/i3ItFRQb4aJw/ZUdze+egEDa7JOoAoGCCqGSM49AwEHoUQDQgAEjI8qbJl+d+4IytlrBt+J2oHo4IC4VR2kFLImpcJPusfk1Ucs/HBqeNYSr8sAP51LBuEQFa3Saj22KtyUZlharA==';
    var privateKey =
        CryptoUtils.decodeEcPrivateKey(base64Decode(decoded), pkcs8: true);
    expect(
      privateKey.d,
      BigInt.parse(
        '27ec05f125bac34b1c9e4afe2dc8b454506f8689c3f6547737be7a01036bb24e',
        radix: 16,
      ),
    );
  });

  test('EC public key can be encoded to PKCS#8', () {
    var publicKey = CryptoUtils.ecPublicKey(
      '048c8f2a6c997e77ee08cad96b06df89da81e8e080b8551da414b226a5c24fbac7e4d5472cfc706a78d612afcb003f9d4b06e11015add26a3db62adc9466585aac',
      'prime256v1',
    );

    var encoded = CryptoUtils.encodeEcPublicKeyToPkcs8(publicKey);
    expect(
      base64Encode(encoded),
      'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEjI8qbJl+d+4IytlrBt+J2oHo4IC4VR2kFLImpcJPusfk1Ucs/HBqeNYSr8sAP51LBuEQFa3Saj22KtyUZlharA==',
    );
  });
}
