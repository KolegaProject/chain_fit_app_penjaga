import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/models/me_response.dart';
import '../../auth/viewmodels/login_view_model.dart';
import '../models/gym_detail_response.dart';
import '../models/gym_equipment_response.dart';
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
        context.read<StatusGymViewModel>().loadGym(gymId);
      });
    }
  }

  int _resolveGymId(MeData? data) {
    final fallbackId = 12;
    if (data == null) {
      return fallbackId;
    }

    final defaultId = data.defaultGymId;
    if (defaultId != null && defaultId > 0) {
      return defaultId;
    }

    if (data.gyms.isNotEmpty) {
      return data.gyms.first.id;
    }

    return fallbackId;
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
                  final gymId = _loadedGymId ?? 12;
                  viewModel.loadGym(gymId);
                },
              );
            }

            final gym = viewModel.gymDetail;
            if (gym == null) {
              return const Center(child: Text('Data gym tidak tersedia.'));
            }

            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _GymHeader(gym: gym)),
                  if (viewModel.errorMessage != null) ...[
                    SliverToBoxAdapter(
                      child: _InlineError(message: viewModel.errorMessage!),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Peralatan Gym',
                      subtitle: '${viewModel.equipment.length} item',
                    ),
                  ),
                  if (viewModel.equipment.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyEquipment())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = viewModel.equipment[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _EquipmentCard(equipment: item),
                        );
                      }, childCount: viewModel.equipment.length),
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
  const _GymHeader({required this.gym});

  final GymDetail gym;

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

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.equipment});

  final GymEquipment equipment;

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveHealthColor(equipment.healthStatus);

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
                        equipment.healthStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  equipment.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                if (_hasValue(equipment.videoUrl)) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Video: ${equipment.videoUrl}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
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
    case 'PERBAIKAN':
      return Colors.orange.shade700;
    case 'RUSAK':
      return Colors.red.shade600;
    default:
      return Colors.blueGrey.shade600;
  }
}
