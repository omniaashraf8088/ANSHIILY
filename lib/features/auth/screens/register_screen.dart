import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await AuthService.instance.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (result.requiresEmailConfirmation) {
        _showSuccessDialog(email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إنشاء الحساب بنجاح! مرحباً بك.',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: AppColors.champagneGold,
          ),
        );
        context.go(AppRoutes.home);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'تعذر إنشاء الحساب',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade700,
        ),
      );
    }
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.champagneGold, width: 1.5),
        ),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneGold.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: AppColors.champagneGold,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تم إنشاء الحساب بنجاح!',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'أهلاً بك في أنشئلي! تم إرسال رابط تأكيد إلى:\n$email\n\nيرجى تأكيد بريدك الإلكتروني لتسجيل الدخول ومتابعة إبداعك.',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagneGold,
              foregroundColor: AppColors.deepNavy,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'الانتقال لتسجيل الدخول',
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.champagneGold,
          ),
          onPressed: () => context.pop(),
        ),
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        AppAssets.appIcon,
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header
                  Text(
                    AppStrings.registerTitle,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.registerSubtitle,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Full Name
                  AuthTextField(
                    controller: _fullNameController,
                    label: AppStrings.fullName,
                    hint: AppStrings.fullNameHint,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسمك الكامل';
                      }
                      if (value.trim().length < 2) {
                        return 'الاسم قصير جداً';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  // Password
                  AuthTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: AppStrings.passwordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
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

                  const SizedBox(height: 16),

                  // Confirm Password
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    hint: AppStrings.confirmPasswordHint,
                    prefixIcon: Icons.lock_reset_rounded,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'كلمتا المرور غير متطابقتين';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Register Button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.deepNavy,
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
                              AppStrings.createNewAccount,
                              style: GoogleFonts.tajawal(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: GoogleFonts.tajawal(
                          color: AppColors.warmIvory.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          AppStrings.login,
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
