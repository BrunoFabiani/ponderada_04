import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_routes.dart';
import '../../core/supabase_config.dart';
import '../../models/profile_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileModel? profile;
  bool isLoadingProfile = true;
  bool isUploadingAvatar = false;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      setState(() {
        isLoadingProfile = false;
      });
      return;
    }

    try {
      final ProfileRepository repository = ProfileRepository(
        Supabase.instance.client,
      );
      final ProfileModel? currentProfile = await repository.getCurrentProfile();

      if (!mounted) return;

      setState(() {
        profile = currentProfile;
        isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingProfile = false;
      });
      showMessage('Não foi possível carregar o perfil.');
    }
  }

  Future<void> takeAvatarPhoto() async {
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      showMessage('O Supabase não está configurado.');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showMessage('Entre antes de alterar sua foto de perfil.');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (photo == null) return;

    setState(() {
      isUploadingAvatar = true;
    });

    try {
      final imageBytes = await photo.readAsBytes();
      final storageService = StorageService(Supabase.instance.client);
      final profileRepository = ProfileRepository(Supabase.instance.client);

      final String avatarUrl = await storageService.uploadAvatar(
        userId: user.id,
        imageBytes: imageBytes,
      );

      await profileRepository.updateAvatarUrl(
        userId: user.id,
        avatarUrl: avatarUrl,
      );

      if (!mounted) return;

      setState(() {
        profile = ProfileModel(
          id: profile?.id ?? user.id,
          username: profile?.username ?? user.email ?? 'Jogador',
          avatarUrl: avatarUrl,
        );
      });
      showMessage('Foto de perfil atualizada.');
    } catch (error) {
      if (!mounted) return;
      showMessage('Não foi possível atualizar a foto de perfil.');
    } finally {
      if (mounted) {
        setState(() {
          isUploadingAvatar = false;
        });
      }
    }
  }

  Future<void> logout() async {
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      showMessage('O Supabase não está configurado.');
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
      showMessage('Não foi possível sair.');
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.profile,
      title: 'Perfil',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Perfil do jogador',
            subtitle: 'Gerencie seu perfil e sua foto no aplicativo.',
          ),
          const SizedBox(height: 12),
          _ProfileCard(
            profile: profile,
            isLoading: isLoadingProfile,
            isUploadingAvatar: isUploadingAvatar,
            onTakePhoto: takeAvatarPhoto,
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
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.isLoading,
    required this.isUploadingAvatar,
    required this.onTakePhoto,
  });

  final ProfileModel? profile;
  final bool isLoading;
  final bool isUploadingAvatar;
  final VoidCallback onTakePhoto;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: _avatarImage,
              child: _avatarImage == null
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              profile?.username ?? 'Jogador',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              profile == null
                  ? 'Nenhum perfil carregado ainda.'
                  : 'Sua foto está salva no Supabase.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isUploadingAvatar ? null : onTakePhoto,
              icon: isUploadingAvatar
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_camera),
              label: Text(
                isUploadingAvatar ? 'Enviando foto...' : 'Tirar foto de perfil',
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? get _avatarImage {
    final String? avatarUrl = profile?.avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    return NetworkImage(avatarUrl);
  }
}
