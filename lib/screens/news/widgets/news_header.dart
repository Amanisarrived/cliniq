import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class NewsHeader extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onRefresh;

  const NewsHeader({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health News',
                style: TextStyle(
                  color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Latest health updates',
                style: TextStyle(
                  color: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),

          // ─── Refresh Button ───────────────────
          GestureDetector(
            onTap: isLoading ? null : onRefresh,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
                ),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: isDark
                          ? CliniqTheme.darkTextMuted
                          : CliniqTheme.lightTextMuted,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
