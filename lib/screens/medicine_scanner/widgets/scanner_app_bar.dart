import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ScannerAppBar extends StatelessWidget {
  final bool isDark;
  final int creditsLeft;

  const ScannerAppBar({
    super.key,
    required this.isDark,
    required this.creditsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // ─── Back Button ──────────────────────
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark
                    ? CliniqTheme.darkSurface2
                    : CliniqTheme.lightSurface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ─── Logo ─────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/cliniq_logo (1).png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 10),

          // ─── Title ────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicine Scanner',
                  style: TextStyle(
                    color:
                        isDark ? CliniqTheme.darkText : CliniqTheme.lightText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'AI Ready',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Credits Pill ─────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: creditsLeft <= 0
                  ? const Color(0xFFFFEEEE)
                  : (isDark
                      ? CliniqTheme.darkSurface2
                      : CliniqTheme.lightSurface2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: creditsLeft <= 0
                    ? const Color(0xFFFFD0D3)
                    : (isDark
                        ? CliniqTheme.darkBorder
                        : CliniqTheme.lightBorder),
                width: 0.5,
              ),
            ),
            child: Text(
              creditsLeft <= 0 ? 'No scans left' : '$creditsLeft scans left',
              style: TextStyle(
                color: creditsLeft <= 0
                    ? CliniqTheme.danger
                    : (isDark
                        ? CliniqTheme.darkTextMuted
                        : CliniqTheme.lightTextMuted),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
