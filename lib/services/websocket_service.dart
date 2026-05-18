import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'constants.dart';

class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;

  const WebSocketMessage({required this.type, required this.data});
}

class WebSocketService {
  WebSocket? _socket;
  StreamController<WebSocketMessage>? _controller;
  bool _disposed = false;

  Stream<WebSocketMessage>? get messages => _controller?.stream;

  Future<void> connect(String token) async {
    _controller = StreamController<WebSocketMessage>.broadcast();
    try {
      _socket = await WebSocket.connect(
        Constants.websocketUrl,
        headers: {'Authorization': '${Constants.bearerPrefix}$token'},
      ).timeout(const Duration(seconds: 10));

      _socket!.listen(
        (data) {
          if (_disposed) return;
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            final type = json['type'] as String? ?? '';
            _controller?.add(WebSocketMessage(type: type, data: json));
          } catch (_) {}
        },
        onDone: () => _controller?.close(),
        onError: (_) => _controller?.close(),
        cancelOnError: false,
      );
    } catch (e) {
      _controller?.addError(e);
    }
  }

  void subscribeToDevice(String deviceId) {
    _send({'type': 'subscribe', 'device_id': deviceId});
  }

  void _send(Map<String, dynamic> message) {
    if (_socket?.readyState == WebSocket.open) {
      _socket!.add(jsonEncode(message));
    }
  }

  void dispose() {
    _disposed = true;
    _socket?.close();
    _controller?.close();
  }
}
