import 'package:dio/dio.dart';

import 'enums/enums.dart';
import 'dtos/challenge.dart';

class KeycloakAuthenticatorClient {
  final String baseUrl;
  final String realm;
  late Dio _dio;

  KeycloakAuthenticatorClient({
    required this.baseUrl,
    required this.realm,
  }) {
    _dio = Dio(BaseOptions(baseUrl: '$baseUrl/realms/$realm'));
    _dio.interceptors.add(LogInterceptor(responseBody: true, error: true));
  }

  Future<String> buildSignatureHeader(
    String keyId,
    Map<String, String> keyValues,
    Future<String> Function(String) signFn,
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
    print('payload: $payload');
    // var signature = base64.encode(utf8.encode(await signFn(payload)));
    var signature = await signFn(payload);
    // buffer.writeAll([',', 'keyId', ':', keyId]);
    // buffer.writeAll([',', 'signature', ':', signature]);
    return 'keyId:$keyId,$payload,signature:$signature';
    // return buffer.toString();
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
    required Future<String> Function(String) signFn,
  }) async {
    // var signatureHeader = await buildSignatureHeader(
    //   deviceId,
    //   {
    //     'created': DateTime.now().millisecondsSinceEpoch.toString(),
    //   },
    //   signFn,
    // );
    // print(signatureHeader);
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
    print(queryParameters);
    // print(queryParameters);
    try {
      var res = await _dio.get(
        '/login-actions/action-token',
        queryParameters: queryParameters,
        // options: Options(
        //   headers: {
        //     'signature': signatureHeader,
        //   },
        // ),
      );
      print(res.statusCode);
      print(res.data);
    } on DioException catch (err) {
      print('request failed');
      print(err.requestOptions.baseUrl);
      rethrow;
      // log(err.response?.data ?? 'no data');
    }
  }

  Future<List<Challenge>> getChallenges(
    String deviceId,
    Future<String> Function(String) signFn,
  ) async {
    var signatureHeader = await buildSignatureHeader(
      deviceId,
      {
        'created': DateTime.now().millisecondsSinceEpoch.toString(),
        // 'request-target': 'get_/realms/$realm/challenge-resource/$deviceId',
      },
      signFn,
    );
    print(signatureHeader);
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
    required Future<String> Function(String) signFn,
  }) async {
    var signatureHeader = await buildSignatureHeader(
      deviceId,
      {
        // 'created': DateTime.now().millisecondsSinceEpoch.toString(),
        'created': timestamp.toString(),
        'secret': value,
        'granted': granted ? 'true' : 'false',
      },
      signFn,
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
