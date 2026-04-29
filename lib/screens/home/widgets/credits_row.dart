import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/user_provider.dart';

class CreditsRow extends StatelessWidget {
  final bool isDark;
  final VoidCallback onWatchAd;

  const CreditsRow({
    super.key,
    required this.isDark,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.select<UserProvider, dynamic>(
      (p) => p.user,
    );

    final isPro = user?.isPro ?? false;
    final credits = user?.totalCredits ?? 0;

    return Row(
      children: [
        // Credits pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                isPro
                    ? 'Unlimited scans'
                    : '$credits free scan${credits == 1 ? '' : 's'} today',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Watch ad pill — only for free users
        if (!isPro)
          GestureDetector(
            onTap: onWatchAd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? CliniqTheme.darkPrimary.withAlpha(25)
                    : CliniqTheme.lightPrimary.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? CliniqTheme.darkPrimary.withAlpha(80)
                      : CliniqTheme.lightPrimary.withAlpha(60),
                  width: 0.5,
                ),
              ),
              child: Text(
                'Watch ad +2',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        const Spacer(),

        // Pro badge
        if (isPro)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? CliniqTheme.darkPrimary.withAlpha(25)
                  : CliniqTheme.lightPrimary.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? CliniqTheme.darkPrimary.withAlpha(80)
                    : CliniqTheme.lightPrimary.withAlpha(60),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 12,
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pro',
                  style: TextStyle(
                    color: isDark
                        ? CliniqTheme.darkPrimary
                        : CliniqTheme.lightPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
