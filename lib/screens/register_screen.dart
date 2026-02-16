import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/network_result.dart';
import '../models/api_responses.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    final l10n = AppLocalizations.of(context)!;

    final valid = validateRegister(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      firstNameError: ref.read(firstNameErrorProvider.notifier),
      lastNameError: ref.read(lastNameErrorProvider.notifier),
      emailError: ref.read(regEmailErrorProvider.notifier),
      phoneError: ref.read(phoneErrorProvider.notifier),
      passwordError: ref.read(regPasswordErrorProvider.notifier),
      confirmPasswordError: ref.read(confirmPasswordErrorProvider.notifier),
      errorFirstNameRequired: l10n.errorFirstNameRequired,
      errorFirstNameTooShort: l10n.errorFirstNameTooShort,
      errorLastNameRequired: l10n.errorLastNameRequired,
      errorLastNameTooShort: l10n.errorLastNameTooShort,
      errorEmailRequired: l10n.errorEmailRequired,
      errorEmailInvalid: l10n.errorEmailInvalid,
      errorPhoneRequired: l10n.errorPhoneRequired,
      errorPhoneInvalid: l10n.errorPhoneInvalid,
      errorPasswordRequired: l10n.errorPasswordRequired,
      errorPasswordTooShort: l10n.errorPasswordTooShort,
      errorConfirmPasswordRequired: l10n.errorConfirmPasswordRequired,
      errorPasswordsNotMatch: l10n.errorPasswordsNotMatch,
    );

    if (valid) {
      ref.read(registerStateProvider.notifier).register(
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
            _emailController.text.trim(),
            _phoneController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final registerState = ref.watch(registerStateProvider);
    final isLoading = registerState is Loading<AuthResponse>;

    // Field errors
    final firstNameError = ref.watch(firstNameErrorProvider);
    final lastNameError = ref.watch(lastNameErrorProvider);
    final emailError = ref.watch(regEmailErrorProvider);
    final phoneError = ref.watch(phoneErrorProvider);
    final passwordError = ref.watch(regPasswordErrorProvider);
    final confirmPasswordError = ref.watch(confirmPasswordErrorProvider);

    // Listen for register result
    ref.listen<NetworkResult<AuthResponse>>(registerStateProvider,
        (prev, next) {
      next.when(
        idle: () {},
        loading: () {},
        success: (data) {
          // Toast + navigate to dashboard with clear stack
          // (matches RegisterActivity.kt FLAG_NEW_TASK | FLAG_CLEAR_TASK)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.registrationSuccess)),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        },
        error: (message, code) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const SizedBox(height: 60),
                  Text(
                    l10n.registerTitle,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),

                  // First name
                  _buildField(
                    controller: _firstNameController,
                    hint: l10n.firstNameHint,
                    error: firstNameError,
                    topMargin: 48,
                    enabled: !isLoading,
                  ),

                  // Last name
                  _buildField(
                    controller: _lastNameController,
                    hint: l10n.lastNameHint,
                    error: lastNameError,
                    enabled: !isLoading,
                  ),

                  // Email
                  _buildField(
                    controller: _emailController,
                    hint: l10n.emailHint,
                    error: emailError,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),

                  // Phone
                  _buildField(
                    controller: _phoneController,
                    hint: l10n.phoneHint,
                    error: phoneError,
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading,
                  ),

                  // Password
                  _buildField(
                    controller: _passwordController,
                    hint: l10n.passwordHint,
                    error: passwordError,
                    obscureText: true,
                    enabled: !isLoading,
                  ),

                  // Confirm password
                  _buildField(
                    controller: _confirmPasswordController,
                    hint: l10n.confirmPasswordHint,
                    error: confirmPasswordError,
                    obscureText: true,
                    enabled: !isLoading,
                  ),

                  // Register button
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _onRegister,
                        child: Text(
                          isLoading ? l10n.registering : l10n.registerButton,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom text
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: GestureDetector(
                onTap: isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  l10n.haveAccount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    String? error,
    double topMargin = 15,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, top: topMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(color: AppColors.black),
              enabled: enabled,
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                error,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
