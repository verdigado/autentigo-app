class AuthenticatorEntry {
  final String id;

  AuthenticatorEntry({required this.id});

  factory AuthenticatorEntry.fromJson(Map<String, dynamic> json) {
    return AuthenticatorEntry(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
