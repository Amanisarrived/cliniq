import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/scan_result_model.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResult result;
  final bool isDark;

  const ScanResultCard({
    super.key,
    required this.result,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Avatar
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color:
                isDark ? CliniqTheme.darkSurface2 : CliniqTheme.lightSurface2,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
          ),
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine name card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? CliniqTheme.darkPrimary
                      : CliniqTheme.lightPrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IDENTIFIED',
                      style: TextStyle(
                        color: Colors.white.withAlpha(153),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.08,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.medicineName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Info cards
              _InfoCard(
                label: "WHAT IT'S FOR",
                value: result.whatItsFor,
                isDark: isDark,
                labelColor:
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              ),

              const SizedBox(height: 5),

              _InfoCard(
                label: 'WHEN TO TAKE',
                value: result.whenToTake,
                isDark: isDark,
                labelColor:
                    isDark ? CliniqTheme.darkPrimary : CliniqTheme.lightPrimary,
              ),

              const SizedBox(height: 5),

              _InfoCard(
                label: '⚠️ AVOID',
                value: result.avoid,
                isDark: isDark,
                isWarning: true,
              ),

              if (result.additionalInfo != null) ...[
                const SizedBox(height: 5),
                _InfoCard(
                  label: 'NOTE',
                  value: result.additionalInfo!,
                  isDark: isDark,
                  labelColor: isDark
                      ? CliniqTheme.darkTextMuted
                      : CliniqTheme.lightTextMuted,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isWarning;
  final Color? labelColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.isDark,
    this.isWarning = false,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFFFF8E8)
            : (isDark ? CliniqTheme.darkSurface : CliniqTheme.lightSurface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFFAEEDA)
              : (isDark ? CliniqTheme.darkBorder : CliniqTheme.lightBorder),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isWarning
                  ? const Color(0xFF854F0B)
                  : (labelColor ??
                      (isDark
                          ? CliniqTheme.darkPrimary
                          : CliniqTheme.lightPrimary)),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.06,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: isWarning
                  ? const Color(0xFF854F0B)
                  : (isDark ? CliniqTheme.darkText : CliniqTheme.lightText),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
