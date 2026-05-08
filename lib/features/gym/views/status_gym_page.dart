import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_alerts.dart';
import '../../auth/models/me_response.dart';
import '../../auth/viewmodels/login_view_model.dart';
import '../models/gym_detail_response.dart';
import '../models/gym_equipment_response.dart';
import 'gym_equipment_create_page.dart';
import 'gym_edit_page.dart';
import 'gym_equipment_edit_page.dart';
import '../viewmodels/status_gym_view_model.dart';

const _pageBackground = Color(0xFFF7F8FB);
const _primaryColor = Color(0xFF6366F1);

class StatusGymPage extends StatefulWidget {
  const StatusGymPage({super.key});

  @override
  State<StatusGymPage> createState() => _StatusGymPageState();
}

class _StatusGymPageState extends State<StatusGymPage> {
  int? _loadedGymId;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = _statusFilterAll;
  int _visibleEquipmentCount = _initialEquipmentLimit;

  @override
  void dispose() {
    _searchController.dispose();
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

        final viewModel = context.read<StatusGymViewModel>();
        if (gymId == null) {
          viewModel.clearGym();
          return;
        }

        viewModel.loadGym(gymId);
      });

      _resetVisibleEquipmentCount();
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

  List<GymEquipment> _filterEquipment(List<GymEquipment> items) {
    final query = _searchController.text.trim().toLowerCase();
    final filter = _statusFilter;

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

  void _resetVisibleEquipmentCount() {
    _visibleEquipmentCount = _initialEquipmentLimit;
  }

  void _showMoreEquipment() {
    setState(() {
      _visibleEquipmentCount += _initialEquipmentLimit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Consumer<StatusGymViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading && viewModel.gymDetail == null) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            }

            if (viewModel.errorMessage != null && viewModel.gymDetail == null) {
              return _ErrorState(
                message: viewModel.errorMessage ?? 'Gagal memuat data gym.',
                onRetry: () {
                  final gymId = _loadedGymId;
                  if (gymId != null) {
                    viewModel.loadGym(gymId);
                  }
                },
              );
            }

            final gym = viewModel.gymDetail;
            if (gym == null) {
              return const Center(child: Text('Data gym tidak tersedia.'));
            }

            final filteredEquipment = _filterEquipment(viewModel.equipment);
            final visibleEquipment = filteredEquipment
                .take(_visibleEquipmentCount)
                .toList();

            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _GymHeader(
                      gym: gym,
                      isUpdating: viewModel.isUpdating,
                      onEdit: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GymEditPage(gym: gym),
                          ),
                        );

                        if (result == true && context.mounted) {
                          AppAlerts.showSuccess(
                            context,
                            'Informasi gym berhasil diperbarui',
                          );
                        }
                      },
                    ),
                  ),
                  if (viewModel.errorMessage != null) ...[
                    SliverToBoxAdapter(
                      child: _InlineError(message: viewModel.errorMessage!),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Peralatan Gym',
                      subtitle: '${filteredEquipment.length} item',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _EquipmentToolbar(
                      controller: _searchController,
                      filterLabel: _statusFilterLabel(_statusFilter),
                      onSearchChanged: (_) {
                        setState(() {
                          _resetVisibleEquipmentCount();
                        });
                      },
                      onFilterSelected: (value) {
                        setState(() {
                          _statusFilter = value;
                          _resetVisibleEquipmentCount();
                        });
                      },
                      onAddPressed: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GymEquipmentCreatePage(gymId: gym.id),
                          ),
                        );

                        if (result == true && context.mounted) {
                          setState(() {
                            _resetVisibleEquipmentCount();
                          });
                          AppAlerts.showSuccess(
                            context,
                            'Alat gym baru berhasil ditambahkan',
                          );
                        }
                      },
                    ),
                  ),
                  if (viewModel.equipment.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyEquipment())
                  else if (filteredEquipment.isEmpty)
                    const SliverToBoxAdapter(child: _EmptySearch())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = visibleEquipment[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _EquipmentCard(
                            equipment: item,
                            onTap: () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GymEquipmentEditPage(
                                    gymId: gym.id,
                                    equipment: item,
                                  ),
                                ),
                              );

                              if (result == true && context.mounted) {
                                AppAlerts.showSuccess(
                                  context,
                                  'Data alat gym berhasil diperbarui',
                                );
                              }
                            },
                          ),
                        );
                      }, childCount: visibleEquipment.length),
                    ),
                  if (filteredEquipment.length > visibleEquipment.length)
                    SliverToBoxAdapter(
                      child: _LoadMoreButton(onPressed: _showMoreEquipment),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GymHeader extends StatelessWidget {
  const _GymHeader({
    required this.gym,
    required this.onEdit,
    required this.isUpdating,
  });

  final GymDetail gym;
  final VoidCallback onEdit;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final imageUrl = gym.gymImage.isNotEmpty ? gym.gymImage.first.url : '';
    final facilities = gym.facility
        .map((item) => item.trim())
        .where(_hasValue)
        .toList();
    final tags = gym.tag
        .split(',')
        .map((item) => item.trim())
        .where(_hasValue)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gym',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GymImage(url: imageUrl),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gym.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _VerifiedPill(status: gym.verified),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: isUpdating ? null : onEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryColor,
                            side: BorderSide(
                              color: _primaryColor.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text(
                            'Edit Gym',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_hasValue(gym.description))
                        Text(
                          gym.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Alamat',
                        value: gym.address,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'Jam Operasional',
                        value: gym.jamOperasional,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.people_alt_outlined,
                        label: 'Kapasitas',
                        value: '${gym.maxCapacity} orang',
                      ),
                      if (facilities.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Fasilitas',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: facilities
                              .map((item) => _TagChip(text: item))
                              .toList(),
                        ),
                      ],
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Tag',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: tags
                              .map((item) => _TagChip(text: item))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GymImage extends StatelessWidget {
  const _GymImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        height: 180,
        decoration: const BoxDecoration(
          color: Color(0xFFEFF1F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 36, color: Colors.grey),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFEFF1F5),
              child: const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }
            return Container(
              color: const Color(0xFFEFF1F5),
              child: const Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VerifiedPill extends StatelessWidget {
  const _VerifiedPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final color = _resolveVerifiedColor(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized.isEmpty ? 'UNKNOWN' : normalized,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _primaryColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _primaryColor,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _EquipmentToolbar extends StatelessWidget {
  const _EquipmentToolbar({
    required this.controller,
    required this.filterLabel,
    required this.onSearchChanged,
    required this.onFilterSelected,
    required this.onAddPressed,
  });

  final TextEditingController controller;
  final String filterLabel;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari alat gym...',
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
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Tambah Alat Baru',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryColor,
            side: BorderSide(color: _primaryColor.withValues(alpha: 0.35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Tampilkan Lebih Banyak',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.equipment, this.onTap});

  final GymEquipment equipment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveHealthColor(equipment.healthStatus);
    final statusLabel = _healthStatusLabel(equipment.healthStatus);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
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
      ),
    );
  }
}

class _EmptyEquipment extends StatelessWidget {
  const _EmptyEquipment();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
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
              child: const Icon(
                Icons.fitness_center_outlined,
                color: _primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Belum ada data alat gym yang tersedia.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
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
              child: const Icon(Icons.search_off_rounded, color: _primaryColor),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tidak ada alat yang sesuai filter.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: _primaryColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _hasValue(String value) {
  final trimmed = value.trim();
  return trimmed.isNotEmpty && trimmed != '-';
}

Color _resolveVerifiedColor(String status) {
  switch (status) {
    case 'APPROVED':
      return Colors.green.shade700;
    case 'PENDING':
      return Colors.orange.shade700;
    case 'REJECTED':
      return Colors.red.shade700;
    default:
      return Colors.blueGrey.shade600;
  }
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
const _initialEquipmentLimit = 5;
