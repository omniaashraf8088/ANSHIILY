import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/user_profile.dart';

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final bool requiresEmailConfirmation;
  final User? user;

  const AuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.requiresEmailConfirmation = false,
    this.user,
  });

  factory AuthResult.success({
    User? user,
    bool requiresEmailConfirmation = false,
  }) {
    return AuthResult(
      isSuccess: true,
      user: user,
      requiresEmailConfirmation: requiresEmailConfirmation,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(isSuccess: false, errorMessage: message);
  }
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient? get _client => SupabaseService.instance.client;

  User? get currentUser => _client?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  /// Register a new user
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? username,
  }) async {
    final client = _client;
    if (client == null) {
      return AuthResult.failure('خدمة Supabase غير متصلة.');
    }

    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          if (username != null && username.isNotEmpty)
            'username': username.trim(),
        },
      );

      final user = response.user;
      if (user == null) {
        return AuthResult.failure('تعذر إنشاء الحساب، يرجى المحاولة لاحقاً.');
      }

      // Check if email confirmation is required (session is null when email confirm is enabled)
      final requiresConfirmation = response.session == null;

      // Ensure profile row exists
      try {
        await client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName.trim(),
          if (username != null && username.isNotEmpty)
            'username': username.trim(),
        });
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Profile upsert notice: $e');
        }
      }

      return AuthResult.success(
        user: user,
        requiresEmailConfirmation: requiresConfirmation,
      );
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  /// Sign in existing user
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      return AuthResult.failure('خدمة Supabase غير متصلة.');
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      return AuthResult.success(user: response.user);
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('حدث خطأ أثناء تسجيل الدخول: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    }
  }

  /// Reset password request
  Future<AuthResult> resetPassword(String email) async {
    final client = _client;
    if (client == null) {
      return AuthResult.failure('خدمة Supabase غير متصلة.');
    }

    try {
      await client.auth.resetPasswordForEmail(email.trim());
      return AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('فشل إرسال رابط استعادة كلمة المرور.');
    }
  }

  /// Resend confirmation email
  Future<AuthResult> resendConfirmationEmail(String email) async {
    final client = _client;
    if (client == null) {
      return AuthResult.failure('خدمة Supabase غير متصلة.');
    }

    try {
      await client.auth.resend(type: OtpType.signup, email: email.trim());
      return AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('فشل إعادة إرسال رابط التأكيد.');
    }
  }

  /// Fetch user profile from Supabase profiles table
  Future<UserProfile?> getCurrentProfile() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return null;

    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // Return basic profile from user metadata
        return UserProfile(
          id: user.id,
          fullName:
              user.userMetadata?['full_name'] as String? ?? 'مستخدم أنشئلي',
          username: user.userMetadata?['username'] as String?,
          credits: 10,
        );
      }

      return UserProfile.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile: $e');
      }
      return UserProfile(
        id: user.id,
        fullName: user.userMetadata?['full_name'] as String? ?? 'مستخدم أنشئلي',
        credits: 10,
      );
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return false;

    try {
      final updateData = <String, dynamic>{
        'full_name': fullName.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (bio != null) updateData['bio'] = bio.trim();
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      await client.from('profiles').update(updateData).eq('id', user.id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      return false;
    }
  }

  /// Translate Supabase Auth errors into Arabic user-friendly messages
  String _mapAuthErrorMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }
    if (msg.contains('email not confirmed')) {
      return 'لم يتم تأكيد البريد الإلكتروني بعد. يرجى مراجعة بريدك والضغط على رابط التأكيد.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('email address already exists')) {
      return 'البريد الإلكتروني مسجل بالفعل، يرجى تسجيل الدخول.';
    }
    if (msg.contains('password should be at least')) {
      return 'كلمة المرور ضعيفة، يجب أن تتكون من 6 أحرف على الأقل.';
    }
    if (msg.contains('email address') && msg.contains('invalid')) {
      return 'صيغة البريد الإلكتروني غير صالحة.';
    }
    return e.message;
  }
}
