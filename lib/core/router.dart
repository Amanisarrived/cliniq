import 'package:cliniq/screens/auth/login_screen.dart';
import 'package:cliniq/screens/diary/diary_screen.dart';
import 'package:cliniq/screens/home/home_screen.dart';
import 'package:cliniq/screens/medicine_scanner/medicine_scanner_screen.dart';
import 'package:cliniq/screens/news/news_screen.dart';
import 'package:cliniq/screens/onboarding/onboarding_screen.dart';
import 'package:cliniq/screens/profile/profile_screen.dart';
import 'package:cliniq/screens/reminders/reminders_screen.dart';
import 'package:cliniq/screens/sickness/sickness_guide_screen.dart';
import 'package:cliniq/screens/terms/terms_screen.dart';
import 'package:cliniq/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // ── No bottom nav screens ──
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.terms,
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.medicineScanner,
      builder: (context, state) => const MedicineScannerScreen(),
    ),
    GoRoute(
      path: AppRoutes.sicknessGuide,
      builder: (context, state) => const SicknessGuideScreen(),
    ),
    GoRoute(
      path: AppRoutes.hospitals,
      redirect: (_, __) => AppRoutes.news,
    ),
    ShellRoute(
      builder: (context, state, child) => Scaffold(
        body: child,
        bottomNavigationBar: AppBottomNav(
          currentRoute: state.uri.toString(),
        ),
      ),
      routes: [
        GoRoute(
          // ✅ ADD THIS
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.reminders,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: RemindersScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.diary,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DiaryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.news,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: NewsScreen(),
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);
