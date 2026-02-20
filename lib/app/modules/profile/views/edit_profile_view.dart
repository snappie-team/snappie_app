import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/helpers/app_snackbar.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/error_handler.dart';
import '../controllers/profile_controller.dart';

/// Edit Profile page – simple form to update basic user info.
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final ProfileController _profileController;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _usernameCtrl;
  String _gender = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _profileController = Get.find<ProfileController>();
    final user = _profileController.userData;
    final nameParts = _splitName(user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _firstNameCtrl = TextEditingController(text: nameParts.$1);
    _lastNameCtrl = TextEditingController(text: nameParts.$2);
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _gender = (user?.userDetail?.gender ?? '').toLowerCase();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(title: 'Info Personal', slivers: [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email field (read-only)
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailCtrl,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Email dari akun Google',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // First Name and Last Name Row
                const Text(
                  'Nama Lengkap',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstNameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Nama Depan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _lastNameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Nama Belakang',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gender Selection
                const Text(
                  'Jenis Kelamin',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => setState(() => _gender = 'male'),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'male',
                            groupValue: _gender,
                            onChanged: (val) =>
                                setState(() => _gender = val ?? ''),
                          ),
                          const Text('Laki-laki'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => setState(() => _gender = 'female'),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'female',
                            groupValue: _gender,
                            onChanged: (val) =>
                                setState(() => _gender = val ?? ''),
                          ),
                          const Text('Perempuan'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Username field
                const Text(
                  'Nama Pengguna',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Minimal 8 kata dan mengandung karakter atau angka',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  enabled: false,
                  controller: _usernameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Contoh: marissa.ana_',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    ]);
  }

  Future<void> _onSave() async {
    final username = _usernameCtrl.text.trim();
    // if (username.length < 8) {
    //   Get.snackbar('Validasi', 'Nama pengguna minimal 8 karakter', snackPosition: SnackPosition.BOTTOM);
    //   return;
    // }

    final fullName =
        _buildFullName(_firstNameCtrl.text.trim(), _lastNameCtrl.text.trim());

    setState(() => _saving = true);
    try {
      await _profileController.userRepository.updateUserProfile(
        name: fullName.isNotEmpty ? fullName : null,
        gender: _gender.isNotEmpty ? _gender : null,
        username: username.isNotEmpty ? username : null,
      );
      await _profileController.loadUserProfile();
      AppSnackbar.success('Profil diperbarui');
      Get.back();
    } catch (e) {
      AppSnackbar.error(
          ErrorHandler.getReadableMessage(e, tag: 'EditProfileView'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  (String, String) _splitName(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return ('', '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  String _buildFullName(String first, String last) {
    if (first.isEmpty && last.isEmpty) return '';
    if (last.isEmpty) return first;
    if (first.isEmpty) return last;
    return '$first $last';
  }
}
