import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_responses.dart';
import '../services/api_client.dart';
import '../services/token_manager.dart';
import '../services/websocket_service.dart';

class ValveState {
  final bool isLoading;
  final String? error;
  final List<DeviceModel> devices;

  const ValveState({
    this.isLoading = true,
    this.error,
    this.devices = const [],
  });

  List<ActiveValveDisplay> get activeValves => devices
      .expand((d) => d.pistons
          .where((p) => p.isActive)
          .map((p) => ActiveValveDisplay(
                deviceName: d.name,
                deviceId: d.id,
                pistonNumber: p.pistonNumber,
                lastTriggered: p.lastTriggered,
              )))
      .toList();
}

class ValveNotifier extends StateNotifier<ValveState> {
  final _apiClient = ApiClient.getInstance();
  final _tokenManager = TokenManager.getInstance();
  final _wsService = WebSocketService();
  StreamSubscription? _wsSub;

  ValveNotifier() : super(const ValveState()) {
    _init();
  }

  Future<void> _init() async {
    await _fetchDevicesAndPistons();
    await _connectWebSocket();
  }

  Future<void> _fetchDevicesAndPistons() async {
    try {
      // Fetch devices
      final devResp = await _apiClient.dio.get('devices');
      final deviceList = (devResp.data['devices'] as List<dynamic>)
          .map((d) => DeviceModel.fromJson(d as Map<String, dynamic>))
          .toList();

      // Fetch pistons for each device
      final devicesWithPistons = await Future.wait(
        deviceList.map((device) async {
          try {
            final pResp = await _apiClient.dio.get('devices/${device.id}/pistons');
            final pistons = (pResp.data as List<dynamic>)
                .map((p) => PistonModel.fromJson(p as Map<String, dynamic>))
                .toList();
            return device.copyWith(pistons: pistons);
          } catch (_) {
            return device;
          }
        }),
      );

      if (mounted) {
        state = ValveState(isLoading: false, devices: devicesWithPistons);
      }
    } catch (e) {
      if (mounted) {
        state = ValveState(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> _connectWebSocket() async {
    final token = await _tokenManager.getToken();
    if (token == null) return;

    await _wsService.connect(token);

    // Subscribe to all devices
    for (final device in state.devices) {
      _wsService.subscribeToDevice(device.id);
    }

    _wsSub = _wsService.messages?.listen((msg) {
      if (msg.type == 'piston_update') {
        _handlePistonUpdate(msg.data);
      } else if (msg.type == 'device_status') {
        _handleDeviceStatus(msg.data);
      }
    });
  }

  void _handlePistonUpdate(Map<String, dynamic> data) {
    final deviceId = data['device_id'] as String?;
    final pistonNumber = data['piston_number'] as int?;
    final newState = data['state'] as String?;
    final timestamp = data['timestamp'];

    if (deviceId == null || pistonNumber == null || newState == null) return;

    String? lastTriggered;
    if (timestamp != null) {
      lastTriggered = DateTime.fromMillisecondsSinceEpoch(
        timestamp is int ? timestamp : (timestamp as double).toInt(),
      ).toIso8601String();
    }

    final newDevices = state.devices.map((device) {
      if (device.id != deviceId) return device;
      final newPistons = device.pistons.map((p) {
        if (p.pistonNumber != pistonNumber) return p;
        return p.copyWith(state: newState, lastTriggered: lastTriggered);
      }).toList();
      return device.copyWith(pistons: newPistons);
    }).toList();

    if (mounted) state = ValveState(isLoading: false, devices: newDevices);
  }

  void _handleDeviceStatus(Map<String, dynamic> data) {
    final deviceId = data['device_id'] as String?;
    final status = data['status'] as String?;
    if (deviceId == null || status == null) return;

    final newDevices = state.devices.map((device) {
      if (device.id != deviceId) return device;
      return device.copyWith(status: status);
    }).toList();

    if (mounted) state = ValveState(isLoading: false, devices: newDevices);
  }

  Future<void> togglePiston(String deviceId, int pistonNumber, bool currentlyActive) async {
    final action = currentlyActive ? 'deactivate' : 'activate';
    try {
      await _apiClient.dio.post(
        'devices/$deviceId/pistons/$pistonNumber',
        data: {'action': action, 'piston_number': pistonNumber},
      );
      // Optimistic update while waiting for WebSocket confirmation
      _handlePistonUpdate({
        'device_id': deviceId,
        'piston_number': pistonNumber,
        'state': currentlyActive ? 'inactive' : 'active',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Future<void> refresh() async {
    state = const ValveState(isLoading: true);
    await _fetchDevicesAndPistons();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _wsService.dispose();
    super.dispose();
  }
}

final valveProvider = StateNotifierProvider<ValveNotifier, ValveState>((ref) {
  return ValveNotifier();
});
