import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_alerts.dart';
import '../viewmodels/status_gym_view_model.dart';

class GymEquipmentCreatePage extends StatefulWidget {
  const GymEquipmentCreatePage({super.key, required this.gymId});

  final int gymId;

  @override
  State<GymEquipmentCreatePage> createState() => _GymEquipmentCreatePageState();
}

class _GymEquipmentCreatePageState extends State<GymEquipmentCreatePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _videoUrlController;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _jumlahController = TextEditingController();
    _descriptionController = TextEditingController();
    _videoUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jumlahController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
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

  Future<void> _onSave() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final jumlah = int.tryParse(_jumlahController.text.trim());
    if (jumlah == null || jumlah <= 0) {
      AppAlerts.showError(context, 'Jumlah harus berupa angka valid.');
      return;
    }

    final viewModel = context.read<StatusGymViewModel>();
    final created = await viewModel.createEquipment(
      gymId: widget.gymId,
      name: _nameController.text.trim(),
      jumlah: jumlah,
      description: _descriptionController.text.trim(),
      videoUrl: _videoUrlController.text.trim(),
      imagePath: _pickedImage?.path,
    );

    if (!mounted) {
      return;
    }

    if (created != null) {
      Navigator.pop(context, true);
      return;
    }

    final message = viewModel.errorMessage ?? 'Gagal menambah alat gym.';
    AppAlerts.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = context.select<StatusGymViewModel, bool>(
      (vm) => vm.isUpdatingEquipment,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Alat Gym'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InputField(
                  label: 'Nama Alat',
                  controller: _nameController,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Jumlah',
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Deskripsi',
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Foto Alat',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PhotoPreview(bytes: _pickedImageBytes),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isUpdating ? null : _pickImageFromGallery,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Pilih Foto'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Video URL',
                  controller: _videoUrlController,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isUpdating
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.bytes});

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 84,
        height: 84,
        color: const Color(0xFFF1F3F6),
        child: bytes == null
            ? const Icon(Icons.image_outlined, color: Colors.grey)
            : Image.memory(bytes!, fit: BoxFit.cover),
      ),
    );
  }
}
