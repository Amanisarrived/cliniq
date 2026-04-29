import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class NoCreditsContent extends StatelessWidget {
  final bool isDark;

  const NoCreditsContent({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No credits left 😔',
          style: TextStyle(
            color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Watch an ad for 2 free credits or upgrade to Pro for unlimited access.',
          style: TextStyle(
            color:
                isDark ? CliniqTheme.darkTextMuted : CliniqTheme.lightTextMuted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
