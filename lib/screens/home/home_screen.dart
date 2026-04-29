import 'package:cliniq/core/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/ad_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/paywall/paywall_screen.dart';
import 'widgets/ai_chat_strip.dart';
import 'widgets/credits_banner.dart';
import 'widgets/feature_grid.dart';
import 'widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _animController.forward();

    // ✅ Config load karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppConfigProvider>().loadConfig();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Watch Ad ─────────────────────────────────
  Future<void> _onWatchAd() async {
    final uid = context.read<UserProvider>().user?.uid;
    if (uid == null) return;

    final adProvider = context.read<AdProvider>();

    if (!adProvider.canWatchAd) {
      _showSnack('Aaj ke liye maximum ads dekh liye! (2/2)');
      return;
    }

    final rewarded = await adProvider.showRewardedAd(uid);
    if (!mounted) return;

    if (rewarded) {
      _showSnack('🎉 +2 credits mile!');
    } else if (adProvider.error != null) {
      _showSnack(adProvider.error!);
      adProvider.clearStatus();
    }
  }

  // ─── Upgrade ──────────────────────────────────
  void _onUpgrade() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  void _onAiChatTap() {
    context.push(AppRoutes.medicineScanner);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adProvider = context.watch<AdProvider>();
    final configProvider = context.watch<AppConfigProvider>();

    // Sync adsWatchedToday from user
    final user = context.watch<UserProvider>().user;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          adProvider.setAdsWatchedToday(user.adsWatchedToday);
        }
      });
    }

    return Scaffold(
      backgroundColor: isDark ? CliniqTheme.darkBg : CliniqTheme.lightBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ───────────────────
                  HomeHeader(isDark: isDark),

                  const SizedBox(height: 18),

                  // ─── Announcement Banner ──────
                  if (configProvider.hasAnnouncement)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A1F00)
                            : const Color(0xFFFFF8E8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? CliniqTheme.warning.withAlpha(60)
                              : CliniqTheme.warning.withAlpha(40),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '📢',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              configProvider.config.announcementText,
                              style: TextStyle(
                                color: isDark
                                    ? CliniqTheme.warning
                                    : const Color(0xFF854F0B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  CreditsBanner(
                    isDark: isDark,
                    onWatchAd: _onWatchAd,
                    onUpgrade: _onUpgrade,
                  ),

                  const SizedBox(height: 12),

                  AiChatStrip(
                    isDark: isDark,
                    onTap: _onAiChatTap,
                  ),

                  const SizedBox(height: 20),

                  // ─── Features Header ──────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FEATURES',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkTextMuted
                              : CliniqTheme.lightTextMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
                        ),
                      ),
                      Text(
                        'See all →',
                        style: TextStyle(
                          color: isDark
                              ? CliniqTheme.darkPrimary
                              : CliniqTheme.lightPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ─── Feature Grid ─────────────
                  FeatureGrid(isDark: isDark),

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
