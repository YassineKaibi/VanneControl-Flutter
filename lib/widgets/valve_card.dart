import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class ValveCard extends StatelessWidget {
  final String name;
  final bool isOpen;
  final VoidCallback? onTap;

  const ValveCard({
    super.key,
    required this.name,
    required this.isOpen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isOpen ? AppColors.primaryGreen : AppColors.valveInactiveRed;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(25),
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
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
