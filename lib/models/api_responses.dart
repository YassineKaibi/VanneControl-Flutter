/// API response models - Matches ApiResponses.kt from the Android project.

class AuthResponse {
  final String token;
  final String userId;

  const AuthResponse({required this.token, required this.userId});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      userId: json['userId'] as String,
    );
  }
}

class ErrorResponse {
  final String? error;
  final String? message;

  const ErrorResponse({this.error, this.message});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}
