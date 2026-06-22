import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    final path = '$userId/avatar.jpg';

    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('avatars').getPublicUrl(path);
  }
}
