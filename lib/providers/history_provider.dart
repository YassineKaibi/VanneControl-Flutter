import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _historyStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

const _historyKey = 'valve_history';
const _maxEntries = 200;

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
    final raw = await _historyStorage.read(key: _historyKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => HistoryEntry.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addEntry(HistoryEntry entry) async {
    final current = state.valueOrNull ?? [];
    final updated = [entry, ...current].take(_maxEntries).toList();
    state = AsyncData(updated);
    await _historyStorage.write(
      key: _historyKey,
      value: jsonEncode(updated.map((e) => e.toMap()).toList()),
    );
  }
}
