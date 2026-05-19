import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/nav_card.dart';
import '../widgets/active_valve_item.dart';
import '../providers/valve_provider.dart';
import '../providers/profile_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final valveState = ref.watch(valveProvider);
    final activeValves = valveState.activeValves;
    final avatarPath = ref.watch(profileProvider).valueOrNull?.avatarPath;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
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
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.grey,
                      backgroundImage: avatarPath != null
                          ? FileImage(File(avatarPath))
                          : null,
                      child: avatarPath == null
                          ? SvgPicture.asset(
                              'assets/icons/account_circle.svg',
                              width: 80,
                              height: 80,
                              colorFilter: const ColorFilter.mode(
                                AppColors.grayIcon,
                                BlendMode.srcIn,
                              ),
                            )
                          : null,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.activeValves,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          if (valveState.isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            GestureDetector(
                              onTap: () => ref.read(valveProvider.notifier).refresh(),
                              child: const Icon(Icons.refresh, size: 20, color: AppColors.primaryGreen),
                            ),
                        ],
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
                          child: valveState.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : valveState.error != null
                                  ? Center(
                                      child: Text(
                                        valveState.error!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : activeValves.isEmpty
                                      ? Center(
                                          child: Text(
                                            l10n.noActiveValves,
                                            style: const TextStyle(
                                              color: AppColors.placeholderGray,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.all(12),
                                          itemCount: activeValves.length,
                                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                                          itemBuilder: (context, index) {
                                            final v = activeValves[index];
                                            return ActiveValveItem(
                                              name: '${l10n.valve} ${v.pistonNumber}',
                                              status: l10n.active,
                                              time: v.formattedTime,
                                            );
                                          },
                                        ),
                        ),
                      ),
                    ),

                    // Control Modules title
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
                        onTap: () => Navigator.pushNamed(context, '/valves'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: NavCard(
                        svgAsset: 'assets/icons/timing_plan.svg',
                        title: l10n.timingPlan,
                        description: l10n.timingPlanDescription,
                        onTap: () => Navigator.pushNamed(context, '/scheduling'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: NavCard(
                        svgAsset: 'assets/icons/ic_calendar.svg',
                        title: l10n.valveOperationHistory,
                        description: l10n.valveOperationHistoryDescription,
                        onTap: () => Navigator.pushNamed(context, '/history'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: NavCard(
                        svgAsset: 'assets/icons/ic_bar_chart.svg',
                        title: l10n.usageStatistics,
                        description: l10n.usageStatisticsDescription,
                        onTap: () => Navigator.pushNamed(context, '/statistics'),
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
