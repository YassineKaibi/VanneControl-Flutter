import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/token_manager.dart';

class ProfileData {
  final String? avatarPath;
  final String firstName;
  final String lastName;
  final String dob;
  final String email;
  final String phone;
  final String location;
  final String valves;

  const ProfileData({
    this.avatarPath,
    this.firstName = '',
    this.lastName = '',
    this.dob = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.valves = '8',
  });
}

const _profileStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileData>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<ProfileData> {
  @override
  Future<ProfileData> build() => _load();

  Future<ProfileData> _load() async {
    final results = await Future.wait([
      _profileStorage.read(key: 'avatar_path'),
      _profileStorage.read(key: 'profile_firstName'),
      _profileStorage.read(key: 'profile_lastName'),
      _profileStorage.read(key: 'profile_dob'),
      _profileStorage.read(key: 'profile_phone'),
      _profileStorage.read(key: 'profile_location'),
      _profileStorage.read(key: 'profile_valves'),
      TokenManager.getInstance().getUserEmail(),
    ]);
    final avatarPath = results[0];
    return ProfileData(
      avatarPath: avatarPath != null && File(avatarPath).existsSync()
          ? avatarPath
          : null,
      firstName: results[1] ?? '',
      lastName: results[2] ?? '',
      dob: results[3] ?? '',
      phone: results[4] ?? '',
      location: results[5] ?? '',
      valves: results[6] ?? '8',
      email: results[7] ?? '',
    );
  }

  Future<void> save({
    String? firstName,
    String? lastName,
    String? dob,
    String? phone,
    String? location,
    String? valves,
    String? avatarPath,
  }) async {
    final current = state.valueOrNull ?? const ProfileData();
    final writes = <Future<void>>[];
    if (firstName != null) writes.add(_profileStorage.write(key: 'profile_firstName', value: firstName));
    if (lastName != null) writes.add(_profileStorage.write(key: 'profile_lastName', value: lastName));
    if (dob != null) writes.add(_profileStorage.write(key: 'profile_dob', value: dob));
    if (phone != null) writes.add(_profileStorage.write(key: 'profile_phone', value: phone));
    if (location != null) writes.add(_profileStorage.write(key: 'profile_location', value: location));
    if (valves != null) writes.add(_profileStorage.write(key: 'profile_valves', value: valves));
    if (avatarPath != null) {
      writes.add(_profileStorage.write(key: 'avatar_path', value: avatarPath));
      writes.add(_profileStorage.write(key: 'profile_avatar', value: avatarPath));
    }
    await Future.wait(writes);
    state = AsyncData(ProfileData(
      avatarPath: avatarPath ?? current.avatarPath,
      firstName: firstName ?? current.firstName,
      lastName: lastName ?? current.lastName,
      dob: dob ?? current.dob,
      phone: phone ?? current.phone,
      location: location ?? current.location,
      valves: valves ?? current.valves,
      email: current.email,
    ));
  }
}
