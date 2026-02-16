import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/nav_card.dart';
import '../widgets/active_valve_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final activeValves = [
      {'name': 'Valve 1', 'status': 'Active', 'time': '10:30 AM'},
      {'name': 'Valve 3', 'status': 'Active', 'time': '10:30 AM'},
      {'name': 'Valve 5', 'status': 'Active', 'time': '10:30 AM'},
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with elevation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.welcome,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.controlPanel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.grey,
                        child: SvgPicture.asset(
                          'assets/icons/account_circle.svg',
                          width: 80,
                          height: 80,
                          colorFilter: const ColorFilter.mode(
                            AppColors.grayIcon,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Valves title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        l10n.activeValves,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),

                    // Active Valves card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          height: 150,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(12),
                            itemCount: activeValves.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final valve = activeValves[index];
                              return ActiveValveItem(
                                name: valve['name']!,
                                status: valve['status']!,
                                time: valve['time']!,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Features / Control Modules title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Text(
                        l10n.controlModules,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),

                    // Nav cards
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: NavCard(
                        svgAsset: 'assets/icons/ic_water.svg',
                        title: l10n.valveManagement,
                        description: l10n.valveManagementDescription,
                        onTap: () =>
                            Navigator.pushNamed(context, '/valves'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: NavCard(
                        svgAsset: 'assets/icons/timing_plan.svg',
                        title: l10n.timingPlan,
                        description: l10n.timingPlanDescription,
                        onTap: () =>
                            Navigator.pushNamed(context, '/scheduling'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: NavCard(
                        svgAsset: 'assets/icons/ic_calendar.svg',
                        title: l10n.valveOperationHistory,
                        description: l10n.valveOperationHistoryDescription,
                        onTap: () =>
                            Navigator.pushNamed(context, '/history'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: NavCard(
                        svgAsset: 'assets/icons/ic_bar_chart.svg',
                        title: l10n.usageStatistics,
                        description: l10n.usageStatisticsDescription,
                        onTap: () =>
                            Navigator.pushNamed(context, '/statistics'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: NavCard(
                        svgAsset: 'assets/icons/ic_notifications.svg',
                        title: l10n.alertsAndNotifications,
                        description: l10n.alertsAndNotificationsDescription,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.todoImplement)),
                          );
                        },
                      ),
                    ),
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
