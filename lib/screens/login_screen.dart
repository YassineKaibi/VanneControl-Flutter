import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/valve_provider.dart';
import '../providers/profile_provider.dart';
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
        success: (data) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.loginSuccess)),
          );
          // Pré-charger les données du dashboard
          ref.read(valveProvider.notifier).refresh();
          ref.read(profileProvider);
          // Attendre que les données soient chargées (max 3s)
          for (int i = 0; i < 30; i++) {
            await Future.delayed(const Duration(milliseconds: 100));
            if (!ref.read(valveProvider).isLoading) break;
          }
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        },
        error: (message, code) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: h * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.12),
                  Center(
                    child: Text(
                      l10n.loginTitle,
                      style: TextStyle(
                        fontSize: w * 0.1,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),

                  // Email field
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.07),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: h * 0.065,
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: l10n.emailHint,
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: AppColors.black, fontSize: w * 0.04),
                            enabled: !isLoading,
                          ),
                        ),
                        if (emailError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(emailError, style: TextStyle(color: const Color(0xFFD32F2F), fontSize: w * 0.03)),
                          ),
                      ],
                    ),
                  ),

                  // Password field
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: h * 0.065,
                          child: TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: l10n.passwordHint,
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                            ),
                            obscureText: true,
                            style: TextStyle(color: AppColors.black, fontSize: w * 0.04),
                            enabled: !isLoading,
                          ),
                        ),
                        if (passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(passwordError, style: TextStyle(color: const Color(0xFFD32F2F), fontSize: w * 0.03)),
                          ),
                      ],
                    ),
                  ),

                  // Forgot password
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.025),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.todoImplement)),
                        );
                      },
                      child: Text(
                        l10n.forgotPassword,
                        style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.bold, color: AppColors.black),
                      ),
                    ),
                  ),

                  // Login button
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.05),
                    child: SizedBox(
                      width: double.infinity,
                      height: h * 0.065,
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _onLogin,
                        child: Text(isLoading ? l10n.loggingIn : l10n.loginButton),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom text
          Padding(
            padding: EdgeInsets.only(bottom: h * 0.04),
            child: Center(
              child: GestureDetector(
                onTap: isLoading ? null : () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  l10n.noAccount,
                  style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
