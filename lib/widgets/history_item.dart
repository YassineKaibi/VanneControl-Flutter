import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class HistoryItem extends StatelessWidget {
  final String valveName;
  final String action;
  final String timestamp;
  final String user;

  const HistoryItem({
    super.key,
    required this.valveName,
    required this.action,
    required this.timestamp,
    this.user = 'Admin',
  });

  @override
  Widget build(BuildContext context) {
    final isOpened = action.toLowerCase() == 'opened' ||
        action.toLowerCase() == 'activated';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Toggle icon
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.editTextBorder, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                isOpened
                    ? 'assets/icons/ic_toggle_on.svg'
                    : 'assets/icons/ic_toggle_off.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isOpened ? AppColors.primaryGreen : AppColors.deleteRed,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valveName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isOpened
                            ? AppColors.primaryGreen
                            : AppColors.deleteRed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timestamp,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.descriptionGray,
                      ),
                    ),
                    if (user.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Par: $user',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.placeholderGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
