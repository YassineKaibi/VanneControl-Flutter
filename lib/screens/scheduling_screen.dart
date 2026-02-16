import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/schedule_card.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final List<Map<String, dynamic>> _schedules = [
    {
      'name': 'Morning Irrigation',
      'valve': 'Valve 1',
      'onTime': '08:00',
      'offTime': '20:00',
      'repeat': 'Everyday',
      'enabled': true,
    },
    {
      'name': 'Evening Watering',
      'valve': 'Valve 3',
      'onTime': '18:30',
      'offTime': '19:30',
      'repeat': 'Weekdays',
      'enabled': true,
    },
    {
      'name': 'Weekend Cycle',
      'valve': 'Valve 2',
      'onTime': '10:00',
      'offTime': '12:00',
      'repeat': 'Weekends',
      'enabled': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom top bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: SvgPicture.asset(
                        'assets/icons/arrow_back.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.timingPlan,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Schedule list or empty state
            Expanded(
              child: _schedules.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
                        return ScheduleCard(
                          name: schedule['name'] as String,
                          valveName: schedule['valve'] as String,
                          onTime: schedule['onTime'] as String,
                          offTime: schedule['offTime'] as String,
                          repeatText: schedule['repeat'] as String,
                          isEnabled: schedule['enabled'] as bool,
                          onToggle: (value) {
                            setState(() {
                              schedule['enabled'] = value;
                            });
                          },
                          onEdit: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.todoImplement)),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.deleteSchedule),
                                content: Text(l10n.deleteScheduleConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _schedules.removeAt(index);
                                      });
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text(l10n.scheduleDeleted)),
                                      );
                                    },
                                    child: Text(
                                      l10n.delete,
                                      style: const TextStyle(
                                          color: AppColors.deleteRed),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),

            // Bottom Add button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.todoImplement)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    l10n.add,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/timing_plan.svg',
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(
              AppColors.grayDisabled.withAlpha(102),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noSchedules,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.grayIcon,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapAddSchedule,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grayDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
