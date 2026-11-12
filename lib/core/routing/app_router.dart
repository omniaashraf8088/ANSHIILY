import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/categories/screens/categories_screen.dart';
import '../../features/templates/screens/template_library_screen.dart';
import '../../features/templates/screens/template_preview_screen.dart';
import '../../features/templates/screens/project_editor_screen.dart';
import '../../features/templates/models/template_model.dart';
import '../../features/projects/models/project_model.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';
import '../../features/ai_engine/screens/guided_creation_wizard_screen.dart';
import '../../features/templates/models/document_structure.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String templateLibrary = '/template-library';
  static const String templatePreview = '/template-preview';
  static const String projectEditor = '/project-editor';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String aiWizard = '/ai-wizard';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.templateLibrary,
        name: 'templateLibrary',
        builder: (context, state) {
          final cat = state.uri.queryParameters['category'];
          return TemplateLibraryScreen(initialCategory: cat);
        },
      ),
      GoRoute(
        path: '${AppRoutes.templatePreview}/:id',
        name: 'templatePreview',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TemplatePreviewScreen(templateId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.projectEditor,
        name: 'projectEditor',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final project =
              extra['project'] as ProjectModel? ??
              ProjectModel(
                id: 'new',
                userId: 'user',
                title: 'مشروع جديد',
                prompt: '',
                createdAt: DateTime.now(),
              );
          final template = extra['template'] as TemplateModel?;
          final initialDoc = extra['initialDocument'] as TemplateDocument?;
          return ProjectEditorScreen(
            project: project,
            template: template,
            initialDocument: initialDoc,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.aiWizard,
        name: 'aiWizard',
        builder: (context, state) {
          final prompt = state.uri.queryParameters['prompt'];
          return GuidedCreationWizardScreen(initialPrompt: prompt);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: Center(
        child: Text(
          'الصفحة غير موجودة',
          style: const TextStyle(color: Color(0xFFD4AF37)),
        ),
      ),
    ),
  );
}
