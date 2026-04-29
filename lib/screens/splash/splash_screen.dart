import 'package:cliniq/providers/reminders_provider.dart';
import 'package:cliniq/providers/user_provider.dart';
import 'package:cliniq/providers/app_config_provider.dart'; // ADD
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // ADD (already in pubspec)
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import 'widgets/animated_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    // --- CONFIG CHECK START ---
    final configProvider = context.read<AppConfigProvider>();
    await configProvider.loadConfig();
    if (!mounted) return;

    final config = configProvider.config;

    // 1. Maintenance mode
    if (config.maintenanceMode) {
      _showMaintenanceDialog();
      return; // navigation rok do
    }

    // 2. Force update
    if (config.forceUpdateVersion.isNotEmpty) {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      if (_isForceUpdateRequired(info.version, config.forceUpdateVersion)) {
        _showForceUpdateDialog();
        return; // navigation rok do
      }
    }
    // --- CONFIG CHECK END ---

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final onboardingDone =
        prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
    final termsAccepted = prefs.getBool(AppConstants.keyTermsAccepted) ?? false;

    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (!mounted) return;

    if (user != null) {
      context.read<UserProvider>().listenToUser(user.uid);
      await context.read<RemindersProvider>().syncFromFirestore();
    }

    final String route;
    if (!onboardingDone) {
      route = AppRoutes.onboarding;
    } else if (user == null) {
      route = AppRoutes.login;
    } else if (!termsAccepted) {
      route = AppRoutes.terms;
    } else {
      route = AppRoutes.home;
    }

    if (!mounted) return;
    context.go(route);
  }

  /// true if currentVersion < forceVersion
  bool _isForceUpdateRequired(String current, String force) {
    final c = current.split('.').map(int.tryParse).whereType<int>().toList();
    final f = force.split('.').map(int.tryParse).whereType<int>().toList();
    for (int i = 0; i < f.length; i++) {
      final cv = i < c.length ? c[i] : 0;
      if (cv < f[i]) return true;
      if (cv > f[i]) return false;
    }
    return false;
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('🔧 Maintenance'),
          content: const Text(
            'Cliniq abhi maintenance mode mein hai.\nThodi der mein wapas aao! 🙏',
          ),
          // No actions — user yahan se ja hi nahi sakta
        ),
      ),
    );
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('🚀 Update Required'),
          content: const Text(
            'Cliniq ka naya version aa gaya hai!\nBehtar experience ke liye update karo.',
          ),
          actions: [
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.cliniq.app',
                ),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Update Karo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... tera existing build — kuch nahi badla
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedLogo(),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Cli',
                            style: TextStyle(
                              color: isDark
                                  ? CliniqTheme.darkText
                                  : CliniqTheme.lightText,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          TextSpan(
                            text: 'niq',
                            style: TextStyle(
                              color: isDark
                                  ? CliniqTheme.darkPrimary
                                  : CliniqTheme.lightPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aapka AI Health Saathi',
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 3,
                child: LinearProgressIndicator(
                  backgroundColor: isDark
                      ? CliniqTheme.darkSurface2
                      : CliniqTheme.lightBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
