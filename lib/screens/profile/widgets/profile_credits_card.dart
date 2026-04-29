import 'package:cliniq/screens/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme.dart';
import '../../../providers/user_provider.dart';

class ProfileCreditsCard extends StatelessWidget {
  final UserModel user;
  final bool isDark;

  const ProfileCreditsCard({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Iconsax.flash,
                size: 16,
                color:
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Credits & Usage',
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Credits row
          Row(
            children: [
              Expanded(
                child: _CreditItem(
                  label: 'Free Credits',
                  value: user.isPro ? '∞' : '${user.freeCredits}',
                  icon: Iconsax.gift,
                  color: CliniqTheme.success,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreditItem(
                  label: 'Ad Credits',
                  value: user.isPro ? '∞' : '${user.adCredits}',
                  icon: Iconsax.video_play,
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CreditItem(
                  label: 'Total',
                  value: user.isPro ? 'Pro' : '${user.totalCredits}',
                  icon: Iconsax.wallet,
                  color: CliniqTheme.warning,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          if (!user.isPro) ...[
            const SizedBox(height: 14),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily credits used',
                      style: TextStyle(
                        color: isDark
                            ? CliniqTheme.darkTextMuted
                            : CliniqTheme.lightTextMuted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${5 - user.freeCredits}/5',
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
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (5 - user.freeCredits) / 5,
                    backgroundColor: isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],

          if (!user.isPro) ...[
            const SizedBox(height: 14),
            // Upgrade banner
            GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(
                builder: (_) => const PaywallScreen(),
              )), // RevenueCat baad mein
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary,
                      isDark
                          ? CliniqTheme.darkPrimary.withAlpha(180)
                          : CliniqTheme.lightPrimary.withAlpha(180),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upgrade to Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Unlimited credits • ₹149/month',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreditItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _CreditItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
