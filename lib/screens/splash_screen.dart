import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final isEn = currentLocale.languageCode == 'en';

    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector - top right
            Padding(
              padding: EdgeInsets.only(top: h * 0.06, right: w * 0.05),
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                      child: Text(
                        'EN',
                        style: TextStyle(
                          fontSize: w * 0.037,
                          fontWeight: FontWeight.bold,
                          color: isEn ? AppColors.primaryGreen : AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.01),
                    Text(
                      '|',
                      style: TextStyle(fontSize: w * 0.037, color: AppColors.separatorGray),
                    ),
                    SizedBox(width: w * 0.01),
                    GestureDetector(
                      onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('fr')),
                      child: Text(
                        'FR',
                        style: TextStyle(
                          fontSize: w * 0.037,
                          fontWeight: FontWeight.bold,
                          color: !isEn ? AppColors.primaryGreen : AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.only(left: w * 0.08, top: h * 0.012),
              child: Text(
                l10n.appName,
                style: TextStyle(
                  fontSize: w * 0.09,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),

            // Subtitle
            Padding(
              padding: EdgeInsets.only(left: w * 0.08, top: h * 0.015),
              child: Text(
                l10n.appSubtitle,
                style: TextStyle(
                  fontSize: w * 0.05,
                  color: AppColors.subtitleGray,
                ),
              ),
            ),

            // Logo
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/icons/logo_tesla_v2.png',
                  width: w * 0.7,
                  height: h * 0.4,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Get Started button
            Padding(
              padding: EdgeInsets.only(left: w * 0.08, right: w * 0.08, top: h * 0.03, bottom: h * 0.04),
              child: SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(l10n.getStarted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
