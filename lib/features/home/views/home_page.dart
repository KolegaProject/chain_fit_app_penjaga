import 'package:flutter/material.dart';

import '../../auth/models/me_response.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.meData});

  final MeData meData;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE8EAFF),
                  backgroundImage: meData.user.profileImage.isNotEmpty
                      ? NetworkImage(meData.user.profileImage)
                      : null,
                  child: meData.user.profileImage.isEmpty
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
                        'Halo, ${meData.user.name}',
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
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
