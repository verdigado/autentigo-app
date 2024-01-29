import 'package:flutter/material.dart';
import 'package:kc_auth_app/app/app.dart';
import 'package:kc_auth_app/app/config/config.dart';
import 'package:kc_auth_app/features/authenticator/domain/authenticator_factory.dart';
import 'package:keycloak_authenticator/api.dart';
import 'package:get_it/get_it.dart';

void main() {
  var appConfig = AppConfig(
    environment: Environment.development,
    keycloakBaseUrl: 'http://192.168.2.196:8080',
    keycloakRealm: 'dev',
  );
  GetIt.I.registerSingleton<AppConfig>(appConfig);

  GetIt.I.registerFactory<AuthenticatorService>(AuthenticatorFactory.create);

  runApp(MyApp());
}
