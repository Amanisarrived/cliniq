import 'package:cliniq/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/user_provider.dart';
import 'widgets/profile_user_card.dart';
import 'widgets/profile_credits_card.dart';
import 'widgets/profile_settings_card.dart';
import 'widgets/profile_about_card.dart';
import 'widgets/profile_logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  void _toggleTheme(BuildContext context) {
    CliniqApp.of(context)?.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 24),

              ProfileUserCard(user: user, isDark: isDark),

              const SizedBox(height: 12),
              if (user != null) ...[
                ProfileCreditsCard(user: user, isDark: isDark),
                const SizedBox(height: 24),
              ],

              // ─── Settings ────────────────────────────
              _SectionLabel(label: 'Preferences', isDark: isDark),
              const SizedBox(height: 10),
              ProfileSettingsCard(
                isDark: isDark,
                onThemeToggle: () => _toggleTheme(context),
              ),

              const SizedBox(height: 24),

              // ─── About ───────────────────────────────
              _SectionLabel(label: 'About', isDark: isDark),
              const SizedBox(height: 10),
              ProfileAboutCard(isDark: isDark),

              const SizedBox(height: 24),

              // ─── Logout ──────────────────────────────
              ProfileLogoutButton(isDark: isDark),

              const SizedBox(height: 12),

              // ─── App tagline ─────────────────────────
              Center(
                child: Text(
                  'Cliniq • Samjho. Sehat Raho.',
                  style: TextStyle(
                    color: isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
