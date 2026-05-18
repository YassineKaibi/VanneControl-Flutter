import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/schedule_card.dart';
import '../providers/schedule_provider.dart';
import '../providers/valve_provider.dart';

class SchedulingScreen extends ConsumerWidget {
  const SchedulingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final schedState = ref.watch(scheduleProvider);
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
                        colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.timingPlan,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: schedState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : schedState.plans.isEmpty
                      ? _EmptyState(l10n: l10n)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: schedState.plans.length,
                          itemBuilder: (context, index) {
                            final plan = schedState.plans[index];
                            final valveName = '${l10n.valve} ${plan.pistonNumber}';
                            final repeatDisplay = plan.repeatText == 'Custom'
                                ? plan.rawDaysOfWeek.replaceAll('MON', 'Mo').replaceAll('TUE', 'Tu').replaceAll('WED', 'We').replaceAll('THU', 'Th').replaceAll('FRI', 'Fr').replaceAll('SAT', 'Sa').replaceAll('SUN', 'Su')
                                : plan.repeatText;
                            return ScheduleCard(
                              name: plan.name,
                              valveName: valveName,
                              onTime: plan.onTime,
                              offTime: plan.offTime,
                              repeatText: repeatDisplay,
                              isEnabled: plan.enabled,
                              onToggle: (v) => ref.read(scheduleProvider.notifier).togglePlan(plan, v),
                              onEdit: () => _showEditDialog(context, ref, l10n, valveState, plan),
                              onDelete: () => _confirmDelete(context, ref, l10n, plan),
                            );
                          },
                        ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: valveState.devices.isEmpty
                      ? null
                      : () => _showAddDialog(context, ref, l10n, valveState),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(l10n.add, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n, plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSchedule),
        content: Text(l10n.deleteScheduleConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(scheduleProvider.notifier).deletePlan(plan);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.scheduleDeleted)),
              );
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.deleteRed)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, ValveState valveState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddScheduleSheet(l10n: l10n, valveState: valveState, ref: ref),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, ValveState valveState, plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddScheduleSheet(l10n: l10n, valveState: valveState, ref: ref, editPlan: plan),
    );
  }
}

class _AddScheduleSheet extends StatefulWidget {
  final AppLocalizations l10n;
  final ValveState valveState;
  final WidgetRef ref;
  final dynamic editPlan;

  const _AddScheduleSheet({required this.l10n, required this.valveState, required this.ref, this.editPlan});

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  late final TextEditingController _nameController;
  int _selectedDeviceIndex = 0;
  late int _pistonNumber;
  late TimeOfDay _onTime;
  late TimeOfDay _offTime;
  late bool _useOnTime;
  late bool _useOffTime;
  late String _repeat;
  DateTime? _onceDate;
  late List<bool> _selectedDays; // Mon-Sun
  bool _isLoading = false;

  static const _dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  void initState() {
    super.initState();
    final plan = widget.editPlan;
    if (plan != null) {
      _nameController = TextEditingController(text: plan.name);
      _pistonNumber = plan.pistonNumber;
      _useOnTime = plan.activateEntry != null;
      _useOffTime = plan.deactivateEntry != null;
      _onTime = _useOnTime ? _parseTime(plan.onTime) : const TimeOfDay(hour: 8, minute: 0);
      _offTime = _useOffTime ? _parseTime(plan.offTime) : const TimeOfDay(hour: 20, minute: 0);
      _repeat = plan.repeatText.isEmpty ? 'Everyday' : plan.repeatText;
      _onceDate = _repeat == 'Once' ? DateTime.now() : null;
      _selectedDays = _parseDays(plan.rawDaysOfWeek);
      // Find device index
      final devices = widget.valveState.devices;
      final idx = devices.indexWhere((d) => d.id == plan.deviceId);
      _selectedDeviceIndex = idx >= 0 ? idx : 0;
    } else {
      _nameController = TextEditingController();
      _pistonNumber = 1;
      _useOnTime = false;
      _useOffTime = false;
      _onTime = const TimeOfDay(hour: 8, minute: 0);
      _offTime = const TimeOfDay(hour: 20, minute: 0);
      _repeat = 'Everyday';
      _selectedDays = List.filled(7, false);
    }
  }

