import 'package:cliniq/screens/auth/widgets/features_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/auth_header.dart';
import 'widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    final success = await authProvider.signInWithGoogle();
    if (!mounted) return;

    if (success && authProvider.user != null) {
      userProvider.listenToUser(authProvider.user!.uid);

      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final termsAccepted =
          prefs.getBool(AppConstants.keyTermsAccepted) ?? false;

      context.go(
        termsAccepted ? AppRoutes.home : AppRoutes.terms,
      );
    } else if (authProvider.errorMessage != null) {
      if (!mounted) return;
      _showError(authProvider.errorMessage!);
      authProvider.clearError();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CliniqTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.select<AuthProvider, bool>(
      (p) => p.isLoading,
    );

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top spacer
                  const Spacer(flex: 2),

                  // Header
                  AuthHeader(isDark: isDark),

                  // Middle spacer
                  const Spacer(flex: 3),

                  // Google Button
                  GoogleSignInButton(
                    onPressed: _handleSignIn,
                    isLoading: isLoading,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  _OrDivider(isDark: isDark),

                  const SizedBox(height: 20),

                  // Feature chips
                  FeatureChips(isDark: isDark),

                  // Bottom spacer
                  const Spacer(flex: 2),

                  // Privacy note
                  _PrivacyNote(isDark: isDark),

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

// ── Or Divider ────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  final bool isDark;
  const _OrDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Trusted by thousands',
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            thickness: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Privacy Note ─────────────────────────────────────
class _PrivacyNote extends StatelessWidget {
  final bool isDark;
  const _PrivacyNote({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'By continuing you agree to our\nTerms of Service & Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightTextMuted,
          fontSize: 11,
          height: 1.6,
        ),
      ),
    );
  }
}
