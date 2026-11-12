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

      // Generate a secure signed URL for private bucket access (24 hour expiration)
      try {
        final signedUrl = await client.storage
            .from(designsBucket)
            .createSignedUrl(path, 60 * 60 * 24);
        return signedUrl;
      } catch (_) {
        return client.storage.from(designsBucket).getPublicUrl(path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Storage upload warning: $e');
      }
      return null;
    }
  }

  /// Create an authenticated signed URL for a private design object
  Future<String?> getDesignSignedUrl(
    String path, {
    int expiresIn = 86400,
  }) async {
    final client = _client;
    if (client == null) return null;
    try {
      final signedUrl = await client.storage
          .from(designsBucket)
          .createSignedUrl(path, expiresIn);
      return signedUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating signed URL for design: $e');
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