  TimeOfDay _parseTime(String t) {
    try {
      final parts = t.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  final _repeats = ['Everyday', 'Custom', 'Once'];

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<bool> _parseDays(String rawDow) {
    if (rawDow.isEmpty || rawDow == '*' || rawDow == '?') return List.filled(7, false);
    // Handle range like MON-FRI
    if (rawDow.contains('-') && !rawDow.contains(',')) {
      final parts = rawDow.split('-');
      final start = _dayNames.indexOf(parts[0]);
      final end = _dayNames.indexOf(parts[1]);
      if (start >= 0 && end >= 0) {
        return List.generate(7, (i) => i >= start && i <= end);
      }
    }
    final days = rawDow.split(',');
    return List.generate(7, (i) => days.contains(_dayNames[i]));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _onceDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _onceDate = picked);
  }

  Future<void> _pickTime(bool isOn) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOn ? _onTime : _offTime,
    );
    if (picked != null) {
      setState(() => isOn ? _onTime = picked : _offTime = picked);
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;
    if (!_useOnTime && !_useOffTime) return;
    if (_repeat == 'Once' && _onceDate == null) return;
    if (_repeat == 'Custom' && !_selectedDays.contains(true)) return;
    final device = widget.valveState.devices[_selectedDeviceIndex];

    String? customDays;
    if (_repeat == 'Custom') {
      final selected = <String>[];
      for (int i = 0; i < 7; i++) {
        if (_selectedDays[i]) selected.add(_dayNames[i]);
      }
      customDays = selected.join(',');
    }

    setState(() => _isLoading = true);

    // If editing, delete the old plan first
    if (widget.editPlan != null) {
      await widget.ref.read(scheduleProvider.notifier).deletePlan(widget.editPlan);
    }

    final error = await widget.ref.read(scheduleProvider.notifier).addSchedule(
          name: _nameController.text.trim(),
          deviceId: device.id,
          pistonNumber: _pistonNumber,
          onHour: _useOnTime ? _onTime.hour : null,
          onMinute: _useOnTime ? _onTime.minute : null,
          offHour: _useOffTime ? _offTime.hour : null,
          offMinute: _useOffTime ? _offTime.minute : null,
          repeat: _repeat,
          onceDate: _onceDate,
          customDays: customDays,
        );
    if (mounted) {
      if (error != null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $error'), backgroundColor: Colors.red),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.scheduleSaved)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final devices = widget.valveState.devices;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.editPlan != null ? l10n.edit : l10n.add,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l10n.scheduleName),
          ),
          const SizedBox(height: 12),

          // Device selector
          if (devices.length > 1) ...[
            DropdownButtonFormField<int>(
              value: _selectedDeviceIndex,
              decoration: const InputDecoration(labelText: 'Device'),
              items: List.generate(devices.length, (i) => DropdownMenuItem(value: i, child: Text(devices[i].name))),
              onChanged: (i) => setState(() => _selectedDeviceIndex = i!),
            ),
            const SizedBox(height: 12),
          ],

          // Valve number
          DropdownButtonFormField<int>(
            value: _pistonNumber,
            decoration: InputDecoration(labelText: l10n.selectValve),
            items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('${l10n.valve} ${i + 1}'))),
            onChanged: (v) => setState(() => _pistonNumber = v!),
          ),
          const SizedBox(height: 12),

          // ON time
          Row(
            children: [
              Checkbox(
                value: _useOnTime,
                activeColor: AppColors.primaryGreen,
                onChanged: (v) => setState(() => _useOnTime = v!),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'ON  ${_fmt(_onTime)}',
                    style: TextStyle(
                      color: _useOnTime ? AppColors.primaryGreen : AppColors.grayDisabled,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(Icons.access_time, color: _useOnTime ? AppColors.primaryGreen : AppColors.grayDisabled),
                  onTap: _useOnTime ? () => _pickTime(true) : null,
                ),
              ),
            ],
          ),

          // OFF time
          Row(
            children: [
              Checkbox(
                value: _useOffTime,
                activeColor: AppColors.deleteRed,
                onChanged: (v) => setState(() => _useOffTime = v!),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'OFF  ${_fmt(_offTime)}',
                    style: TextStyle(
                      color: _useOffTime ? AppColors.deleteRed : AppColors.grayDisabled,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(Icons.access_time, color: _useOffTime ? AppColors.deleteRed : AppColors.grayDisabled),
                  onTap: _useOffTime ? () => _pickTime(false) : null,
                ),
              ),
            ],
          ),

          // Repeat
          DropdownButtonFormField<String>(
            value: _repeat,
            decoration: InputDecoration(labelText: l10n.repeat),
            items: _repeats.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) {
              setState(() {
                _repeat = v!;
                if (_repeat == 'Once' && _onceDate == null) {
                  _onceDate = DateTime.now();
                }
              });
            },
          ),

          // Day selector (only for Custom)
          if (_repeat == 'Custom') ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final selected = _selectedDays[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDays[i] = !_selectedDays[i]),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primaryGreen : Colors.transparent,
                      border: Border.all(
                        color: selected ? AppColors.primaryGreen : AppColors.grayDisabled,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _dayLabels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selected ? AppColors.white : AppColors.grayDisabled,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],

          // Date picker (only for Once)
          if (_repeat == 'Once') ...[
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
              title: Text(
                _onceDate != null
                    ? '${_onceDate!.year}-${_onceDate!.month.toString().padLeft(2, '0')}-${_onceDate!.day.toString().padLeft(2, '0')}'
                    : 'Select date',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: _pickDate,
            ),
          ],
          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/timing_plan.svg',
            width: 80, height: 80,
            colorFilter: ColorFilter.mode(AppColors.grayDisabled.withAlpha(102), BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          Text(l10n.noSchedules, style: const TextStyle(fontSize: 18, color: AppColors.grayIcon)),
          const SizedBox(height: 8),
          Text(l10n.tapAddSchedule, style: const TextStyle(fontSize: 14, color: AppColors.grayDisabled)),
        ],
      ),
    );
  }
}
