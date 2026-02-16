import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showFilter = false;

  final List<Map<String, String>> _historyItems = [
    {'valve': 'Valve 1', 'action': 'Opened', 'time': '21/10/2025 14:30', 'user': 'Admin'},
    {'valve': 'Valve 3', 'action': 'Closed', 'time': '21/10/2025 13:10', 'user': 'Admin'},
    {'valve': 'Valve 2', 'action': 'Opened', 'time': '21/10/2025 11:45', 'user': 'Admin'},
    {'valve': 'Valve 1', 'action': 'Closed', 'time': '20/10/2025 18:20', 'user': 'Admin'},
    {'valve': 'Valve 5', 'action': 'Opened', 'time': '20/10/2025 16:00', 'user': 'Admin'},
    {'valve': 'Valve 3', 'action': 'Opened', 'time': '20/10/2025 09:15', 'user': 'Admin'},
    {'valve': 'Valve 2', 'action': 'Closed', 'time': '19/10/2025 22:30', 'user': 'Admin'},
    {'valve': 'Valve 4', 'action': 'Opened', 'time': '19/10/2025 14:00', 'user': 'Admin'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Expanded(
                    child: Text(
                      l10n.historyTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFilter = !_showFilter;
                      });
                    },
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: SvgPicture.asset(
                        'assets/icons/tune.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results count
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 16),
              child: Text(
                l10n.resultCount(_historyItems.length, _historyItems.length),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.descriptionGray,
                ),
              ),
            ),

            // Filter panel (togglable)
            if (_showFilter)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.filterHistory,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Valve selection chips
                        Text(
                          l10n.selectValves,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: List.generate(8, (i) {
                            return FilterChip(
                              label: Text('${l10n.valve} ${i + 1}'),
                              selected: false,
                              onSelected: (_) {},
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        // Action type
                        Text(
                          l10n.actionType,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: Text(l10n.openings),
                              selected: false,
                              onSelected: (_) {},
                            ),
                            FilterChip(
                              label: Text(l10n.closings),
                              selected: false,
                              onSelected: (_) {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Date range
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  side: const BorderSide(
                                      color: AppColors.editTextBorder),
                                  foregroundColor: AppColors.subtitleGray,
                                ),
                                child: Text(l10n.startDate),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  side: const BorderSide(
                                      color: AppColors.editTextBorder),
                                  foregroundColor: AppColors.subtitleGray,
                                ),
                                child: Text(l10n.endDate),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Clear / Apply buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: Text(l10n.clearFilters),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showFilter = false;
                                  });
                                },
                                child: Text(l10n.applyFilters),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // History list
            Expanded(
              child: _historyItems.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: _historyItems.length,
                      itemBuilder: (context, index) {
                        final item = _historyItems[index];
                        return HistoryItem(
                          valveName: item['valve']!,
                          action: item['action']!,
                          timestamp: item['time']!,
                          user: item['user']!,
                        );
                      },
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
            'assets/icons/ic_water.svg',
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(
              AppColors.grayDisabled.withAlpha(77),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noHistory,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.grayIcon,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noHistoryDescription,
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
