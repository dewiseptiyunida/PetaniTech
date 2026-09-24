class AuthModel {
  final int expires;
  final String refreshToken;
  final String accessToken;

  AuthModel({
    required this.expires,
    required this.refreshToken,
    required this.accessToken,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      expires: json['expires'],
      refreshToken: json['refresh_token'],
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expires': expires,
      'refresh_token': refreshToken,
      'access_token': accessToken,
    };
  }
}
