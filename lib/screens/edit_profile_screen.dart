import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/token_manager.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _avatarPath;
  bool _isSaving = false;
  final _storage = const FlutterSecureStorage();
  final _picker = ImagePicker();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _valvesCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _dobCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _valvesCtrl = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    final tokenManager = TokenManager.getInstance();
    final results = await Future.wait([
      _storage.read(key: 'avatar_path'),
      _storage.read(key: 'profile_firstName'),
      _storage.read(key: 'profile_lastName'),
      _storage.read(key: 'profile_dob'),
      _storage.read(key: 'profile_phone'),
      _storage.read(key: 'profile_location'),
      _storage.read(key: 'profile_valves'),
      tokenManager.getUserEmail(),
    ]);

    final avatarPath = results[0];
    setState(() {
      if (avatarPath != null && File(avatarPath).existsSync()) _avatarPath = avatarPath;
      _firstNameCtrl.text = results[1] ?? '';
      _lastNameCtrl.text = results[2] ?? '';
      _dobCtrl.text = results[3] ?? '';
      _phoneCtrl.text = results[4] ?? '';
      _locationCtrl.text = results[5] ?? '';
      _valvesCtrl.text = results[6] ?? '8';
      _emailCtrl.text = results[7] ?? '';
    });
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() => _isSaving = true);
    await Future.wait([
      _storage.write(key: 'profile_firstName', value: _firstNameCtrl.text.trim()),
      _storage.write(key: 'profile_lastName', value: _lastNameCtrl.text.trim()),
      _storage.write(key: 'profile_dob', value: _dobCtrl.text.trim()),
      _storage.write(key: 'profile_phone', value: _phoneCtrl.text.trim()),
      _storage.write(key: 'profile_location', value: _locationCtrl.text.trim()),
      _storage.write(key: 'profile_valves', value: _valvesCtrl.text.trim()),
    ]);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaved)),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/avatar.jpg';
    await File(picked.path).copy(dest);
    await _storage.write(key: 'avatar_path', value: dest);
    await _storage.write(key: 'profile_avatar', value: dest);
    if (mounted) setState(() => _avatarPath = dest);
  }

  void _showImageSourceSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryGreen),
              title: Text(l10n.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _valvesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.white,
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
                  Expanded(
                    child: Text(
                      l10n.editProfile,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black),
                    ),
                  ),
                  _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : GestureDetector(
                          onTap: () => _save(l10n),
                          child: Text(
                            l10n.save,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showImageSourceSheet(l10n),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: AppColors.grey,
                                      backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                                      child: _avatarPath == null
                                          ? SvgPicture.asset('assets/icons/ic_avatar_placeholder.svg', width: 60, height: 60)
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(7),
                                          child: SvgPicture.asset(
                                            'assets/icons/ic_camera.svg',
                                            width: 18,
                                            height: 18,
                                            colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _showImageSourceSheet(l10n),
                                child: Text(
                                  l10n.changeProfilePhoto,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Personal Information
                    Text(l10n.personalInformation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildTextField(l10n.firstName, _firstNameCtrl),
                            const SizedBox(height: 16),
                            _buildTextField(l10n.lastName, _lastNameCtrl),
                            const SizedBox(height: 16),
                            _buildTextField(l10n.dateOfBirth, _dobCtrl),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact Information
                    Text(l10n.contactInformation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildTextField(l10n.email, _emailCtrl, enabled: false),
                            const SizedBox(height: 16),
                            _buildTextField(l10n.phone, _phoneCtrl, keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            _buildTextField(l10n.location, _locationCtrl),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Valve Settings
                    Text(l10n.valveSettings, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildTextField(l10n.numberOfValves, _valvesCtrl, keyboardType: TextInputType.number),
                      ),
                    ),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primaryGreen, fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.grayDisabled, width: 1),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: TextStyle(fontSize: 16, color: enabled ? AppColors.black : AppColors.grayIcon),
    );
  }
}
