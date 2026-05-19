import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_client.dart';
import '../services/token_manager.dart';
import '../services/network_result.dart';
import '../models/api_requests.dart';
import '../models/api_responses.dart';

const _profileStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

/// AuthState - Combines login and register state into one provider.
/// Replaces LoginViewModel + RegisterViewModel from the Android project.

// --- Login ---

final loginStateProvider =
    StateNotifierProvider<LoginNotifier, NetworkResult<AuthResponse>>(
  (ref) => LoginNotifier(),
);

final emailErrorProvider = StateProvider<String?>((ref) => null);
final passwordErrorProvider = StateProvider<String?>((ref) => null);

class LoginNotifier extends StateNotifier<NetworkResult<AuthResponse>> {
  LoginNotifier() : super(const Idle());

  final _apiClient = ApiClient.getInstance();
  final _tokenManager = TokenManager.getInstance();

  Future<void> login(String email, String password) async {
    state = const Loading();

    final result = await _apiClient.safeApiCall(
      () => _apiClient.dio.post(
        'auth/login',
        data: LoginRequest(email: email, password: password).toJson(),
      ),
      (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );

    // On success, save token and user info (matches AuthRepository.kt)
    if (result is Success<AuthResponse>) {
      final token = result.data.token;
      if (token != null) await _tokenManager.saveToken(token);
      await _tokenManager.saveUserInfo(result.data.userId, email);
    }

    state = result;
  }

  void resetState() {
    state = const Idle();
  }
}

// --- Register ---

final registerStateProvider =
    StateNotifierProvider<RegisterNotifier, NetworkResult<AuthResponse>>(
  (ref) => RegisterNotifier(),
);

final firstNameErrorProvider = StateProvider<String?>((ref) => null);
final lastNameErrorProvider = StateProvider<String?>((ref) => null);
final regEmailErrorProvider = StateProvider<String?>((ref) => null);
final phoneErrorProvider = StateProvider<String?>((ref) => null);
final regPasswordErrorProvider = StateProvider<String?>((ref) => null);
final confirmPasswordErrorProvider = StateProvider<String?>((ref) => null);

class RegisterNotifier extends StateNotifier<NetworkResult<AuthResponse>> {
  RegisterNotifier() : super(const Idle());

  final _apiClient = ApiClient.getInstance();
  final _tokenManager = TokenManager.getInstance();

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    state = const Loading();

    final result = await _apiClient.safeApiCall(
      () => _apiClient.dio.post(
        'auth/register',
        data: RegisterRequest(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
        ).toJson(),
      ),
      (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );

    // On success, save token, user info and profile data
    if (result is Success<AuthResponse>) {
      final token = result.data.token;
      if (token != null) await _tokenManager.saveToken(token);
      await _tokenManager.saveUserInfo(result.data.userId, email);
      await Future.wait([
        _profileStorage.write(key: 'profile_firstName', value: firstName),
        _profileStorage.write(key: 'profile_lastName', value: lastName),
        _profileStorage.write(key: 'profile_phone', value: phoneNumber),
      ]);
    }

    state = result;
  }

  void resetState() {
    state = const Idle();
  }
}

// --- Logout ---

Future<void> logout() async {
  await TokenManager.getInstance().logout();
  ApiClient.reset();
}

// --- Validation helpers (match Kotlin ViewModel validation) ---

final _emailPattern = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

/// Validate login fields. Returns true if valid.
bool validateLogin({
  required String email,
  required String password,
  required StateController<String?> emailError,
  required StateController<String?> passwordError,
  required String errorEmailRequired,
  required String errorEmailInvalid,
  required String errorPasswordRequired,
  required String errorPasswordTooShort,
}) {
  var valid = true;

  // Email validation
  if (email.isEmpty) {
    emailError.state = errorEmailRequired;
    valid = false;
  } else if (!_emailPattern.hasMatch(email)) {
    emailError.state = errorEmailInvalid;
    valid = false;
  } else {
    emailError.state = null;
  }

  // Password validation
  if (password.isEmpty) {
    passwordError.state = errorPasswordRequired;
    valid = false;
  } else if (password.length < 8) {
    passwordError.state = errorPasswordTooShort;
    valid = false;
  } else {
    passwordError.state = null;
  }

  return valid;
}

/// Validate register fields. Returns true if valid.
bool validateRegister({
  required String firstName,
  required String lastName,
  required String email,
  required String phone,
  required String password,
  required String confirmPassword,
  required StateController<String?> firstNameError,
  required StateController<String?> lastNameError,
  required StateController<String?> emailError,
  required StateController<String?> phoneError,
  required StateController<String?> passwordError,
  required StateController<String?> confirmPasswordError,
  required String errorFirstNameRequired,
  required String errorFirstNameTooShort,
  required String errorLastNameRequired,
  required String errorLastNameTooShort,
  required String errorEmailRequired,
  required String errorEmailInvalid,
  required String errorPhoneRequired,
  required String errorPhoneInvalid,
  required String errorPasswordRequired,
  required String errorPasswordTooShort,
  required String errorConfirmPasswordRequired,
  required String errorPasswordsNotMatch,
}) {
  var valid = true;

  // First name
  if (firstName.isEmpty) {
    firstNameError.state = errorFirstNameRequired;
    valid = false;
  } else if (firstName.length < 2) {
    firstNameError.state = errorFirstNameTooShort;
    valid = false;
  } else {
    firstNameError.state = null;
  }

  // Last name
  if (lastName.isEmpty) {
    lastNameError.state = errorLastNameRequired;
    valid = false;
  } else if (lastName.length < 2) {
    lastNameError.state = errorLastNameTooShort;
    valid = false;
  } else {
    lastNameError.state = null;
  }

  // Email
  if (email.isEmpty) {
    emailError.state = errorEmailRequired;
    valid = false;
  } else if (!_emailPattern.hasMatch(email)) {
    emailError.state = errorEmailInvalid;
    valid = false;
  } else {
    emailError.state = null;
  }

  // Phone
  if (phone.isEmpty) {
    phoneError.state = errorPhoneRequired;
    valid = false;
  } else if (phone.replaceAll(RegExp(r'\D'), '').length < 8) {
    phoneError.state = errorPhoneInvalid;
    valid = false;
  } else {
    phoneError.state = null;
  }

  // Password
  if (password.isEmpty) {
    passwordError.state = errorPasswordRequired;
    valid = false;
  } else if (password.length < 6) {
    passwordError.state = errorPasswordTooShort;
    valid = false;
  } else {
    passwordError.state = null;
  }

  // Confirm password
  if (confirmPassword.isEmpty) {
    confirmPasswordError.state = errorConfirmPasswordRequired;
    valid = false;
  } else if (confirmPassword != password) {
    confirmPasswordError.state = errorPasswordsNotMatch;
    valid = false;
  } else {
    confirmPasswordError.state = null;
  }

  return valid;
}
