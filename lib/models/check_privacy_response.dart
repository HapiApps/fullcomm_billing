class LoginResponse {
  final String status;
  final String message;
  final String authId;
  final String cosId;
  final String role;
  final String username;
  final String storeType;
  final String companyName;
  final bool showPrivacyPopup;

  LoginResponse({
    required this.status,
    this.message = '',
    this.authId = '',
    this.cosId = '',
    this.role = '',
    this.username = '',
    this.storeType = '',
    this.companyName = '',
    this.showPrivacyPopup = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      authId: json['auth_id']?.toString() ?? '',
      cosId: json['cos_id']?.toString() ?? '',
      role: json['role'] ?? '',
      username: json['username'] ?? '',
      storeType: json['store_type'] ?? '',
      companyName: json['company_name'] ?? '',
      showPrivacyPopup: json['show_privacy_popup'] == true ||
          json['show_privacy_popup'] == 1 ||
          json['show_privacy_popup'] == '1',
    );
  }
}
