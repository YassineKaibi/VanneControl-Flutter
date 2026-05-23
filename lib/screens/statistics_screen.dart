import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/valve_provider.dart';
import '../providers/history_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  Set<int> _selectedValves = {};
  String _period = 'all';
  int _lastValveLimit = 0;

  static const _valveColors = [
    Color(0xFFFF5252),
    Color(0xFF156F35),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF91BC21),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  static const _periodKeys = ['24h', '7d', '30d', '90d', '365d', 'all'];
  static const _periodLabels = [
    'Last 24 hours',
    'Last 7 days',
    'Last 30 days',
    'Last 3 months',
    'Last year',
    'Since beginning',
  ];

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

  ({List<LineChartBarData> bars, List<int> valveNums, List<String> xLabels})
      _buildChartData(List<HistoryEntry> allHistory) {
    final empty = (bars: <LineChartBarData>[], valveNums: <int>[], xLabels: <String>[]);
    if (allHistory.isEmpty) return empty;

    final parsed = <({HistoryEntry entry, DateTime date})>[];
    for (final e in allHistory) {
      final d = _parseDate(e.time);
      if (d != null) parsed.add((entry: e, date: d));
    }
    if (parsed.isEmpty) return empty;

    final now = DateTime.now();
    DateTime rangeStart;
    Duration bucketSize;

    if (_period == 'all') {
      final oldest = parsed.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
      rangeStart = DateTime(oldest.year, oldest.month, oldest.day);
      final totalDays = now.difference(rangeStart).inDays;
      if (totalDays <= 7) {
        bucketSize = const Duration(days: 1);
      } else if (totalDays <= 60) {
        bucketSize = const Duration(days: 7);
      } else {
        bucketSize = const Duration(days: 30);
      }
    } else {
      switch (_period) {
        case '24h':
          rangeStart = now.subtract(const Duration(hours: 24));
          bucketSize = const Duration(hours: 1);
        case '7d':
          rangeStart = now.subtract(const Duration(days: 7));
          bucketSize = const Duration(days: 1);
        case '30d':
          rangeStart = now.subtract(const Duration(days: 30));
          bucketSize = const Duration(days: 1);
        case '90d':
          rangeStart = now.subtract(const Duration(days: 90));
          bucketSize = const Duration(days: 7);
        case '365d':
          rangeStart = now.subtract(const Duration(days: 365));
          bucketSize = const Duration(days: 30);
        default:
          rangeStart = now.subtract(const Duration(days: 30));
          bucketSize = const Duration(days: 1);
      }
    }

    final totalBuckets =
        (now.difference(rangeStart).inMicroseconds / bucketSize.inMicroseconds).ceil() + 1;
    if (totalBuckets <= 0) return empty;

    final bars = <LineChartBarData>[];
    final valveNums = <int>[];

    for (final valveNum in (_selectedValves.toList()..sort())) {
      final counts = List.filled(totalBuckets, 0);

      for (final e in parsed) {
        if (e.date.isBefore(rangeStart)) continue;
        final match = RegExp(r'\d+').firstMatch(e.entry.valve);
        if (match == null) continue;
        if (int.tryParse(match.group(0)!) != valveNum) continue;

        final bucketIdx =
            (e.date.difference(rangeStart).inMicroseconds / bucketSize.inMicroseconds).floor();
        if (bucketIdx >= 0 && bucketIdx < totalBuckets) counts[bucketIdx]++;
      }

      if (counts.every((c) => c == 0)) continue;

      final spots = List.generate(
          totalBuckets, (i) => FlSpot(i.toDouble(), counts[i].toDouble()));

      final color = _valveColors[(valveNum - 1) % _valveColors.length];
      bars.add(LineChartBarData(
        spots: spots,
        color: color,
        isCurved: true,
        curveSmoothness: 0.3,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: totalBuckets <= 20),
        belowBarData: BarAreaData(show: true, color: color.withAlpha(30)),
      ));
      valveNums.add(valveNum);
    }

    // X axis labels
    const monthAbbr = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final xLabels = List.generate(totalBuckets, (i) {
      final d = rangeStart.add(Duration(microseconds: (i * bucketSize.inMicroseconds)));
      if (bucketSize.inHours == 1) return '${d.hour.toString().padLeft(2, '0')}h';
      if (bucketSize.inDays < 14) {
        return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      }
      return monthAbbr[d.month - 1];
    });

    return (bars: bars, valveNums: valveNums, xLabels: xLabels);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final valveLimit =
        int.tryParse(ref.watch(profileProvider).valueOrNull?.valves ?? '8') ??
            8;
    final valveState = ref.watch(valveProvider);
    final historyAsync = ref.watch(historyProvider);

    if (_lastValveLimit != valveLimit) {
      _lastValveLimit = valveLimit;
      _selectedValves = Set.from(List.generate(valveLimit, (i) => i + 1));
    }

    final totalValves = valveLimit;
    final activeNow = valveState.devices
        .expand((d) =>
            d.pistons.where((p) => p.isActive && p.pistonNumber <= valveLimit))
        .length;
    final inactiveValves = totalValves - activeNow;
    final maintenanceValves = valveState.devices
        .where((d) => d.status == 'offline')
        .expand((d) => d.pistons.where((p) => p.pistonNumber <= valveLimit))
        .length;

    final allHistory = historyAsync.valueOrNull ?? [];

    final chartResult = _buildChartData(allHistory);
    final chartBars = chartResult.bars;
    final chartValveNums = chartResult.valveNums;
    final chartXLabels = chartResult.xLabels;

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
                            AppColors.black, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.statisticsTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.todoImplement)),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: Text(l10n.exportPdf),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview cards
                    Text(
                      l10n.overview,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: _StatCard(
                              title: l10n.totalValves,
                              value: '$totalValves',
                              color: const Color(0xFF156F35))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              title: l10n.activeNow,
                              value: '$activeNow',
                              color: const Color(0xFF4A8A33))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: _StatCard(
                              title: l10n.inactiveValves,
                              value: '$inactiveValves',
                              color: const Color(0xFF7AAC29))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _StatCard(
                              title: l10n.maintenance,
                              value: '$maintenanceValves',
                              color: const Color(0xFF9AC42D))),
                    ]),

                    const SizedBox(height: 24),
                    Text(
                      l10n.activationTimeline,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black),
                    ),
                    const SizedBox(height: 16),

                    // Valve chips — horizontal scrollable row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...List.generate(valveLimit, (i) {
                            final valveNum = i + 1;
                            final isSelected =
                                _selectedValves.contains(valveNum);
                            final color =
                                _valveColors[i % _valveColors.length];
                            return _ValveChip(
                              label: '${l10n.valve} $valveNum',
                              isSelected: isSelected,
                              color: color,
                              onTap: () => setState(() {
                                if (isSelected) {
                                  _selectedValves.remove(valveNum);
                                } else {
                                  _selectedValves.add(valveNum);
                                }
                              }),
                            );
                          }),
                          _ActionChip(
                            label: '✓ All',
                            color: const Color(0xFF4CAF50),
                            onTap: () => setState(() {
                              _selectedValves = Set.from(
                                  List.generate(valveLimit, (i) => i + 1));
                            }),
                          ),
                          _ActionChip(
                            label: '✗ None',
                            color: const Color(0xFFFF5252),
                            onTap: () =>
                                setState(() => _selectedValves.clear()),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Period selector
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              l10n.period,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButton<String>(
                                value: _period,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: List.generate(
                                  _periodKeys.length,
                                  (i) => DropdownMenuItem(
                                    value: _periodKeys[i],
                                    child: Text(_periodLabels[i]),
                                  ),
                                ),
                                onChanged: (v) =>
                                    setState(() => _period = v!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Line chart
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                        child: chartBars.isEmpty
                            ? SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    l10n.noData,
                                    style: const TextStyle(
                                        color: AppColors.grayIcon),
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 280,
                                child: LineChart(
                                  LineChartData(
                                    lineBarsData: chartBars,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (_) => FlLine(
                                        color: AppColors.grey,
                                        strokeWidth: 0.8,
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          interval: 1,
                                          getTitlesWidget: (val, meta) {
                                            if (val != val.roundToDouble()) {
                                              return const SizedBox();
                                            }
                                            return Text(
                                              val.toInt().toString(),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.subtitleGray),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          getTitlesWidget: (val, meta) {
                                            final idx = val.toInt();
                                            if (idx < 0 || idx >= chartXLabels.length) {
                                              return const SizedBox();
                                            }
                                            final total = chartXLabels.length;
                                            final step = (total / 5).ceil().clamp(1, total);
                                            if (idx % step != 0 && idx != total - 1) {
                                              return const SizedBox();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                chartXLabels[idx],
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.subtitleGray),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: false)),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: const Border(
                                        left: BorderSide(
                                            color: AppColors.editTextBorder),
                                        bottom: BorderSide(
                                            color: AppColors.editTextBorder),
                                      ),
                                    ),
                                    lineTouchData: LineTouchData(
                                      touchTooltipData:
                                          LineTouchTooltipData(
                                        getTooltipColor: (spot) =>
                                            Colors.blueGrey.shade800,
                                        getTooltipItems: (spots) =>
                                            spots.map((s) {
                                          final vNum = s.barIndex <
                                                  chartValveNums.length
                                              ? chartValveNums[s.barIndex]
                                              : s.barIndex + 1;
                                          final color =
                                              _valveColors[(vNum - 1) %
                                                  _valveColors.length];
                                          return LineTooltipItem(
                                            '${l10n.valve} $vNum: ${s.y.toInt()}',
                                            TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Legend
                    if (chartBars.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: chartValveNums.map((v) {
                          final color =
                              _valveColors[(v - 1) % _valveColors.length];
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${l10n.valve} $v',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 20),
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

class _ValveChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ValveChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
