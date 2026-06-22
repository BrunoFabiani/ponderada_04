import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_routes.dart';
import '../../core/supabase_config.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/placeholder_card.dart';
import '../../widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoggingOut = false;

  Future<void> logout() async {
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      showMessage('Supabase is not configured.');
      return;
    }

    setState(() {
      isLoggingOut = true;
    });

    try {
      final AuthRepository repository = AuthRepository(
        Supabase.instance.client,
      );

      await repository.signOut();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      showMessage('Could not log out.');
    } finally {
      if (!mounted) return;

      setState(() {
        isLoggingOut = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.profile,
      title: 'Profile',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Player profile',
            subtitle:
                'This screen will connect Supabase profile data and camera avatar upload.',
          ),
          const SizedBox(height: 12),
          const PlaceholderCard(
            title: 'Camera avatar',
            subtitle:
                'Next step: take a photo, upload it to Supabase Storage and save avatar_url.',
            icon: Icons.photo_camera_outlined,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: isLoggingOut ? null : logout,
            icon: isLoggingOut
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
