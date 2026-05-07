import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_alerts.dart';
import '../models/gym_detail_response.dart';
import '../viewmodels/status_gym_view_model.dart';

class GymEditPage extends StatefulWidget {
  const GymEditPage({super.key, required this.gym});

  final GymDetail gym;

  @override
  State<GymEditPage> createState() => _GymEditPageState();
}

class _GymEditPageState extends State<GymEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _maxCapacityController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _facilityController;
  late final TextEditingController _tagController;
  late final List<_DaySchedule> _schedules;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gym.name);
    _maxCapacityController = TextEditingController(
      text: widget.gym.maxCapacity.toString(),
    );
    _addressController = TextEditingController(text: widget.gym.address);
    _descriptionController = TextEditingController(
      text: widget.gym.description,
    );
    _facilityController = TextEditingController(
      text: widget.gym.facility.join(', '),
    );
    _tagController = TextEditingController(text: widget.gym.tag);
    _schedules = _buildSchedules(widget.gym.jamOperasional);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxCapacityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _facilityController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  List<String> _parseFacility(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _onSave() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final jamOperasional = _buildOperationalText();
    if (jamOperasional.isEmpty) {
      AppAlerts.showError(context, 'Jam operasional belum diisi.');
      return;
    }

    final maxCapacity = int.tryParse(_maxCapacityController.text.trim());
    if (maxCapacity == null || maxCapacity <= 0) {
      AppAlerts.showError(context, 'Kapasitas harus berupa angka valid.');
      return;
    }

    final viewModel = context.read<StatusGymViewModel>();
    final updated = await viewModel.updateGym(
      gymId: widget.gym.id,
      name: _nameController.text.trim(),
      maxCapacity: maxCapacity,
      address: _addressController.text.trim(),
      jamOperasional: jamOperasional,
      description: _descriptionController.text.trim(),
      facility: _parseFacility(_facilityController.text),
      tag: _tagController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (updated != null) {
      Navigator.pop(context, true);
      return;
    }

    final message = viewModel.errorMessage ?? 'Gagal memperbarui data gym.';
    AppAlerts.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = context.select<StatusGymViewModel, bool>(
      (vm) => vm.isUpdating,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Gym'),
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
                  label: 'Nama Gym',
                  controller: _nameController,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Kapasitas Maksimal',
                  controller: _maxCapacityController,
                  keyboardType: TextInputType.number,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Alamat',
                  controller: _addressController,
                  maxLines: 2,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _OperationalSection(
                  schedules: _schedules,
                  onToggle: _toggleDay,
                  onPickStart: (schedule) => _pickTime(schedule, true),
                  onPickEnd: (schedule) => _pickTime(schedule, false),
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Deskripsi',
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Fasilitas (pisahkan dengan koma)',
                  controller: _facilityController,
                  maxLines: 2,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                _InputField(
                  label: 'Tag',
                  controller: _tagController,
                  validator: _requiredValidator,
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

  List<_DaySchedule> _buildSchedules(String raw) {
    final schedules = _dayNames
        .map(
          (day) => _DaySchedule(
            day: day,
            isOpen: false,
            openTime: _defaultOpenTime(day),
            closeTime: _defaultCloseTime(day),
          ),
        )
        .toList();

    if (raw.trim().isEmpty) {
      return schedules;
    }

    final byDay = {for (final item in schedules) item.day: item};
    final entries = raw.split(',');

    for (final entry in entries) {
      final trimmed = entry.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final colonIndex = trimmed.indexOf(':');
      if (colonIndex <= 0) {
        continue;
      }

      final day = trimmed.substring(0, colonIndex).trim();
      final schedule = byDay[day];
      if (schedule == null) {
        continue;
      }

      final timePart = trimmed.substring(colonIndex + 1).trim();
      if (timePart.toLowerCase().contains('tutup')) {
        schedule.isOpen = false;
        continue;
      }

      final range = timePart.split('-');
      if (range.length < 2) {
        continue;
      }

      final openTime = _parseTime(range[0]);
      final closeTime = _parseTime(range[1]);
      if (openTime == null || closeTime == null) {
        continue;
      }

      schedule.isOpen = true;
      schedule.openTime = openTime;
      schedule.closeTime = closeTime;
    }

    return schedules;
  }

  void _toggleDay(_DaySchedule schedule, bool? value) {
    if (value == null) {
      return;
    }

    setState(() {
      schedule.isOpen = value;
    });
  }

  Future<void> _pickTime(_DaySchedule schedule, bool isStart) async {
    if (!schedule.isOpen) {
      return;
    }

    final initial = isStart ? schedule.openTime : schedule.closeTime;
    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStart) {
        schedule.openTime = picked;
      } else {
        schedule.closeTime = picked;
      }
    });
  }

  String _buildOperationalText() {
    final items = <String>[];

    for (final schedule in _schedules) {
      if (!schedule.isOpen) {
        continue;
      }

      items.add(
        '${schedule.day}: ${_formatTime24(schedule.openTime)} - ${_formatTime24(schedule.closeTime)}',
      );
    }

    return items.join(', ');
  }

  TimeOfDay? _parseTime(String value) {
    final trimmed = value.trim();
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*([AP]M))?$',
      caseSensitive: false,
    ).firstMatch(trimmed);

    if (match == null) {
      return null;
    }

    var hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final period = match.group(3)?.toUpperCase();

    if (hour == null || minute == null) {
      return null;
    }

    if (period == 'PM' && hour < 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay _defaultOpenTime(String day) {
    if (day == 'Sabtu') {
      return const TimeOfDay(hour: 8, minute: 0);
    }

    return const TimeOfDay(hour: 12, minute: 0);
  }

  TimeOfDay _defaultCloseTime(String day) {
    if (day == 'Sabtu') {
      return const TimeOfDay(hour: 13, minute: 0);
    }

    return const TimeOfDay(hour: 20, minute: 0);
  }
}

const _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

class _DaySchedule {
  _DaySchedule({
    required this.day,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });

  final String day;
  bool isOpen;
  TimeOfDay openTime;
  TimeOfDay closeTime;
}

class _OperationalSection extends StatelessWidget {
  const _OperationalSection({
    required this.schedules,
    required this.onToggle,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final List<_DaySchedule> schedules;
  final void Function(_DaySchedule schedule, bool? value) onToggle;
  final void Function(_DaySchedule schedule) onPickStart;
  final void Function(_DaySchedule schedule) onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jam Operasional',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE1E4EC)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < schedules.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE1E4EC),
                  ),
                _OperationalRow(
                  schedule: schedules[i],
                  onToggle: onToggle,
                  onPickStart: onPickStart,
                  onPickEnd: onPickEnd,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OperationalRow extends StatelessWidget {
  const _OperationalRow({
    required this.schedule,
    required this.onToggle,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final _DaySchedule schedule;
  final void Function(_DaySchedule schedule, bool? value) onToggle;
  final void Function(_DaySchedule schedule) onPickStart;
  final void Function(_DaySchedule schedule) onPickEnd;

  @override
  Widget build(BuildContext context) {
    final timeLabel = _formatTimeLabel(context, schedule.openTime);
    final closeLabel = _formatTimeLabel(context, schedule.closeTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Checkbox(
            value: schedule.isOpen,
            onChanged: (value) => onToggle(schedule, value),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
            child: Text(
              schedule.day,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: schedule.isOpen
                ? Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          label: timeLabel,
                          onTap: () => onPickStart(schedule),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('-', style: TextStyle(color: Colors.black54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TimeField(
                          label: closeLabel,
                          onTap: () => onPickEnd(schedule),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTimeLabel(BuildContext context, TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCAD1DD)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.access_time, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      enabled: enabled,
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
