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
              padding: const EdgeInsets.only(top: 50, right: 20),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isEn ? AppColors.primaryGreen : AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '|',
                      style: TextStyle(fontSize: 14, color: AppColors.separatorGray),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('fr')),
                      child: Text(
                        'FR',
                        style: TextStyle(
                          fontSize: 14,
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
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Text(
                l10n.appName,
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 15),
              child: Text(
                l10n.appSubtitle,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.subtitleGray,
                ),
              ),
            ),

            // Logo
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: SvgPicture.asset(
                    'assets/icons/ic_water.svg',
                    width: 200,
                    height: 200,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),

            // Get Started button
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 43, bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
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
