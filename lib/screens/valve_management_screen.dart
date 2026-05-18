import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/valve_card.dart';
import '../models/api_responses.dart';
import '../providers/valve_provider.dart';

class ValveManagementScreen extends ConsumerWidget {
  const ValveManagementScreen({super.key});

  void _showConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DeviceModel device,
    PistonModel piston,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmAction),
        content: Text(piston.isActive ? l10n.confirmClose : l10n.confirmOpen),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(valveProvider.notifier).togglePiston(
                    device.id,
                    piston.pistonNumber,
                    piston.isActive,
                  );
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final valveState = ref.watch(valveProvider);

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
                      l10n.valveManagementTitle,
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
                      child: const Icon(Icons.refresh, color: AppColors.primaryGreen),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: valveState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : valveState.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(valveState.error!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.read(valveProvider.notifier).refresh(),
                                child: Text(l10n.ok),
                              ),
                            ],
                          ),
                        )
                      : valveState.devices.isEmpty
                          ? Center(child: Text(l10n.noActiveValves))
                          : _DevicePistonGrid(
                              devices: valveState.devices,
                              l10n: l10n,
                              onTap: (device, piston) => _showConfirmDialog(
                                context, ref, l10n, device, piston,
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevicePistonGrid extends StatefulWidget {
  final List<DeviceModel> devices;
  final AppLocalizations l10n;
  final void Function(DeviceModel, PistonModel) onTap;

  const _DevicePistonGrid({
    required this.devices,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<_DevicePistonGrid> createState() => _DevicePistonGridState();
}

class _DevicePistonGridState extends State<_DevicePistonGrid> {
  int _selectedDeviceIndex = 0;

  @override
  Widget build(BuildContext context) {
    final device = widget.devices[_selectedDeviceIndex];

    // Build a map of pistonNumber → PistonModel for quick lookup
    final pistonMap = {for (final p in device.pistons) p.pistonNumber: p};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Device selector (only if multiple devices)
          if (widget.devices.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: DropdownButton<int>(
                value: _selectedDeviceIndex,
                isExpanded: true,
                items: List.generate(
                  widget.devices.length,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(widget.devices[i].name),
                  ),
                ),
                onChanged: (i) => setState(() => _selectedDeviceIndex = i!),
              ),
            ),

          // 4 rows × 2 columns = 8 pistons
          for (int row = 0; row < 4; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int col = 0; col < 2; col++)
                    Builder(builder: (_) {
                      final num = row * 2 + col + 1;
                      final piston = pistonMap[num];
                      final isOpen = piston?.isActive ?? false;
                      return ValveCard(
                        name: '${widget.l10n.valve} $num',
                        isOpen: isOpen,
                        onTap: piston != null
                            ? () => widget.onTap(device, piston)
                            : null,
                      );
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
