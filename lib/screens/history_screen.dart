import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/history_item.dart';
import '../providers/history_provider.dart';
import '../providers/profile_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _showFilter = false;

  final Set<int> _selectedValves = {};
  bool _filterOpenings = false;
  bool _filterClosings = false;
  DateTime? _startDate;
  DateTime? _endDate;

  DateTime? _parseDate(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final dateParts = parts[0].split('/');
      final timeParts = parts[1].split(':');
      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (_) {
      return null;
    }
  }

  List<Map<String, String>> _applyFiltersTo(List<Map<String, String>> allItems) {
    return allItems.where((item) {
      // Valve filter — extract number from any "Valve X" format
      if (_selectedValves.isNotEmpty) {
        final match = RegExp(r'\d+').firstMatch(item['valve'] ?? '');
        final valveNum = match != null ? int.tryParse(match.group(0)!) : null;
        if (valveNum == null || !_selectedValves.contains(valveNum)) return false;
      }

      // Action type filter
      if (_filterOpenings && !_filterClosings) {
        if (item['action'] != 'Opened') return false;
      } else if (_filterClosings && !_filterOpenings) {
        if (item['action'] != 'Closed') return false;
      }

      // Date range filter
      if (_startDate != null || _endDate != null) {
        final itemDate = _parseDate(item['time']!);
        if (itemDate == null) return false;
        if (_startDate != null && itemDate.isBefore(_startDate!)) return false;
        if (_endDate != null) {
          final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          if (itemDate.isAfter(endOfDay)) return false;
        }
      }

      return true;
    }).toList();
  }

  void _applyFilters() {
    setState(() => _showFilter = false);
  }

  void _clearFilters() {
    setState(() {
      _selectedValves.clear();
      _filterOpenings = false;
      _filterClosings = false;
      _startDate = null;
      _endDate = null;
      _showFilter = false;
    });
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompactCalendar(initialDate: initial),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  bool get _hasActiveFilters =>
      _selectedValves.isNotEmpty ||
      _filterOpenings ||
      _filterClosings ||
      _startDate != null ||
      _endDate != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final valveLimit = int.tryParse(ref.watch(profileProvider).valueOrNull?.valves ?? '8') ?? 8;
    final historyAsync = ref.watch(historyProvider);
    final allItems = historyAsync.valueOrNull
            ?.map((e) => e.toMap())
            .toList() ??
        [];
    final filteredItems = _applyFiltersTo(allItems);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset(
                            'assets/icons/tune.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              _hasActiveFilters ? AppColors.primaryGreen : AppColors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        if (_hasActiveFilters)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Results count
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 16),
              child: Text(
                l10n.resultCount(filteredItems.length, allItems.length),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.descriptionGray,
                ),
              ),
            ),

            // Filter panel
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
                          children: List.generate(valveLimit, (i) {
                            final valveNum = i + 1;
                            return FilterChip(
                              label: Text('${l10n.valve} $valveNum'),
                              selected: _selectedValves.contains(valveNum),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedValves.add(valveNum);
                                  } else {
                                    _selectedValves.remove(valveNum);
                                  }
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
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
                              selected: _filterOpenings,
                              onSelected: (v) => setState(() => _filterOpenings = v),
                            ),
                            FilterChip(
                              label: Text(l10n.closings),
                              selected: _filterClosings,
                              onSelected: (v) => setState(() => _filterClosings = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.period,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _pickDate(context, isStart: true),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  side: BorderSide(
                                    color: _startDate != null
                                        ? AppColors.primaryGreen
                                        : AppColors.editTextBorder,
                                  ),
                                  foregroundColor: _startDate != null
                                      ? AppColors.primaryGreen
                                      : AppColors.subtitleGray,
                                ),
                                child: Text(
                                  _startDate != null
                                      ? _formatDate(_startDate!)
                                      : l10n.startDate,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _pickDate(context, isStart: false),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  side: BorderSide(
                                    color: _endDate != null
                                        ? AppColors.primaryGreen
                                        : AppColors.editTextBorder,
                                  ),
                                  foregroundColor: _endDate != null
                                      ? AppColors.primaryGreen
                                      : AppColors.subtitleGray,
                                ),
                                child: Text(
                                  _endDate != null
                                      ? _formatDate(_endDate!)
                                      : l10n.endDate,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _clearFilters,
                                child: Text(l10n.clearFilters),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _applyFilters,
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
              child: filteredItems.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
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

// ── Compact calendar bottom sheet ────────────────────────────────────────────

class _CompactCalendar extends StatefulWidget {
  final DateTime initialDate;
  const _CompactCalendar({required this.initialDate});

  @override
  State<_CompactCalendar> createState() => _CompactCalendarState();
}

class _CompactCalendarState extends State<_CompactCalendar> {
  late DateTime _viewing;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _viewing = DateTime(_selected.year, _selected.month);
  }

  int get _daysInMonth =>
      DateTime(_viewing.year, _viewing.month + 1, 0).day;

  // 0 = Mon … 6 = Sun
  int get _firstDayOffset =>
      DateTime(_viewing.year, _viewing.month, 1).weekday - 1;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    // narrowWeekdays is Sun-first → reorder to Mon-first
    final rawHeaders = localizations.narrowWeekdays; // [S,M,T,W,T,F,S]
    final headers = [...rawHeaders.sublist(1), rawHeaders[0]];

    final monthLabel = localizations.formatMonthYear(
      DateTime(_viewing.year, _viewing.month),
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grayDisabled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _viewing = DateTime(_viewing.year, _viewing.month - 1);
                }),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _viewing = DateTime(_viewing.year, _viewing.month + 1);
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Day-of-week headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: headers
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.descriptionGray,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),

          // Day grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...List.generate(_firstDayOffset, (_) => const SizedBox()),
              ...List.generate(_daysInMonth, (i) {
                final day = i + 1;
                final date = DateTime(_viewing.year, _viewing.month, day);
                final isSelected = _selected.year == date.year &&
                    _selected.month == date.month &&
                    _selected.day == date.day;
                final isToday = DateTime.now().year == date.year &&
                    DateTime.now().month == date.month &&
                    DateTime.now().day == date.day;
                return GestureDetector(
                  onTap: () => setState(() => _selected = date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primaryGreen, width: 1)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  localizations.cancelButtonLabel,
                  style: const TextStyle(color: AppColors.subtitleGray),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(80, 40),
                  elevation: 0,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
