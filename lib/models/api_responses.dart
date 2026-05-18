/// API response models - Matches ApiResponses.kt from the Android project.

class PistonModel {
  final int pistonNumber;
  final String state;
  final String? lastTriggered;

  const PistonModel({
    required this.pistonNumber,
    required this.state,
    this.lastTriggered,
  });

  bool get isActive => state == 'active';

  factory PistonModel.fromJson(Map<String, dynamic> json) {
    return PistonModel(
      pistonNumber: json['piston_number'] as int,
      state: json['state'] as String,
      lastTriggered: json['last_triggered'] as String?,
    );
  }

  PistonModel copyWith({String? state, String? lastTriggered}) {
    return PistonModel(
      pistonNumber: pistonNumber,
      state: state ?? this.state,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }
}

class DeviceModel {
  final String id;
  final String name;
  final String status;
  final List<PistonModel> pistons;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.status,
    required this.pistons,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final pistonsList = (json['pistons'] as List<dynamic>? ?? [])
        .map((p) => PistonModel.fromJson(p as Map<String, dynamic>))
        .toList();
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'offline',
      pistons: pistonsList,
    );
  }

  DeviceModel copyWith({String? status, List<PistonModel>? pistons}) {
    return DeviceModel(
      id: id,
      name: name,
      status: status ?? this.status,
      pistons: pistons ?? this.pistons,
    );
  }
}

class ActiveValveDisplay {
  final String deviceName;
  final String deviceId;
  final int pistonNumber;
  final String? lastTriggered;

  const ActiveValveDisplay({
    required this.deviceName,
    required this.deviceId,
    required this.pistonNumber,
    this.lastTriggered,
  });

  String get formattedTime {
    if (lastTriggered == null) return '--:--';
    try {
      final dt = DateTime.parse(lastTriggered!).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '--:--';
    }
  }
}

class AuthResponse {
  final String? token;
  final String userId;
  final String? message;

  const AuthResponse({this.token, required this.userId, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String?,
      userId: json['userId'] as String,
      message: json['message'] as String?,
    );
  }
}

class ErrorResponse {
  final String? error;
  final String? message;

  const ErrorResponse({this.error, this.message});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}
