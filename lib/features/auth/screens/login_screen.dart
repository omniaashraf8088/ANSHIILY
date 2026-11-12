import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await AuthService.instance.signIn(
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'مرحباً بك في أنشئلي!',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: AppColors.champagneGold,
        ),
      );
      context.go(AppRoutes.home);
    } else {
      final error = result.errorMessage ?? 'فشل تسجيل الدخول';
      if (error.contains('تأكيد البريد') ||
          error.contains('email not confirmed')) {
        _showEmailConfirmationDialog(email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent.shade700,
          ),
        );
      }
    }
  }

  void _showEmailConfirmationDialog(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.3),
          ),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.mark_email_unread_outlined,
              color: AppColors.champagneGold,
            ),
            const SizedBox(width: 8),
            Text(
              'تأكيد البريد الإلكتروني',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'لم يتم تفعيل هذا الحساب بعد. يرجى الضغط على رابط التفعيل في الرسالة المرسلة إلى $email أو طلب إعادة إرسال الرابط.',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final res = await AuthService.instance.resendConfirmationEmail(
                email,
              );
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    res.isSuccess
                        ? 'تمت إعادة إرسال رابط التأكيد بنجاح.'
                        : 'فشل الإرسال: ${res.errorMessage}',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(),
                  ),
                  backgroundColor: res.isSuccess
                      ? AppColors.champagneGold
                      : Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagneGold,
              foregroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'إعادة إرسال الرابط',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Container(
        width: size.width,
        height: size.height,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Official Logo
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.champagneGold.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            AppAssets.appIcon,
                            width: 84,
                            height: 84,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // App Title & Tagline
                  Center(
                    child: Column(
                      children: [
                        Text(
                          AppStrings.appNameArabic,
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppStrings.taglineArabic}  •  ${AppStrings.taglineEnglish}',
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.tajawal(
                            color: AppColors.warmIvory.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Section Header
                  Text(
                    AppStrings.welcomeBack,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.loginSubtitle,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.65),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Email
                  AuthTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: AppStrings.emailHint,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password
                  AuthTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: AppStrings.passwordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Forgot Password Link
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: GoogleFonts.tajawal(
                          color: AppColors.champagneGold.withValues(
                            alpha: 0.85,
                          ),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.deepNavy,
                        disabledBackgroundColor: AppColors.champagneGold
                            .withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.deepNavy,
                              ),
                            )
                          : Text(
                              AppStrings.login,
                              style: GoogleFonts.tajawal(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Register prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.doNotHaveAccount,
                        style: GoogleFonts.tajawal(
                          color: AppColors.warmIvory.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: Text(
                          AppStrings.createNewAccount,
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.champagneGold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Continue as guest
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: AppColors.warmIvory.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.guestMode,
                            style: GoogleFonts.tajawal(
                              color: AppColors.warmIvory.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
