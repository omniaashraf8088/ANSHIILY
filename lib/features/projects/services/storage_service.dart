import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String designsBucket = 'designs';
  static const String avatarsBucket = 'avatars';

  SupabaseClient? get _client => SupabaseService.instance.client;

  /// Upload file bytes to Supabase Storage
  Future<String?> uploadDesignImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return null;

    try {
      final path = '${user.id}/$fileName';
      await client.storage
          .from(designsBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = client.storage.from(designsBucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Storage upload warning: $e');
      }
      return null;
    }
  }

  /// Upload avatar image
  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return null;

    try {
      final path = '${user.id}/$fileName';
      await client.storage
          .from(avatarsBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = client.storage.from(avatarsBucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Avatar upload warning: $e');
      }
      return null;
    }
  }
}
