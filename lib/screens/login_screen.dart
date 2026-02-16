import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/network_result.dart';
import '../models/api_responses.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final l10n = AppLocalizations.of(context)!;
    final emailErr = ref.read(emailErrorProvider.notifier);
    final passwordErr = ref.read(passwordErrorProvider.notifier);

    final valid = validateLogin(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      emailError: emailErr,
      passwordError: passwordErr,
      errorEmailRequired: l10n.errorEmailRequired,
      errorEmailInvalid: l10n.errorEmailInvalid,
      errorPasswordRequired: l10n.errorPasswordRequired,
      errorPasswordTooShort: l10n.errorPasswordTooShort,
    );

    if (valid) {
      ref.read(loginStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loginState = ref.watch(loginStateProvider);
    final emailError = ref.watch(emailErrorProvider);
    final passwordError = ref.watch(passwordErrorProvider);
    final isLoading = loginState is Loading<AuthResponse>;

    // Listen for login result
    ref.listen<NetworkResult<AuthResponse>>(loginStateProvider, (prev, next) {
      next.when(
        idle: () {},
        loading: () {},
        success: (data) {
          // Toast + navigate to dashboard (matches LoginActivity.kt)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.loginSuccess)),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
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
                  const SizedBox(height: 136),
                  Text(
                    l10n.loginTitle,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),

                  // Email field
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: l10n.emailHint,
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppColors.black),
                            enabled: !isLoading,
                          ),
                        ),
                        if (emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              emailError,
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Password field
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: l10n.passwordHint,
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                            obscureText: true,
                            style: const TextStyle(color: AppColors.black),
                            enabled: !isLoading,
                          ),
                        ),
                        if (passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              passwordError,
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Forgot password - LEFT aligned
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 20),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.todoImplement)),
                        );
                      },
                      child: Text(
                        l10n.forgotPassword,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),

                  // Login button
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 40,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _onLogin,
                        child: Text(
                          isLoading ? l10n.loggingIn : l10n.loginButton,
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
                onTap: isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/register');
                      },
                child: Text(
                  l10n.noAccount,
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
}
