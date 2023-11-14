import 'package:dio/dio.dart';

import 'types.dart';
import 'enums/enums.dart';
import 'dtos/challenge.dart';

class KeycloakClient {
  final String baseUrl;
  final String realm;
  late Dio _dio;

  KeycloakClient({
    required this.baseUrl,
    required this.realm,
  }) {
    _dio = Dio(BaseOptions(baseUrl: '$baseUrl/realms/$realm'));
    _dio.interceptors.add(LogInterceptor(responseBody: true, error: true));
  }

  Future<String> buildSignatureHeader(
    String keyId,
    Map<String, String> keyValues,
    SignFn sign,
  ) async {
    var buffer = StringBuffer();
    var first = true;
    keyValues.forEach((key, value) {
      if (!first) {
        buffer.write(',');
      }
      buffer.writeAll([key, ':', value]);
      first = false;
    });
    var payload = buffer.toString();
    var signature = await sign(payload);
    return 'keyId:$keyId,$payload,signature:$signature';
  }

  Future<void> register({
    required String clientId,
    required String tabId,
    required String deviceId,
    required DeviceOs deviceOs,
    String? devicePushId,
    required String oneTimeJwt,
    required String publicKey,
    required KeyAlgorithm keyAlgorithm,
    required SignatureAlgorithm signatureAlgorithm,
    required SignFn sign,
  }) async {
    var queryParameters = {
      'client_id': clientId,
      'tab_id': tabId,
      'device_id': deviceId,
      'device_os': deviceOs.name.toString(),
      'device_push_id': devicePushId,
      'key_algorithm': keyAlgorithm.name.toString(),
      'signature_algorithm': signatureAlgorithm.name.toString(),
      'public_key': publicKey,
      'key': oneTimeJwt,
    };
    try {
      await _dio.get(
        '/login-actions/action-token',
        queryParameters: queryParameters,
      );
    } on DioException catch (err) {
      rethrow;
    }
  }

  Future<List<Challenge>> getChallenges(
    String deviceId,
    SignFn sign,
  ) async {
    var signatureHeader = await buildSignatureHeader(
      deviceId,
      {
        'created': DateTime.now().millisecondsSinceEpoch.toString(),
        // 'request-target': 'get_/realms/$realm/challenge-resource/$deviceId',
      },
      sign,
    );
    try {
      var res = await _dio.get(
        '/challenges',
        queryParameters: {
          'device_id': deviceId,
        },
        options: Options(
          headers: {
            'signature': signatureHeader,
          },
        ),
      );
      return [Challenge.fromJson(res.data)];
    } on DioException catch (err) {
      if (err.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  completeChallenge({
    required String deviceId,
    required String clientId,
    required String tabId,
    required String oneTimeJwt,
    required String value,
    required bool granted,
    required int timestamp,
    required SignFn sign,
  }) async {
    var signatureHeader = await buildSignatureHeader(
      deviceId,
      {
        // 'created': DateTime.now().millisecondsSinceEpoch.toString(),
        'created': timestamp.toString(),
        'secret': value,
        'granted': granted ? 'true' : 'false',
      },
      sign,
    );
    var res = await _dio.get(
      '/login-actions/action-token',
      queryParameters: {
        'client_id': clientId,
        'tab_id': tabId,
        'key': oneTimeJwt,
        'granted': granted,
      },
      options: Options(
        headers: {
          'signature': signatureHeader,
        },
      ),
    );
  }
}
