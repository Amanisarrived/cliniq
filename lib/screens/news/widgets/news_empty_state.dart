import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class NewsEmptyState extends StatelessWidget {
  final bool isDark;

  const NewsEmptyState({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📰', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No news yet',
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check back later for health updates',
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
