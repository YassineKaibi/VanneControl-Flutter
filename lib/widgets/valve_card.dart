import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class ValveCard extends StatelessWidget {
  final String name;
  final bool isOpen;
  final bool isDisabled;
  final VoidCallback? onTap;
  final double size;

  const ValveCard({
    super.key,
    required this.name,
    required this.isOpen,
    this.isDisabled = false,
    this.onTap,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDisabled
        ? AppColors.grayDisabled
        : (isOpen ? AppColors.primaryGreen : AppColors.deleteRed);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(size * 0.25),
              child: SvgPicture.asset(
                isOpen
                    ? 'assets/icons/ic_toggle_on.svg'
                    : 'assets/icons/ic_toggle_off.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: (size * 0.14).clamp(11.0, 15.0),
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
