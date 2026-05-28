import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_responses.dart';
import '../services/api_client.dart';
import '../services/network_result.dart';

class HistoryEntry {
  final String valve;
  final String action;
  final String time;
  final String user;

  const HistoryEntry({
    required this.valve,
    required this.action,
    required this.time,
    required this.user,
  });

  Map<String, String> toMap() => {
        'valve': valve,
        'action': action,
        'time': time,
        'user': user,
      };

  factory HistoryEntry.fromMap(Map<String, dynamic> map) => HistoryEntry(
        valve: map['valve'] as String,
        action: map['action'] as String,
        time: map['time'] as String,
        user: map['user'] as String,
      );
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryEntry>>(
        HistoryNotifier.new);

class HistoryNotifier extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() async {
    return _fetchFromBackend();
  }

  Future<List<HistoryEntry>> _fetchFromBackend() async {
    final result = await ApiClient.getInstance().safeApiCall<List<HistoryEntry>>(
      () => ApiClient.getInstance().dio.get('history'),
      (data) {
        final list = (data['history'] as List<dynamic>);
        return list
            .map((e) => _mapEvent(HistoryEvent.fromJson(e as Map<String, dynamic>)))
            .toList();
      },
    );

    return switch (result) {
      Success(data: final entries) => entries,
      _ => [],
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchFromBackend());
  }

  HistoryEntry _mapEvent(HistoryEvent event) {
    final dt = DateTime.tryParse(event.timestamp)?.toLocal() ?? DateTime.now();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');

    return HistoryEntry(
      valve: 'Valve ${event.pistonNumber}',
      action: event.action == 'activated' ? 'Opened' : 'Closed',
      time: '$d/$m/${dt.year} $h:$min',
      user: '',
    );
  }
}
