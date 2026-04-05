import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_alerts.dart';
import '../../auth/models/me_response.dart';
import '../../auth/viewmodels/login_view_model.dart';
import '../viewmodels/profile_view_model.dart';

const _modalPrimaryBlue = Color(0xFF636AE8);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.meData});

  final MeData meData;

  @override
  Widget build(BuildContext context) {
    final currentData =
        context.select<LoginViewModel, MeData?>((vm) => vm.meData) ?? meData;
    final gymCount = currentData.gyms.length;
    final defaultGym = _resolveDefaultGymName(currentData);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Profil',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            _ProfileHeaderCard(
              title: currentData.user.name,
              email: currentData.user.email,
              role: currentData.user.role,
              imageUrl: currentData.user.profileImage,
              initial: _resolveInitial(currentData.user.name),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Gym Terdaftar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  '$gymCount',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF6366F1), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      defaultGym,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _onEditProfilePressed(context, currentData),
                icon: const Icon(Icons.edit_rounded),
                label: const Text(
                  'Edit Profil',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _onLogoutPressed(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveInitial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'P';
    }
    return trimmed.characters.first.toUpperCase();
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah kamu yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ya, Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final loginViewModel = context.read<LoginViewModel>();

    try {
      await loginViewModel.logout();
      if (!context.mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      AppAlerts.showError(context, 'Gagal logout, coba lagi.');
    }
  }

  Future<void> _onEditProfilePressed(BuildContext context, MeData data) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFF5F6FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _EditProfileSheet(initialData: data);
      },
    );

    if (updated == true && context.mounted) {
      AppAlerts.showSuccess(context, 'Profil berhasil diperbarui');
    }
  }

  String _resolveDefaultGymName(MeData data) {
    if (data.gyms.isEmpty) {
      return 'Belum terdaftar di gym';
    }

    final matched = data.gyms.where((gym) => gym.id == data.defaultGymId);

    if (matched.isNotEmpty) {
      return matched.first.name;
    }

    return data.gyms.first.name;
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.title,
    required this.email,
    required this.role,
    required this.imageUrl,
    required this.initial,
  });

  final String title;
  final String email;
  final String role;
  final String? imageUrl;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF636AE8), Color(0xFF7C5CFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF636AE8).withValues(alpha: 0.25),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Avatar(imageUrl: imageUrl, initial: initial, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RolePill(role: role),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.imageUrl,
    required this.initial,
    required this.size,
  });

  final String? imageUrl;
  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl ?? '').trim();
    final hasImage = url.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(2.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: hasImage
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return Container(
                    color: Colors.white.withValues(alpha: 0.10),
                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.10),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final value = role.isEmpty ? 'PENJAGA' : role.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.initialData});

  final MeData initialData;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _usernameController;
  late final TextEditingController _nameController;

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.initialData.user.username,
    );
    _nameController = TextEditingController(text: widget.initialData.user.name);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1280,
    );

    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _pickedImage = picked;
      _pickedImageBytes = bytes;
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final profileViewModel = context.read<ProfileViewModel>();
    final loginViewModel = context.read<LoginViewModel>();

    final updatedData = await profileViewModel.updateProfile(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      imagePath: _pickedImage?.path,
    );

    if (!mounted) {
      return;
    }

    if (updatedData != null) {
      loginViewModel.setMeData(updatedData);
      Navigator.pop(context, true);
      return;
    }

    final message =
        profileViewModel.errorMessage ?? 'Gagal memperbarui profil, coba lagi.';
    AppAlerts.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Consumer2<LoginViewModel, ProfileViewModel>(
        builder: (context, _, profileViewModel, child) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _modalPrimaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _modalPrimaryBlue,
                              width: 1.2,
                            ),
                          ),
                          child: ClipOval(child: _buildImagePreview()),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: profileViewModel.isUpdating
                              ? null
                              : _pickImageFromGallery,
                          style: TextButton.styleFrom(
                            foregroundColor: _modalPrimaryBlue,
                          ),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Pilih dari Gallery'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _modalPrimaryBlue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _modalPrimaryBlue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _modalPrimaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: profileViewModel.isUpdating ? null : _submit,
                      child: profileViewModel.isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  if (profileViewModel.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      profileViewModel.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedImageBytes != null) {
      return Image.memory(_pickedImageBytes!, fit: BoxFit.cover);
    }

    final imageUrl = widget.initialData.user.profileImage.trim();
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackPreview(),
      );
    }

    return _fallbackPreview();
  }

  Widget _fallbackPreview() {
    return Container(
      color: const Color(0xFFEFF1F5),
      child: const Icon(Icons.person, size: 38, color: Colors.grey),
    );
  }
}
