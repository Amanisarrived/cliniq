import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class StreakBanner extends StatelessWidget {
  final int streak;
  final bool isDark;

  const StreakBanner({
    super.key,
    required this.streak,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B35).withAlpha(isDark ? 40 : 25),
            const Color(0xFFFFB347).withAlpha(isDark ? 30 : 15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B35).withAlpha(isDark ? 80 : 60),
        ),
      ),
      child: Row(
        children: [
          // Fire emoji + count
          const Text(
            '🔥',
            style:  TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),

          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day Streak!',
                  style: TextStyle(
                    color:
                        isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  streak >= 7
                      ? 'Amazing consistency! Keep it up 💪'
                      : streak >= 3
                          ? 'Great habit forming! 👏'
                          : 'Good start! Keep going!',
                  style: TextStyle(
                    color: isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Streak dots
          Row(
            children: List.generate(
              streak > 7 ? 7 : streak,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
