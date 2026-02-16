import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/valve_card.dart';

class ValveManagementScreen extends StatefulWidget {
  const ValveManagementScreen({super.key});

  @override
  State<ValveManagementScreen> createState() => _ValveManagementScreenState();
}

class _ValveManagementScreenState extends State<ValveManagementScreen> {
  // 8 valves: odd = open (green), even = closed (red)
  final List<bool> _valveStates = [
    true, false, true, false, true, false, true, false,
  ];

  void _showConfirmDialog(int index) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrentlyOpen = _valveStates[index];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmAction),
        content: Text(
          isCurrentlyOpen ? l10n.confirmClose : l10n.confirmOpen,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _valveStates[index] = !_valveStates[index];
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.valveStateChanged)),
              );
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }

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
                    l10n.valveManagementTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Grid of valve buttons
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    for (int row = 0; row < 4; row++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ValveCard(
                              name: '${l10n.valve} ${row * 2 + 1}',
                              isOpen: _valveStates[row * 2],
                              onTap: () => _showConfirmDialog(row * 2),
                            ),
                            ValveCard(
                              name: '${l10n.valve} ${row * 2 + 2}',
                              isOpen: _valveStates[row * 2 + 1],
                              onTap: () => _showConfirmDialog(row * 2 + 1),
                            ),
                          ],
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
