import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AiChatStrip extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const AiChatStrip({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // ─── Logo ─────────────────────────────
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/cliniq_logo (1).png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ─── Text ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask Cliniq AI',
                    style: TextStyle(
                      color:
                          isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Medicine • Symptoms • Guidance',
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

            // ─── Arrow ────────────────────────────
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color:
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
