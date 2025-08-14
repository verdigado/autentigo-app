enum Environment { production, staging, development }

class AppConfig {
  Environment environment;
  String keycloakBaseUrl;
  String keycloakRealm;

  AppConfig({required this.environment, required this.keycloakBaseUrl, required this.keycloakRealm});
}
