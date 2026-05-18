import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

class ScheduleEntry {
  final String id;
  final String name;
  final String deviceId;
  final int pistonNumber;
  final String action; // ACTIVATE | DEACTIVATE
  final String cronExpression;
  final bool enabled;

  const ScheduleEntry({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.pistonNumber,
    required this.action,
    required this.cronExpression,
    required this.enabled,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceId: json['deviceId'] as String,
      pistonNumber: json['pistonNumber'] as int,
      action: json['action'] as String,
      cronExpression: json['cronExpression'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  String get formattedTime {
    // Parse cron: 0 {min} {hour} ...
    try {
      final parts = cronExpression.split(' ');
      if (parts.length >= 3) {
        final h = parts[2].padLeft(2, '0');
        final m = parts[1].padLeft(2, '0');
        return '$h:$m';
      }
    } catch (_) {}
    return '--:--';
  }
}

class SchedulePlan {
  final ScheduleEntry? activateEntry;
  final ScheduleEntry? deactivateEntry;

  const SchedulePlan({this.activateEntry, this.deactivateEntry});

  String get name => activateEntry?.name ?? deactivateEntry?.name ?? '';
  int get pistonNumber => activateEntry?.pistonNumber ?? deactivateEntry?.pistonNumber ?? 0;
  String get deviceId => activateEntry?.deviceId ?? deactivateEntry?.deviceId ?? '';
  bool get enabled => activateEntry?.enabled ?? deactivateEntry?.enabled ?? false;
  String get onTime => activateEntry?.formattedTime ?? '--:--';
  String get offTime => deactivateEntry?.formattedTime ?? '--:--';

  String get repeatText {
    final cron = activateEntry?.cronExpression ?? deactivateEntry?.cronExpression ?? '';
    final parts = cron.split(' ');
    if (parts.length < 6) return '';
    final dayOfWeek = parts.length > 5 ? parts[5] : '*';
    if (dayOfWeek == '*' || dayOfWeek == '?') return 'Everyday';
    if (dayOfWeek == 'MON-FRI' || dayOfWeek == 'MON,TUE,WED,THU,FRI' || dayOfWeek == '2-6') return 'Weekdays';
    if (dayOfWeek == 'SAT,SUN' || dayOfWeek == '1,7' || dayOfWeek == '6,7') return 'Weekends';
    return 'Once';
  }
}

class ScheduleState {
  final bool isLoading;
  final String? error;
  final List<SchedulePlan> plans;

  const ScheduleState({
    this.isLoading = true,
    this.error,
    this.plans = const [],
  });
}

String buildCron(int hour, int minute, String repeat, {DateTime? onceDate}) {
  // Convert local time to UTC for server-side cron execution
  final baseDate = onceDate ?? DateTime.now();
  final local = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  final utc = local.toUtc();
  final h = utc.hour;
  final m = utc.minute;

  switch (repeat) {
    case 'Everyday':
      return '0 $m $h * * ?';
    case 'Weekdays':
      return '0 $m $h ? * MON,TUE,WED,THU,FRI';
    case 'Weekends':
      return '0 $m $h ? * SAT,SUN';
    default: // Once
      return '0 $m $h ${utc.day} ${utc.month} ? ${utc.year}';
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final _api = ApiClient.getInstance();

  ScheduleNotifier() : super(const ScheduleState()) {
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    try {
      state = const ScheduleState(isLoading: true);
      final resp = await _api.dio.get('schedules');
      final entries = (resp.data['schedules'] as List<dynamic>)
          .map((s) => ScheduleEntry.fromJson(s as Map<String, dynamic>))
          .toList();

      // Group by name into plans
      final Map<String, SchedulePlan> planMap = {};
      for (final entry in entries) {
        final existing = planMap[entry.name];
        if (entry.action == 'ACTIVATE') {
          planMap[entry.name] = SchedulePlan(
            activateEntry: entry,
            deactivateEntry: existing?.deactivateEntry,
          );
        } else {
          planMap[entry.name] = SchedulePlan(
            activateEntry: existing?.activateEntry,
            deactivateEntry: entry,
          );
        }
      }

      state = ScheduleState(isLoading: false, plans: planMap.values.toList());
    } catch (e) {
      state = ScheduleState(isLoading: false, error: e.toString());
    }
  }

  Future<String?> addSchedule({
    required String name,
    required String deviceId,
    required int pistonNumber,
    required int? onHour,
    required int? onMinute,
    required int? offHour,
    required int? offMinute,
    required String repeat,
    DateTime? onceDate,
  }) async {
    try {
      final futures = <Future>[];
      if (onHour != null && onMinute != null) {
        futures.add(_api.dio.post('schedules', data: {
          'name': name,
          'deviceId': deviceId,
          'pistonNumber': pistonNumber,
          'action': 'ACTIVATE',
          'cronExpression': buildCron(onHour, onMinute, repeat, onceDate: onceDate),
          'enabled': true,
        }));
      }
      if (offHour != null && offMinute != null) {
        futures.add(_api.dio.post('schedules', data: {
          'name': name,
          'deviceId': deviceId,
          'pistonNumber': pistonNumber,
          'action': 'DEACTIVATE',
          'cronExpression': buildCron(offHour, offMinute, repeat, onceDate: onceDate),
          'enabled': true,
        }));
      }
      await Future.wait(futures);
      await fetchSchedules();
      return null; // success
    } catch (e) {
      await fetchSchedules();
      return e.toString(); // return error message
    }
  }

  Future<void> togglePlan(SchedulePlan plan, bool enabled) async {
    try {
      final futures = <Future>[];
      if (plan.activateEntry != null) {
        futures.add(_api.dio.patch(
          'schedules/${plan.activateEntry!.id}',
          data: {'enabled': enabled},
        ));
      }
      if (plan.deactivateEntry != null) {
        futures.add(_api.dio.patch(
          'schedules/${plan.deactivateEntry!.id}',
          data: {'enabled': enabled},
        ));
      }
      await Future.wait(futures);
      await fetchSchedules();
    } catch (_) {}
  }

  Future<void> deletePlan(SchedulePlan plan) async {
    try {
      final futures = <Future>[];
      if (plan.activateEntry != null) {
        futures.add(_api.dio.delete('schedules/${plan.activateEntry!.id}'));
      }
      if (plan.deactivateEntry != null) {
        futures.add(_api.dio.delete('schedules/${plan.deactivateEntry!.id}'));
      }
      await Future.wait(futures);
      await fetchSchedules();
    } catch (_) {}
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  return ScheduleNotifier();
});
