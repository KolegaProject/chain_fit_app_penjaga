import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_alerts.dart';
import '../../auth/models/me_response.dart';
import '../../auth/viewmodels/login_view_model.dart';
import '../../dashboard/models/attendance_response.dart';
import '../../dashboard/viewmodels/dashboard_view_model.dart';
import '../../gym/models/gym_equipment_response.dart';

const _primaryColor = Color(0xFF6366F1);

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.meData});

  final MeData meData;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _loadedGymId;
  final TextEditingController _equipmentSearchController =
      TextEditingController();
  String _equipmentStatusFilter = _statusFilterAll;

  @override
  void dispose() {
    _equipmentSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loginViewModel = Provider.of<LoginViewModel>(context);
    final gymId = _resolveGymId(loginViewModel.meData);

    if (_loadedGymId != gymId) {
      _loadedGymId = gymId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        final viewModel = context.read<DashboardViewModel>();
        if (gymId == null) {
          viewModel.clearDashboard();
          return;
        }

        viewModel.loadDashboard(gymId);
      });
    }
  }

  int? _resolveGymId(MeData? data) {
    if (data == null) {
      return null;
    }

    final defaultId = data.defaultGymId;
    if (defaultId != null && defaultId > 0) {
      return defaultId;
    }

    if (data.gyms.isNotEmpty) {
      return data.gyms.first.id;
    }

    return null;
  }

  List<GymEquipment> _filterProblemEquipment(List<GymEquipment> items) {
    final query = _equipmentSearchController.text.trim().toLowerCase();
    final filter = _equipmentStatusFilter;

    return items.where((equipment) {
      final matchesQuery =
          query.isEmpty || equipment.name.toLowerCase().contains(query);
      if (!matchesQuery) {
        return false;
      }

      if (filter == _statusFilterAll) {
        return true;
      }

      return equipment.healthStatus.toUpperCase() == filter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentData =
        context.select<LoginViewModel, MeData?>((vm) => vm.meData) ??
        widget.meData;

    return SafeArea(
      child: Consumer<DashboardViewModel>(
        builder: (context, viewModel, _) {
          final filteredEquipment = _filterProblemEquipment(
            viewModel.problemEquipment,
          );

          return RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFE8EAFF),
                      backgroundImage: currentData.user.profileImage.isNotEmpty
                          ? NetworkImage(currentData.user.profileImage)
                          : null,
                      child: currentData.user.profileImage.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.grey.shade600,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${currentData.user.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Selamat bertugas hari ini!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (viewModel.errorMessage != null)
                  _InlineError(message: viewModel.errorMessage!),
                const SizedBox(height: 12),
                const _SectionTitle(title: 'Member di Gym'),
                const SizedBox(height: 10),
                if (viewModel.isLoading && viewModel.activeAttendances.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(color: _primaryColor),
                    ),
                  )
                else if (viewModel.activeAttendances.isEmpty)
                  const _EmptyAttendance()
                else
                  ...viewModel.activeAttendances.map(
                    (attendance) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AttendanceCard(
                        attendance: attendance,
                        isCheckingOut: viewModel.isCheckingOut(attendance.id),
                        onCheckout: () async {
                          final message = await viewModel.checkOut(attendance);
                          if (!context.mounted) {
                            return;
                          }

                          if (message != null) {
                            AppAlerts.showSuccess(context, message);
                          } else if (viewModel.errorMessage != null) {
                            AppAlerts.showError(
                              context,
                              viewModel.errorMessage!,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                const _SectionTitle(title: 'Peralatan Bermasalah'),
                const SizedBox(height: 10),
                _ProblemEquipmentToolbar(
                  controller: _equipmentSearchController,
                  filterLabel: _statusFilterLabel(_equipmentStatusFilter),
                  onSearchChanged: (_) {
                    setState(() {});
                  },
                  onFilterSelected: (value) {
                    setState(() {
                      _equipmentStatusFilter = value;
                    });
                  },
                ),
                const SizedBox(height: 6),
                if (viewModel.isLoading && viewModel.problemEquipment.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(color: _primaryColor),
                    ),
                  )
                else if (viewModel.problemEquipment.isEmpty)
                  const _EmptyEquipment()
                else if (filteredEquipment.isEmpty)
                  const _EmptyFilteredEquipment()
                else
                  ...filteredEquipment.map(
                    (equipment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EquipmentCard(equipment: equipment),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

class _ProblemEquipmentToolbar extends StatelessWidget {
  const _ProblemEquipmentToolbar({
    required this.controller,
    required this.filterLabel,
    required this.onSearchChanged,
    required this.onFilterSelected,
  });

  final TextEditingController controller;
  final String filterLabel;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari alat bermasalah...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                borderSide: const BorderSide(color: _primaryColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        PopupMenuButton<String>(
          onSelected: onFilterSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: _statusFilterAll,
              child: Text('Semua Status'),
            ),
            const PopupMenuItem(value: 'BAIK', child: Text('BAIK')),
            const PopupMenuItem(
              value: 'BUTUH_PERAWATAN',
              child: Text('BUTUH PERAWATAN'),
            ),
            const PopupMenuItem(value: 'RUSAK', child: Text('RUSAK')),
          ],
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE1E4EC)),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, size: 18),
                const SizedBox(width: 6),
                Text(
                  filterLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.attendance,
    required this.isCheckingOut,
    required this.onCheckout,
  });

  final AttendanceEntry attendance;
  final bool isCheckingOut;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = attendance.memberProfileImage;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: avatarUrl.trim().isEmpty
                ? const Icon(Icons.person_outline, color: _primaryColor)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person_outline,
                          color: _primaryColor,
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.memberName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member #${attendance.membershipId} - Check-in: ${_formatDateTime(attendance.checkInAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: isCheckingOut ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isCheckingOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Checkout', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.equipment});

  final GymEquipment equipment;

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveHealthColor(equipment.healthStatus);
    final statusLabel = _healthStatusLabel(equipment.healthStatus);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EquipmentImage(url: equipment.photo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        equipment.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: _primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Jumlah: ${equipment.jumlah}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentImage extends StatelessWidget {
  const _EquipmentImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 84,
        height: 84,
        color: const Color(0xFFF1F3F6),
        child: url.trim().isEmpty
            ? const Icon(Icons.fitness_center_outlined, color: Colors.grey)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyAttendance extends StatelessWidget {
  const _EmptyAttendance();

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.people_outline,
      label: 'Belum ada member di dalam gym.',
    );
  }
}

class _EmptyEquipment extends StatelessWidget {
  const _EmptyEquipment();

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.fitness_center_outlined,
      label: 'Belum ada alat bermasalah.',
    );
  }
}

class _EmptyFilteredEquipment extends StatelessWidget {
  const _EmptyFilteredEquipment();

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.search_off_rounded,
      label: 'Tidak ada alat yang sesuai filter.',
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return '-';
  }

  final local = parsed.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$day/$month/$year $hour:$minute';
}

Color _resolveHealthColor(String status) {
  switch (status.toUpperCase()) {
    case 'BAIK':
      return Colors.green.shade600;
    case 'BUTUH_PERAWATAN':
      return Colors.amber.shade700;
    case 'PERBAIKAN':
      return Colors.orange.shade700;
    case 'RUSAK':
      return Colors.red.shade600;
    default:
      return Colors.blueGrey.shade600;
  }
}

String _healthStatusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'BUTUH_PERAWATAN':
      return 'BUTUH PERAWATAN';
    default:
      return status.toUpperCase();
  }
}

String _statusFilterLabel(String status) {
  if (status == _statusFilterAll) {
    return 'Semua';
  }
  return _healthStatusLabel(status);
}

const _statusFilterAll = 'ALL';
