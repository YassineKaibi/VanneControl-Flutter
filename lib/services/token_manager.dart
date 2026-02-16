import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

/// TokenManager - Secure JWT token management.
/// Matches TokenManager.kt from the Android project.
/// Uses flutter_secure_storage (Android KeyStore / iOS Keychain).
class TokenManager {
  static TokenManager? _instance;

  final FlutterSecureStorage _storage;

  TokenManager._()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  static TokenManager getInstance() {
    _instance ??= TokenManager._();
    return _instance!;
  }

  /// Save the JWT token
  Future<void> saveToken(String token) async {
    await _storage.write(key: Constants.prefsAuthToken, value: token);
  }

  /// Retrieve the JWT token
  Future<String?> getToken() async {
    return _storage.read(key: Constants.prefsAuthToken);
  }

  /// Save user info (userId and email)
  Future<void> saveUserInfo(String userId, String email) async {
    await _storage.write(key: Constants.prefsUserId, value: userId);
    await _storage.write(key: Constants.prefsUserEmail, value: email);
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    return _storage.read(key: Constants.prefsUserId);
  }

  /// Retrieve user email
  Future<String?> getUserEmail() async {
    return _storage.read(key: Constants.prefsUserEmail);
  }

  /// Check if user is logged in (has a token)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Clear all auth data (logout)
  Future<void> clearAuth() async {
    await _storage.delete(key: Constants.prefsAuthToken);
    await _storage.delete(key: Constants.prefsUserId);
    await _storage.delete(key: Constants.prefsUserEmail);
  }

  /// Logout - alias for clearAuth
  Future<void> logout() async {
    await clearAuth();
  }

  /// Get the full Authorization header value with Bearer prefix
  Future<String?> getAuthorizationHeader() async {
    final token = await getToken();
    if (token != null) {
      return '${Constants.bearerPrefix}$token';
    }
    return null;
  }
}
