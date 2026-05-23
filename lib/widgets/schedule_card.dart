import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class ScheduleCard extends StatelessWidget {
  final String name;
  final String valveName;
  final String? onTime;
  final String? offTime;
  final String repeatText;
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ScheduleCard({
    super.key,
    required this.name,
    required this.valveName,
    this.onTime,
    this.offTime,
    required this.repeatText,
    required this.isEnabled,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF6FAEE),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: name + switch
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            // Valve info
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                valveName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grayIcon,
                ),
              ),
            ),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: AppColors.grayDisabled.withAlpha(128),
              ),
            ),
            // ON time row
            if (onTime != null)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ON',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    onTime!,
                    style: const TextStyle(fontSize: 14, color: AppColors.black),
                  ),
                ],
              ),
            if (onTime != null && offTime != null) const SizedBox(height: 8),
            // OFF time row
            if (offTime != null)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.deleteRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'OFF',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deleteRed,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    offTime!,
                    style: const TextStyle(fontSize: 14, color: AppColors.black),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            // Repeat row with edit/delete
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_repeat.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.grayIcon,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  repeatText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grayIcon,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: onEdit,
                    icon: SvgPicture.asset(
                      'assets/icons/ic_edit.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryGreen,
                        BlendMode.srcIn,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: SvgPicture.asset(
                      'assets/icons/ic_delete.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        AppColors.deleteRed,
                        BlendMode.srcIn,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
