import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  String _selectedLanguage = 'ar'; // 'ar' or 'en'
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final prof = await AuthService.instance.getCurrentProfile();
    if (!mounted) return;
    setState(() {
      _profile = prof;
      _isLoading = false;
    });
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(
      text: _profile?.fullName ?? '',
    );
    final bioController = TextEditingController(text: _profile?.bio ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.champagneGold, width: 1.2),
        ),
        title: Text(
          'تعديل الملف الشخصي',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              style: GoogleFonts.tajawal(color: AppColors.warmIvory),
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                labelStyle: GoogleFonts.tajawal(color: AppColors.champagneGold),
                filled: true,
                fillColor: AppColors.deepNavy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: bioController,
              maxLines: 2,
              style: GoogleFonts.tajawal(color: AppColors.warmIvory),
              decoration: InputDecoration(
                labelText: 'نبذة عنك',
                labelStyle: GoogleFonts.tajawal(color: AppColors.champagneGold),
                filled: true,
                fillColor: AppColors.deepNavy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagneGold,
              foregroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'حفظ التغييرات',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await AuthService.instance.updateProfile(
        fullName: nameController.text.trim(),
        bio: bioController.text.trim(),
      );

      if (success && mounted) {
        _loadProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديث الملف الشخصي في Supabase بنجاح.',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: AppColors.champagneGold,
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.champagneGold),
        ),
        title: Text(
          AppStrings.signOut,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          AppStrings.confirmSignOut,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.85),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppStrings.confirm,
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.signOut();
      if (!mounted) return;
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final isAuthenticated = AuthService.instance.isAuthenticated;
    final name =
        _profile?.fullName ?? (isAuthenticated ? 'مستخدم أنشئلي' : 'ضيف كريم');
    final email = user?.email ?? 'زائر بدون تسجيل';
    final credits = _profile?.credits ?? 10;
    final bio = _profile?.bio ?? 'مبدع في منصة أنشئلي للتصميم الذكي';

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNavy,
        elevation: 0,
        title: Text(
          'الملف الشخصي والإعدادات',
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.champagneGold,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepNavy,
              AppColors.deepNavyMid,
              Color(0xFF0D1830),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.champagneGold,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceNavy,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFF7A0E2C),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.champagneGold,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.champagneGold.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0] : 'A',
                                    style: GoogleFonts.tajawal(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              if (isAuthenticated)
                                GestureDetector(
                                  onTap: _showEditProfileDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.champagneGold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: AppColors.deepNavy,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            name,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.tajawal(
                              color: AppColors.champagneGold,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: GoogleFonts.tajawal(
                              color: AppColors.warmIvory.withValues(
                                alpha: 0.65,
                              ),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            bio,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tajawal(
                              color: AppColors.warmIvory.withValues(alpha: 0.8),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          if (isAuthenticated) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _showEditProfileDialog,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text(
                                'تعديل الملف الشخصي',
                                style: GoogleFonts.tajawal(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.champagneGold,
                                side: const BorderSide(
                                  color: AppColors.champagneGold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Subscription & Credits Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E2D4A),
                            Color(0xFF121B2F),
                            Color(0xFF26141F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(
                            alpha: 0.35,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.champagneGold,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$credits رصيد إبداعي متوفر',
                                    style: GoogleFonts.tajawal(
                                      color: AppColors.champagneGold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'خطة أنشئلي المجانية',
                                    style: GoogleFonts.tajawal(
                                      color: AppColors.warmIvory.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                context.push(AppRoutes.subscription),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.champagneGold,
                              foregroundColor: AppColors.deepNavy,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'ترقية ★',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section: تفضيلات التطبيق
                    Text(
                      'تفضيلات التطبيق والإعدادات',
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceNavy,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Language Selector
                          ListTile(
                            leading: const Icon(
                              Icons.language_rounded,
                              color: AppColors.champagneGold,
                            ),
                            title: Text(
                              'لغة التطبيق',
                              style: GoogleFonts.tajawal(
                                color: AppColors.warmIvory,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLanguage,
                                dropdownColor: AppColors.surfaceNavy,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.champagneGold,
                                ),
                                style: GoogleFonts.tajawal(
                                  color: AppColors.champagneGold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'ar',
                                    child: Text('العربية (RTL)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text('English (LTR)'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedLanguage = val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const Divider(color: Color(0x1AD4AF37), height: 1),

                          // Notifications Toggle
                          SwitchListTile(
                            secondary: const Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.champagneGold,
                            ),
                            title: Text(
                              'إشعارات التحديثات والقوالب',
                              style: GoogleFonts.tajawal(
                                color: AppColors.warmIvory,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: _notificationsEnabled,
                            activeThumbColor: AppColors.champagneGold,
                            onChanged: (val) {
                              setState(() => _notificationsEnabled = val);
                            },
                          ),
                          const Divider(color: Color(0x1AD4AF37), height: 1),

                          // Security / Password
                          ListTile(
                            leading: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.champagneGold,
                            ),
                            title: Text(
                              'إعادة تعيين كلمة المرور',
                              style: GoogleFonts.tajawal(
                                color: AppColors.warmIvory,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.champagneGold,
                              size: 14,
                            ),
                            onTap: () {
                              context.push(AppRoutes.forgotPassword);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout Button
                    if (isAuthenticated)
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _handleSignOut,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          label: Text(
                            AppStrings.signOut,
                            style: GoogleFonts.tajawal(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.redAccent.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.login),
                          icon: const Icon(Icons.login_rounded, size: 20),
                          label: Text(
                            'تسجيل الدخول / إنشاء حساب',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.champagneGold,
                            foregroundColor: AppColors.deepNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
