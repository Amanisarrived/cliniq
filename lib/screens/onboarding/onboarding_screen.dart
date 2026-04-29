import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ✅ Single controller for content animation
  late AnimationController _contentController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      image: 'assets/images/onbording1.png',
      title: 'Understand Your\nMedicines Instantly',
      subtitle:
          'Scan any medicine and get complete\ninformation in simple language',
    ),
    _OnboardingData(
      image: 'assets/images/onbording2.png',
      title: 'Your Guide for\nCommon Illnesses',
      subtitle: 'Fever, cold, injury — get simple\nhome care guidance anytime',
    ),
    _OnboardingData(
      image: 'assets/images/onbording3.png',
      title: 'Find Nearby\nHospitals Instantly',
      subtitle:
          'Emergency or routine checkup —\nfind the nearest hospital in seconds',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _animateToPage(int index) async {
    await _contentController.reverse();

    setState(() => _currentPage = index);

    _pageController.jumpToPage(index);

    await _contentController.forward();
  }

  Future<void> _onNext() async {
    if (_currentPage < _pages.length - 1) {
      await _animateToPage(_currentPage + 1);
    } else {
      await _completeOnboarding();
    }
  }

  Future<void> _onSkip() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,

      // ✅ No drag — physics none
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: AnimatedOpacity(
                  opacity: isLastPage ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: TextButton(
                    onPressed: isLastPage ? null : _onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ✅ PageView with NeverScrollableScrollPhysics
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: OnboardingPage(
                        imagePath: _pages[index].image,
                        title: _pages[index].title,
                        subtitle: _pages[index].subtitle,
                        isDark: isDark,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
              child: Column(
                children: [
                  // Indicator
                  PageIndicator(
                    count: _pages.length,
                    currentIndex: _currentPage,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? CliniqTheme.darkPrimary
                            : CliniqTheme.lightPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: child,
                        ),
                        child: Text(
                          isLastPage ? 'Get Started' : 'Next',
                          key: ValueKey(isLastPage),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Login link
                  AnimatedOpacity(
                    opacity: isLastPage ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextButton(
                      onPressed:
                          isLastPage ? () => context.go(AppRoutes.login) : null,
                      child: Text(
                        'Already have an account? Sign in',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
