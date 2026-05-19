import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vanne_control_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider).valueOrNull ?? const ProfileData();

    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      body: SafeArea(
        child: Column(
          children: [
            // Custom top bar
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
                      l10n.profileTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                    child: Text(
                      l10n.editProfile,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile header card
                    Container(
                      width: double.infinity,
                      color: AppColors.white,
                      child: Material(
                        elevation: 2,
                        color: AppColors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.grey,
                                  backgroundImage: profile.avatarPath != null
                                      ? FileImage(File(profile.avatarPath!))
                                      : null,
                                  child: profile.avatarPath == null
                                      ? SvgPicture.asset(
                                          'assets/icons/ic_avatar_placeholder.svg',
                                          width: 50,
                                          height: 50,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${profile.firstName} ${profile.lastName}'.trim().isEmpty
                                    ? '—'
                                    : '${profile.firstName} ${profile.lastName}'.trim(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.email.isEmpty ? '—' : profile.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.descriptionGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tabs row
                    Container(
                      height: 48,
                      color: AppColors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0
                                      ? AppColors.white
                                      : AppColors.tabUnselectedBg,
                                  border: _selectedTab == 0
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: AppColors.primaryGreen,
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  l10n.personalInfo,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 0
                                        ? AppColors.black
                                        : AppColors.placeholderGray,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1
                                      ? AppColors.white
                                      : AppColors.tabUnselectedBg,
                                  border: _selectedTab == 1
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: AppColors.primaryGreen,
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  l10n.system,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 1
                                        ? AppColors.black
                                        : AppColors.placeholderGray,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tab content
                    if (_selectedTab == 0) _buildPersonalInfo(l10n, profile),
                    if (_selectedTab == 1) _buildSystemInfo(l10n, profile),

                    Container(height: 32, color: AppColors.lightGrayBg),

                    // Logout button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.logout),
                                content: Text(l10n.logoutConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await logout();
                                      if (context.mounted) {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/splash',
                                          (route) => false,
                                        );
                                      }
                                    },
                                    child: Text(l10n.logout),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            l10n.logout,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(AppLocalizations l10n, ProfileData profile) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileRow('assets/icons/account_circle.svg', l10n.firstName, profile.firstName.isEmpty ? '—' : profile.firstName),
          _buildProfileRow('assets/icons/account_circle.svg', l10n.lastName, profile.lastName.isEmpty ? '—' : profile.lastName),
          _buildProfileRow('assets/icons/ic_calendar.svg', l10n.dateOfBirth, profile.dob.isEmpty ? '—' : profile.dob),
          _buildProfileRow('assets/icons/ic_email.svg', l10n.email, profile.email.isEmpty ? '—' : profile.email),
          _buildProfileRow('assets/icons/ic_phone.svg', l10n.phone, profile.phone.isEmpty ? '—' : profile.phone),
          _buildProfileRow('assets/icons/ic_location.svg', l10n.location, profile.location.isEmpty ? '—' : profile.location, showDivider: false),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String svgAsset, String label, String value,
      {bool showDivider = true}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.grayIcon,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.placeholderGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 12, bottom: 12),
            child: const Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }

  Widget _buildSystemInfo(AppLocalizations l10n, ProfileData profile) {
    final valveCount = int.tryParse(profile.valves) ?? 8;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/ic_water.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryGreen,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            l10n.valvesToManage(valveCount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
