import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class NewsErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const NewsErrorState({
    super.key,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Could not load news',
            style: TextStyle(
              color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please check your connection',
            style: TextStyle(
              color: isDark
                  ? CliniqTheme.darkTextMuted
                  : CliniqTheme.lightTextMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
