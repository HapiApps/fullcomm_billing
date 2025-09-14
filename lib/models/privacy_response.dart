class UserResponse {
  final String responseCode;
  final UserLogin userLogin;

  UserResponse({required this.responseCode, required this.userLogin});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      responseCode: json['responseCode'],
      userLogin: UserLogin.fromJson(json['userLogin']),
    );
  }
}

class UserLogin {
  final String id;
  final String name;
  final bool privacyAccepted;

  UserLogin({
    required this.id,
    required this.name,
    required this.privacyAccepted,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      id: json['id'],
      name: json['name'],
      privacyAccepted: json['privacyAccepted'] ?? false,
    );
  }
}
