import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme.dart';

class FeatureCard extends StatelessWidget {
  final dynamic icon;
  final String line1;
  final String line2;
  final String subtitle;
  final Color iconBgColor;
  final Color iconColor;
  final Color cornerColor;
  final VoidCallback onTap;
  final bool isDark;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.line1,
    required this.line2,
    required this.subtitle,
    required this.iconBgColor,
    required this.iconColor,
    required this.cornerColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? iconColor.withAlpha(50) : iconColor.withAlpha(30),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withAlpha(isDark ? 20 : 12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top row: Icon + Arrow ─────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withAlpha(isDark ? 70 : 40),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: icon,
                      size: 22.0,
                      color: iconColor,
                    ),
                  ),
                ),

                // Arrow button
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_outward_rounded,
                    size: 14,
                    color: iconColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Title ────────────────────────────
            Text(
              line1,
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              line2,
              style: TextStyle(
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 8),

            // ─── Subtitle ─────────────────────────
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
