import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class NavCard extends StatelessWidget {
  final String svgAsset;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBgColor;

  const NavCard({
    super.key,
    required this.svgAsset,
    required this.title,
    required this.description,
    this.onTap,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: iconBgColor != null
                    ? BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      )
                    : null,
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  svgAsset,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    iconColor ?? AppColors.primaryGreen,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.descriptionGray,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/ic_chevron_right.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.grayIcon,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
