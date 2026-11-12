import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://wwfhoogtnwyavyvuabbw.supabase.co';
  static const String publishableKey =
      'sb_publishable_uJ2Mq_atmAoIjHuotMi1-A_AxNmxMD3';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && publishableKey.isNotEmpty;
}

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        print('⚠️ Supabase is not fully configured yet.');
      }
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.publishableKey,
      );
      _initialized = true;
      if (kDebugMode) {
        print(
          '✅ Supabase initialized successfully: ${SupabaseConfig.supabaseUrl}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Supabase: $e');
      }
    }
  }

  SupabaseClient? get client {
    if (!_initialized) return null;
    return Supabase.instance.client;
  }

  User? get currentUser => client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;
}
