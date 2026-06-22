import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/placeholder_card.dart';
import '../../widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.profile,
      title: 'Profile',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionHeader(
            title: 'Player profile',
            subtitle:
                'This screen will connect Supabase profile data and camera avatar upload.',
          ),
          SizedBox(height: 12),
          PlaceholderCard(
            title: 'Camera avatar',
            subtitle:
                'Next step: take a photo, upload it to Supabase Storage and save avatar_url.',
            icon: Icons.photo_camera_outlined,
          ),
        ],
      ),
    );
  }
}
