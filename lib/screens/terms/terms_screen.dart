import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import 'widgets/terms_checkbox.dart';
import 'widgets/terms_section.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen>
    with SingleTickerProviderStateMixin {
  bool _check1 = false;
  bool _check2 = false;
  bool _isSaving = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get _canProceed => _check1 && _check2;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

  // Terms accept hone ke baad
  Future<void> _onAgree() async {
    if (!_canProceed || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyTermsAccepted, true);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({
          'termsAccepted': true,
          'termsAcceptedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      context.go(AppRoutes.home); // ← Home pe bhejo
    } catch (e) {
      debugPrint('Terms error: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? CliniqTheme.darkPrimary.withAlpha(30)
                              : CliniqTheme.lightPrimary.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? CliniqTheme.darkPrimary.withAlpha(80)
                                : CliniqTheme.lightPrimary.withAlpha(60),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: isDark
                                  ? CliniqTheme.darkPrimary
                                  : CliniqTheme.lightPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Important Information',
                              style: TextStyle(
                                color: isDark
                                    ? CliniqTheme.darkPrimary
                                    : CliniqTheme.lightPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Before You Begin',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkText
                              : CliniqTheme.lightText,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Please read this carefully',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // What app does
                        TermsSection(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'What Cliniq does',
                          isDark: isDark,
                          points: const [
                            'Provides general information about medicines',
                            'Offers home care guidance for common illnesses',
                            'Helps you find nearby hospitals',
                            'Sets medicine reminders for you and family',
                          ],
                        ),

                        const SizedBox(height: 12),

                        // What app doesn't do
                        TermsSection(
                          icon: Icons.cancel_outlined,
                          title: 'What Cliniq does NOT do',
                          isDark: isDark,
                          iconColor: CliniqTheme.danger,
                          points: const [
                            'Does not diagnose any medical condition',
                            'Does not prescribe or recommend medicines',
                            'Cannot replace a doctor\'s consultation',
                            'Does not provide emergency medical help',
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Checkboxes
                        TermsCheckbox(
                          text:
                              'I understand that Cliniq is an information app only and is not a substitute for professional medical advice.',
                          value: _check1,
                          isDark: isDark,
                          onChanged: (val) =>
                              setState(() => _check1 = val ?? false),
                        ),

                        const SizedBox(height: 10),

                        TermsCheckbox(
                          text:
                              'I will only take medicines after consulting a doctor or pharmacist.',
                          value: _check2,
                          isDark: isDark,
                          onChanged: (val) =>
                              setState(() => _check2 = val ?? false),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    children: [
                      // Agree Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ElevatedButton(
                            onPressed: _canProceed ? _onAgree : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canProceed
                                  ? (isDark
                                      ? CliniqTheme.darkPrimary
                                      : CliniqTheme.lightPrimary)
                                  : (isDark
                                      ? CliniqTheme.darkSurface2
                                      : CliniqTheme.lightBorder),
                              foregroundColor: _canProceed
                                  ? Colors.white
                                  : (isDark
                                      ? CliniqTheme.darkTextMuted
                                      : CliniqTheme.lightTextMuted),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'I Agree, Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Helper text
                      AnimatedOpacity(
                        opacity: _canProceed ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          'Please accept both checkboxes to continue',
                          style: TextStyle(
                            color: isDark
                                ? CliniqTheme.darkTextMuted
                                : CliniqTheme.lightTextMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
