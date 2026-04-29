import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SessionLimitCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onWatchAd;
  final VoidCallback onUpgrade;

  const SessionLimitCard({
    super.key,
    required this.isDark,
    required this.onWatchAd,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AI message
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: CliniqTheme.danger,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFD0D3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily limit reached',
                      style: TextStyle(
                        color: CliniqTheme.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You've used all your free scans today. Come back tomorrow or get more scans.",
                      style: TextStyle(
                        color: CliniqTheme.danger.withAlpha(200),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Upgrade button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: const Column(
              children: [
                Text(
                  'Upgrade to Pro ✨',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Unlimited scans • ₹149/month',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Watch ad button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onWatchAd,
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              side: BorderSide(
                color: isDark
                    ? CliniqTheme.darkPrimary.withAlpha(80)
                    : CliniqTheme.lightPrimary.withAlpha(80),
                width: 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: const Text(
              'Watch ad for +2 scans',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
