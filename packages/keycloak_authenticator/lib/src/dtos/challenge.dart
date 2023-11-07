class Challenge {
  // User who is requesting authentication
  final String userName;
  // User frist name
  final String userFirstName;
  // User last name
  final String userLastName;
  // URL containing JWT to send challenge to
  final String targetUrl;
  // random string to be signed
  final String secret;
  // Unix timestamp in milliseconds the user requested authentication (login)
  final int updatedTimestamp;
  // IP address of the requesting device
  final String ipAddress;
  // The requesting device, e.g. iPhone
  final String device;
  // Browser of the requesting device
  final String browser;
  // OS of the requesting device
  final String os;
  // OS version of the requesting device
  final String osVersion;

  Challenge({
    required this.userName,
    required this.userFirstName,
    required this.userLastName,
    required this.targetUrl,
    required this.secret,
    required this.updatedTimestamp,
    required this.ipAddress,
    required this.device,
    required this.browser,
    required this.os,
    required this.osVersion,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      userName: json['userName'],
      userFirstName: json['userFirstName'],
      userLastName: json['userLastName'],
      targetUrl: json['targetUrl'],
      secret: json['secret'],
      updatedTimestamp: json['updatedTimestamp'],
      ipAddress: json['ipAddress'],
      device: json['device'],
      browser: json['browser'],
      os: json['os'],
      osVersion: json['osVersion'],
    );
  }
}
