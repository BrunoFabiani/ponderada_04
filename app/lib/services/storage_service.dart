import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;

  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final path = '$userId/avatar.jpg';

    await _client.storage.from('avatars').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('avatars').getPublicUrl(path);
  }
}
