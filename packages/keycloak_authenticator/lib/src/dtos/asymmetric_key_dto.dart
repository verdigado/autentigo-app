class AsymmetricKeyDto {
  final String type;
  final String publicKey;
  final String privateKey;

  AsymmetricKeyDto({
    required this.type,
    required this.publicKey,
    required this.privateKey,
  });

  factory AsymmetricKeyDto.fromJson(Map<String, dynamic> json) {
    return AsymmetricKeyDto(
      type: json['type'],
      publicKey: json['publicKey'],
      privateKey: json['privateKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }
}
